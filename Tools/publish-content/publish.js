#!/usr/bin/env node
// Publishes articles and recipes from App Content to the app, without the app's publisher screens.
// Run with --help for usage. Without --publish it only checks and shows what it would do.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { SUMMARY_MAX } from './lib/parse.js';
import { findUpcomingFolders, formatDay, parseDay, readContentFolder } from './lib/folder.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const config = JSON.parse(fs.readFileSync(path.join(here, 'config.json'), 'utf8'));

const HELP = `Usage: npm run publish -- [folders…] [options]

Publishes articles and recipes from "App Content" to the Carnivore Diet Guide.
Each folder is …/Articles/YYYY/MM/DD/ or …/Recipes/YYYY/MM/DD/ with one text file and one cover image.
With no folders, it picks up every folder dated today or later.

Nothing is published without --publish: it checks each folder and shows what would go live.

Options:
  --publish          Publish everything that passes the checks.
  --now              Go live right away instead of on the folder's date.
  --date YYYY-MM-DD  Go live on this day instead of the folder's date.
  --type TYPE        "article" or "recipe", for a folder outside Articles or Recipes.
  --free             Free for everyone (otherwise Carnivore+, unless the file says "**Premium:** No").
  --premium          Carnivore+ only, whatever the file says.
  --author ID        Publish as this publisher instead of the one in config.json.
  --offline          Only check the files; don't look anything up in Firebase.
  -h, --help         Show this.

Sign in once with: gcloud auth application-default login`;

let args;
try {
    args = parseArgs({
        allowPositionals: true,
        options: {
            publish: { type: 'boolean' },
            now: { type: 'boolean' },
            date: { type: 'string' },
            type: { type: 'string' },
            free: { type: 'boolean' },
            premium: { type: 'boolean' },
            author: { type: 'string' },
            offline: { type: 'boolean' },
            help: { type: 'boolean', short: 'h' },
        },
    });
} catch (error) {
    console.error(`${error.message}\n\n${HELP}`);
    process.exit(2);
}
const { values: options, positionals } = args;
if (options.help) {
    console.log(HELP);
    process.exit(0);
}
if (options.publish && options.offline) fail('--publish needs Firebase, so it can\'t be used with --offline.');
if (options.free && options.premium) fail('Pass --free or --premium, not both.');
if (options.type && !['article', 'recipe'].includes(options.type)) fail('--type must be "article" or "recipe".');
const date = options.date ? parseDay(options.date) : undefined;
if (options.date && !date) fail(`--date "${options.date}" isn't a YYYY-MM-DD date.`);
if (date && options.now) fail('Pass --date or --now, not both.');

function fail(message) {
    console.error(message);
    process.exit(2);
}

const authorId = options.author ?? config.authorId;
const contentRoot = path.resolve(here, config.contentRoot);
// `npm run` moves into this folder, so folders are relative to where the command was typed.
const startDir = process.env.INIT_CWD ?? process.cwd();
const folders = positionals.length ? positionals.map((folder) => path.resolve(startDir, folder)) : findUpcomingFolders(contentRoot);
if (folders.length === 0) {
    console.log(`Nothing dated today or later in ${contentRoot}.`);
    process.exit(0);
}
for (const folder of folders) {
    if (!fs.existsSync(folder) || !fs.statSync(folder).isDirectory()) fail(`Not a folder: ${folder}`);
}

const items = folders.map((folder) => readContentFolder(folder, {
    type: options.type,
    date,
    publishNow: options.now,
    isPremium: options.free ? false : options.premium ? true : undefined,
}));

// Look up categories and anything already published.
let connection = null;
if (!options.offline) {
    const { connect, fetchArticleCategories, findPublished } = await import('./lib/firebase.js');
    try {
        connection = connect(config);
        const needsCategories = items.some((item) => item.type === 'article');
        const categories = needsCategories ? await fetchArticleCategories(connection) : new Map();
        for (const item of items) {
            if (item.type === 'article' && item.categoryNames?.length) {
                item.categories = [];
                for (const name of item.categoryNames) {
                    const category = categories.get(name.toLowerCase());
                    if (category) item.categories.push(category);
                    else item.errors.push(`No article category "${name}". Use one of: ${[...categories.values()].map((c) => c.name).sort().join(', ')}.`);
                }
            }
            if (item.title && item.type) item.published = await findPublished(connection, item.type, item.title);
        }
    } catch (error) {
        console.error(`Couldn't reach Firebase: ${error.message}`);
        console.error('Sign in with "gcloud auth application-default login", or pass --offline to only check the files.');
        process.exit(1);
    }
}

// Report
const relative = (file) => {
    const inside = path.relative(contentRoot, file);
    return inside && !inside.startsWith('..') ? inside : file;
};
const when = (item) => {
    if (!item.publicationDate) return 'no date';
    const isNow = Math.abs(item.publicationDate - Date.now()) < 60_000;
    return isNow ? 'goes live now' : `goes live ${formatDay(item.publicationDate)}`;
};
const label = { article: 'Article', recipe: 'Recipe' };

for (const item of items) {
    console.log(`\n${label[item.type] ?? 'Unknown'} · ${relative(item.folder)}`);
    if (item.title) console.log(`  ${item.title}`);
    if (item.summary) console.log(`  Summary (${item.summary.length}/${SUMMARY_MAX}): ${item.summary}`);
    const details = [when(item), item.isPremium ? 'Carnivore+' : 'Free'];
    if (item.type === 'article') {
        if (item.categories?.length) details.push(item.categories.map((c) => c.name).join(', '));
        else if (item.categoryNames?.length) details.push(item.categoryNames.join(', '));
        details.push(`${item.citations?.length ?? 0} citation${item.citations?.length === 1 ? '' : 's'}`);
    }
    if (item.type === 'recipe' && item.difficultyLevel) {
        details.push(`${item.difficultyLevel}, ${item.prepTimeMinutes} min prep, ${item.cookTimeMinutes} min cook, serves ${item.servings}`);
        if (item.nutrition) {
            const n = item.nutrition;
            details.push(`${n.calories} kcal, ${n.protein}g protein, ${n.fat}g fat, ${n.carbohydrates}g carbs`);
        }
    }
    console.log(`  ${details.join(' · ')}`);
    if (item.imageFile) console.log(`  Cover: ${path.basename(item.imageFile)}`);
    if (item.body) {
        const opening = item.body.split('\n').find((line) => line.trim())?.slice(0, 70);
        console.log(`  Body: ${item.body.length.toLocaleString()} characters, starting "${opening}${opening?.length === 70 ? '…' : ''}"`);
    }
    for (const warning of item.warnings) console.log(`  ! ${warning}`);
    for (const error of item.errors) console.log(`  ✗ ${error}`);
    if (item.published) {
        console.log(`  = Already published as ${item.published.id}${item.published.publicationDate ? ` (${formatDay(item.published.publicationDate)})` : ''}, so it's skipped.`);
    } else if (item.errors.length === 0) {
        console.log(options.offline ? '  ✓ The file checks out (not checked against Firebase)' : '  ✓ Ready');
    }
}

const ready = items.filter((item) => item.errors.length === 0 && !item.published);
const blocked = items.filter((item) => item.errors.length > 0);
console.log('');

if (!options.publish) {
    const fix = blocked.length ? ` ${blocked.length} need${blocked.length === 1 ? 's' : ''} fixing first.` : '';
    console.log(ready.length
        ? `Nothing was published. Run again with --publish to publish ${ready.length === 1 ? 'the 1 ready item' : `the ${ready.length} ready items`}.${fix}`
        : `Nothing is ready to publish.${fix}`);
    process.exit(blocked.length ? 1 : 0);
}

const { publish } = await import('./lib/firebase.js');
let failures = blocked.length;
for (const item of ready) {
    try {
        const { id } = await publish(connection, item, { authorId, categoryIds: item.categories?.map((c) => c.id) ?? [] });
        console.log(`Published "${item.title}" as ${id}, ${when(item)}.`);
    } catch (error) {
        failures += 1;
        console.error(`Couldn't publish "${item.title}": ${error.message}`);
    }
}
if (blocked.length) console.log(`Skipped ${blocked.length} with problems.`);
process.exit(failures ? 1 : 0);

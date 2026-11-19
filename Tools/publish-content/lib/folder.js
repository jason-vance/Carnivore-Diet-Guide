// A content folder is `App Content/Articles/YYYY/MM/DD/` (or `Recipes/…`) holding one text file and one cover image.

import fs from 'node:fs';
import path from 'node:path';
import { parseContent, parseRecipeDetails, parseYesNo } from './parse.js';

const IMAGE_EXTENSIONS = new Set(['.jpg', '.jpeg', '.png', '.webp', '.avif', '.tif', '.tiff', '.gif']);
/** Files that are neither the text nor the cover. */
const IGNORED = /\.(json|pdf|docx?|pages|zip)$/i;
const isImage = (name) => IMAGE_EXTENSIONS.has(path.extname(name).toLowerCase());

export function typeOf(folder) {
    const parts = path.resolve(folder).split(path.sep);
    if (parts.includes('Articles')) return 'article';
    if (parts.includes('Recipes')) return 'recipe';
    return null;
}

/** The folder's `YYYY/MM/DD`, as that day's local midnight (the same default the app used). */
export function dateOf(folder) {
    const match = path.resolve(folder).match(/(\d{4})[/\\](\d{1,2})[/\\](\d{1,2})(?:[/\\]|$)/);
    if (!match) return null;
    const [, year, month, day] = match.map(Number);
    return new Date(year, month - 1, day);
}

export function startOfToday(now = new Date()) {
    return new Date(now.getFullYear(), now.getMonth(), now.getDate());
}

export function formatDay(date) {
    const pad = (n) => String(n).padStart(2, '0');
    return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
}

/** Parses `YYYY-MM-DD` as local midnight. */
export function parseDay(text) {
    const match = /^(\d{4})-(\d{1,2})-(\d{1,2})$/.exec(text ?? '');
    if (!match) return null;
    const [, year, month, day] = match.map(Number);
    const date = new Date(year, month - 1, day);
    return date.getMonth() === month - 1 ? date : null;
}

/**
 * Reads and checks one folder. Nothing here touches Firebase.
 * @param {string} folder
 * @param {{ type?: 'article'|'recipe', date?: Date, now?: Date, publishNow?: boolean, isPremium?: boolean }} options
 */
export function readContentFolder(folder, options = {}) {
    const errors = [];
    const warnings = [];
    const now = options.now ?? new Date();
    const type = options.type ?? typeOf(folder);
    if (!type) errors.push('Not under an Articles or Recipes folder, so pass --type article or --type recipe.');

    const files = fs.readdirSync(folder, { withFileTypes: true })
        .filter((entry) => entry.isFile() && !entry.name.startsWith('.'))
        .map((entry) => entry.name);
    const heic = files.filter((name) => /\.hei[cf]$/i.test(name));
    const textFiles = files.filter((name) => !isImage(name) && !IGNORED.test(name) && !heic.includes(name));
    const images = files.filter(isImage);

    if (heic.length) errors.push(`${heic.join(', ')} is HEIC, which can't be converted here. Export it as a JPEG.`);
    if (textFiles.length === 0) errors.push('No text file in the folder.');
    if (textFiles.length > 1) errors.push(`More than one text file: ${textFiles.join(', ')}.`);
    if (images.length === 0) errors.push('No cover image (.jpg, .jpeg, .png or .webp) in the folder.');
    if (images.length > 1) errors.push(`More than one image, so it isn't clear which is the cover: ${images.join(', ')}.`);

    const item = {
        folder,
        type,
        textFile: textFiles.length === 1 ? path.join(folder, textFiles[0]) : null,
        imageFile: images.length === 1 ? path.join(folder, images[0]) : null,
        errors,
        warnings,
    };
    if (!item.textFile) return item;

    const parsed = parseContent(fs.readFileSync(item.textFile, 'utf8'), type ?? 'article');
    const recipeDetails = type === 'recipe' ? parseRecipeDetails(parsed) : null;
    Object.assign(item, {
        title: parsed.title,
        summary: parsed.summary,
        body: parsed.body,
        citations: type === 'article' ? parsed.citations : [],
        fields: parsed.fields,
    });
    errors.push(...parsed.errors);
    warnings.push(...parsed.warnings);
    if (type === 'recipe' && parsed.citations.length) {
        // Recipes have nowhere to show sources, so the links stay in the text.
        item.body = [item.body, '', ...parsed.citations].join('\n');
    }

    if (type === 'article') {
        const names = parsed.fields.categories ?? parsed.fields.category;
        item.categoryNames = names ? names.split(/\s*[,;]\s*/).filter(Boolean) : [];
        if (item.categoryNames.length === 0) {
            errors.push('No category. Add a line like "**Category:** Nutrition" between the summary and the body.');
        }
    } else if (recipeDetails) {
        Object.assign(item, recipeDetails);
    }

    const premiumField = parseYesNo(parsed.fields.premium);
    // The app published everything as Carnivore+ unless told otherwise.
    item.isPremium = options.isPremium ?? premiumField ?? true;

    // When it goes live: the folder's day at midnight, or right away if that's already passed today.
    const day = options.date ?? dateOf(folder);
    const today = startOfToday(now);
    if (options.publishNow) {
        item.publicationDate = now;
    } else if (!day) {
        errors.push('No date in the folder path (…/YYYY/MM/DD/), so pass --date YYYY-MM-DD or --now.');
    } else if (day < today) {
        errors.push(`${formatDay(day)} has passed. Pass --now to publish it now, or --date YYYY-MM-DD to schedule it.`);
    } else {
        item.publicationDate = day.getTime() === today.getTime() ? now : day;
    }
    return item;
}

/** Content folders in App Content dated today or later. */
export function findUpcomingFolders(contentRoot, now = new Date()) {
    const today = startOfToday(now);
    const found = [];
    for (const kind of ['Articles', 'Recipes']) {
        const root = path.join(contentRoot, kind);
        if (!fs.existsSync(root)) continue;
        const walk = (dir, depth) => {
            for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
                if (!entry.isDirectory() || !/^\d+$/.test(entry.name)) continue;
                const child = path.join(dir, entry.name);
                if (depth < 2) walk(child, depth + 1);
                else if (dateOf(child) >= today) found.push(child);
            }
        };
        walk(root, 0);
    }
    return found.sort((a, b) => dateOf(a) - dateOf(b) || a.localeCompare(b));
}

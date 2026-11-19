// Reads an article or recipe written the way the files in App Content are:
//
//   Title
//
//   **Summary:**
//   One or two sentences, 128 characters at most.
//
//   ---
//   **Category:** Nutrition            (articles; recipes have Difficulty, Prep Time, … and nutrition instead)
//   ---
//
//   The body, in Markdown…
//
//   https://a-source.com/…            (bare links at the very end become the article's citations)

/** The app hides an article or recipe whose summary is outside these lengths (`Resource.Summary`). */
export const SUMMARY_MIN = 12;
export const SUMMARY_MAX = 128;

const SEPARATOR = /^\s*(?:-{3,}|\*{3,}|_{3,})\s*$/;
// `**Key:** value`, `**Key**: value` or `* **Key:** value`.
const FIELD = /^\s*(?:[*-]\s+)?\*\*\s*([^*]+?)\s*:?\s*\*\*\s*:?\s*(.*)$/;
const URL_LINE = /^\s*(?:[*-]\s+|\d+\.\s+)?<?(https?:\/\/[^\s>]+)>?\s*$/;
const SOURCES_HEADING = /^\s*(?:#{1,6}\s*)?\**\s*(?:sources|references|citations)\s*:?\s*\**\s*:?\s*$/i;

const ARTICLE_KEYS = new Set(['category', 'categories', 'topic', 'premium', 'tags', 'keywords']);
const RECIPE_KEYS = new Set([
    'difficulty', 'prep time', 'cook time', 'total time', 'servings', 'serves', 'yield', 'premium',
    'nutrition', 'calories', 'protein', 'fat', 'carbs', 'carbohydrates',
]);

const ALIASES = {
    level: 'difficulty', 'difficulty level': 'difficulty',
    prep: 'prep time', 'preparation time': 'prep time', 'prep time': 'prep time',
    cook: 'cook time', 'cooking time': 'cook time',
    serves: 'servings', yield: 'servings', serving: 'servings',
    carbohydrates: 'carbs', 'total carbs': 'carbs', 'net carbs': 'carbs', carb: 'carbs',
    kcal: 'calories', energy: 'calories',
};

/** `**Prep Time (approx.)**` → `prep time`, `Level` → `difficulty` */
function normalizeKey(key) {
    const plain = key.replace(/\*/g, '').toLowerCase().replace(/\(.*?\)/g, '').replace(/\s+/g, ' ').trim();
    return ALIASES[plain] ?? plain;
}

const INGREDIENTS_HEADING = /^\s*(?:#{1,6}\s*)?\**\s*ingredients\b/i;
const PLAIN_FIELD = /^\s*(?:[*-]\s+)?([A-Za-z][A-Za-z ()/]{1,30}):\s+(\S.*)$/;

function cleanTitle(line) {
    return line.replace(/^\s*#+\s*/, '').replace(/^\*\*(.*)\*\*$/, '$1').trim();
}

function isKnownField(line, type) {
    const match = line.match(FIELD);
    if (!match) return false;
    const key = normalizeKey(match[1]);
    const keys = type === 'recipe' ? RECIPE_KEYS : ARTICLE_KEYS;
    return keys.has(key) || (type === 'recipe' && key.includes('nutrition'));
}

/** Splits a Markdown table row into cells without the bold markers. */
function tableCells(line) {
    return line.trim().replace(/^\||\|$/g, '').split('|').map((cell) => cell.replace(/\*/g, '').trim());
}

/**
 * Reads `**Key:** value` lines, plain `Key: value` lines and tables, across (a row of names, then a row of
 * values) or down (`| Difficulty | Easy |`).
 */
function readFields(headerLines) {
    const fields = {};
    const set = (key, value) => {
        const name = normalizeKey(key);
        if (name && value?.trim() && !(name in fields)) fields[name] = value.trim();
    };
    const tables = [];
    let table = null;
    for (const line of headerLines) {
        if (/^\s*\|/.test(line)) {
            if (!table) tables.push((table = []));
            const cells = tableCells(line);
            if (!cells.every((cell) => /^:?-+:?$/.test(cell))) table.push(cells);
            continue;
        }
        table = null;
        // `**Calories:** 650 | **Protein:** 55g` on one line.
        for (const part of line.split(/\s\|\s/)) {
            const field = part.match(FIELD);
            if (field) set(field[1], field[2]);
            else if (PLAIN_FIELD.test(part)) set(...part.match(PLAIN_FIELD).slice(1, 3));
        }
    }
    const known = new Set([...RECIPE_KEYS, ...ARTICLE_KEYS]);
    for (const rows of tables) {
        if (rows.length >= 2 && rows[0].length > 2 && rows[0].every((cell) => known.has(normalizeKey(cell)))) {
            rows[0].forEach((name, index) => set(name, rows[1][index]));
        } else {
            for (const cells of rows) if (cells.length >= 2) set(cells[0], cells[1]);
        }
    }
    return fields;
}

/**
 * @param {string} text the file's contents
 * @param {'article' | 'recipe'} type
 * @returns {{ title: string, summary: string, body: string, citations: string[], fields: Record<string,string>,
 *            errors: string[], warnings: string[] }}
 */
export function parseContent(text, type) {
    const errors = [];
    const warnings = [];
    const lines = text.replace(/^﻿/, '').replace(/\r\n?/g, '\n').replace(/ /g, ' ').split('\n');

    let i = lines.findIndex((line) => line.trim() !== '');
    const title = i === -1 ? '' : cleanTitle(lines[i]);
    i += 1;

    // The summary: inline after `**Summary:**` and/or on the lines right after it.
    let summary = '';
    for (; i < lines.length; i++) {
        const line = lines[i];
        if (line.trim() === '' || SEPARATOR.test(line)) continue;
        const match = line.match(FIELD);
        if (match && normalizeKey(match[1]) === 'summary') {
            const parts = match[2].trim() ? [match[2].trim()] : [];
            let j = i + 1;
            // Allow one blank line between `**Summary:**` and its text.
            if (parts.length === 0 && lines[j]?.trim() === '') j += 1;
            for (; j < lines.length; j++) {
                const next = lines[j];
                if (next.trim() === '' || SEPARATOR.test(next) || FIELD.test(next)) break;
                parts.push(next.trim());
            }
            summary = parts.join(' ').trim();
            i = j;
        } else if (!match && !/^\s*(?:#|\||[*-]\s|\d+\.\s)/.test(line)) {
            // No "**Summary:**" label: a first paragraph that the details come right after is the summary.
            let j = i;
            const parts = [];
            for (; j < lines.length && lines[j].trim() !== '' && !SEPARATOR.test(lines[j]); j++) parts.push(lines[j].trim());
            let k = j;
            while (k < lines.length && lines[k].trim() === '') k++;
            if (k < lines.length && (SEPARATOR.test(lines[k]) || isKnownField(lines[k], type))) {
                summary = parts.join(' ');
                i = j;
            }
        }
        break;
    }
    if (!summary) errors.push('No summary found. Put it under a "**Summary:**" line right after the title.');

    // The details between the summary and the body. A recipe's run up to its ingredients, whatever their layout.
    const detailsStart = i;
    let bodyStart = type === 'recipe' ? lines.findIndex((line, index) => index >= i && INGREDIENTS_HEADING.test(line)) : -1;
    if (bodyStart === -1) {
        bodyStart = lines.length;
        for (; i < lines.length; i++) {
            const line = lines[i];
            if (line.trim() === '' || SEPARATOR.test(line) || isKnownField(line, type)) continue;
            // A bare "**Article:**" label before the text.
            if (/^\s*\**\s*(?:article|body|content|text)\s*:?\s*\**\s*:?\s*$/i.test(line)) continue;
            if (type === 'recipe' && (/^\s*#{1,6}.*nutrition/i.test(line) || /^\s*\|/.test(line))) continue;
            bodyStart = i;
            break;
        }
    }
    const fields = readFields(lines.slice(detailsStart, bodyStart));

    // Bare links at the end are citations, as are links under a closing "Sources" heading.
    const bodyLines = lines.slice(bodyStart);
    const citations = [];
    const trimTrailingBlanks = () => {
        while (bodyLines.length && (bodyLines.at(-1).trim() === '' || SEPARATOR.test(bodyLines.at(-1)))) bodyLines.pop();
    };
    trimTrailingBlanks();
    while (bodyLines.length) {
        const url = bodyLines.at(-1).match(URL_LINE);
        if (!url) break;
        citations.unshift(url[1]);
        bodyLines.pop();
        while (bodyLines.length && bodyLines.at(-1).trim() === '') bodyLines.pop();
    }
    if (citations.length && bodyLines.length && SOURCES_HEADING.test(bodyLines.at(-1))) bodyLines.pop();
    trimTrailingBlanks();
    const body = bodyLines.join('\n').trim();

    if (!title) errors.push('The file is empty.');
    if (!body) errors.push('No body found after the summary and details.');
    if (summary && (summary.length < SUMMARY_MIN || summary.length > SUMMARY_MAX)) {
        errors.push(
            `The summary is ${summary.length} characters. The app only shows summaries of ${SUMMARY_MIN}–${SUMMARY_MAX} characters, so it would hide this.`
        );
    }

    return { title, summary, body, citations, fields, errors, warnings };
}

// Recipes

const DIFFICULTIES = {
    beginner: 'beginner', easy: 'beginner', simple: 'beginner',
    intermediate: 'intermediate', medium: 'intermediate', moderate: 'intermediate',
    advanced: 'advanced', hard: 'advanced', difficult: 'advanced', expert: 'advanced',
};

const LEVELS = ['beginner', 'intermediate', 'advanced'];

/**
 * "Easy" or "Very Easy"; "Easy/Medium" is the harder one, with a note.
 * @returns {{ level: string | null, note: string | null }}
 */
export function parseDifficulty(text) {
    const levels = [...new Set(((text ?? '').toLowerCase().match(/[a-z]+/g) ?? []).map((word) => DIFFICULTIES[word]).filter(Boolean))];
    if (levels.length === 0) return { level: null, note: null };
    const level = levels.sort((a, b) => LEVELS.indexOf(b) - LEVELS.indexOf(a))[0];
    return { level, note: levels.length > 1 ? 'used the harder one' : null };
}

const NUMBER = String.raw`(\d+(?:\.\d+)?)`;
const RANGE_DASH = String.raw`\s*(?:-|–|—|to)\s*`;
const HOURS = String.raw`(?:hours?|hrs?|h)\b`;
const MINUTES = String.raw`(?:minutes?|mins?|m)\b`;

/**
 * Minutes from text like "10 mins", "1 hour 30 minutes", "1.5 hours" or "3–4 hours". A range uses its middle,
 * and only the first option of "4 hours (High) or 7 hours (Low)" is read, so either comes with a note.
 * @returns {{ minutes: number | null, note: string | null }}
 */
export function parseMinutes(text) {
    if (!text) return { minutes: null, note: null };
    // "2 hours (plus 10 min rest)" is 2 hours.
    const source = text.replace(/\(.*?\)/g, ' ').replace(/\s+/g, ' ').trim();
    const first = source.split(/\s+or\s+|\s*\/\s*|;/i)[0].trim();
    let note = first !== source ? 'used the first option' : /\(.*\d.*\)/.test(text) ? 'left out the part in brackets' : null;

    const range = first.match(new RegExp(`${NUMBER}${RANGE_DASH}${NUMBER}\\s*(${HOURS}|${MINUTES})`, 'i'));
    if (range) {
        const unit = /^h/i.test(range[3]) ? 60 : 1;
        // The publisher always picked the top of a range in the app.
        return { minutes: Math.round(Number(range[2]) * unit), note: 'used the top of the range' };
    }

    let minutes = 0;
    let found = false;
    const hours = first.match(new RegExp(`${NUMBER}\\s*${HOURS}`, 'i'));
    if (hours) { minutes += Number(hours[1]) * 60; found = true; }
    const mins = first.match(new RegExp(`${NUMBER}\\s*${MINUTES}`, 'i'));
    if (mins) { minutes += Number(mins[1]); found = true; }
    if (!found) {
        const bare = first.match(new RegExp(`^${NUMBER}$`));
        if (!bare) return { minutes: null, note: null };
        minutes = Number(bare[1]);
        note = 'no unit, so took it as minutes';
    }
    return { minutes: Math.round(minutes), note };
}

/** "4", "6–8" (→ 8) or "4 (about 12 meatballs)" (→ 4) */
export function parseCount(text) {
    if (!text) return { count: null, note: null };
    text = text.replace(/\(.*?\)/g, ' ');
    const range = text.match(new RegExp(`${NUMBER}${RANGE_DASH}${NUMBER}`));
    if (range) return { count: Math.round(Number(range[2])), note: 'used the top of the range' };
    const single = text.match(/\d+/);
    return single ? { count: Number(single[0]), note: null } : { count: null, note: null };
}

const firstNumber = (text) => {
    const match = (text ?? '').replace(/,/g, '').match(/\d+(?:\.\d+)?/);
    return match ? Math.round(Number(match[0])) : null;
};

/**
 * Per-serving nutrition, from bullets or a table.
 * @returns {{ calories: number, protein: number, fat: number, carbohydrates: number } | null}
 */
export function parseNutrition(fields) {
    const values = {
        calories: firstNumber(fields.calories),
        protein: firstNumber(fields.protein),
        fat: firstNumber(fields.fat),
        carbohydrates: firstNumber(fields.carbs),
    };
    return Object.values(values).every(Number.isInteger) ? values : null;
}

/** Everything a recipe needs beyond the shared fields. */
export function parseRecipeDetails(parsed) {
    const { fields, errors, warnings } = parsed;
    const difficultyText = fields.difficulty;
    const { level: difficultyLevel, note: difficultyNote } = parseDifficulty(difficultyText);
    if (!difficultyLevel) {
        errors.push(difficultyText
            ? `Difficulty "${difficultyText}" isn't one of Easy, Medium or Hard (or Beginner, Intermediate, Advanced).`
            : 'No "**Difficulty:**" line.');
    } else if (difficultyNote) {
        warnings.push(`Difficulty "${difficultyText}" → ${difficultyLevel} (${difficultyNote}).`);
    }

    const time = (label, key) => {
        const raw = fields[key];
        if (!raw) {
            warnings.push(`No "**${label}:**" line, so it's 0 min.`);
            return 0;
        }
        const { minutes, note } = parseMinutes(raw);
        if (minutes === null) errors.push(`Couldn't read ${label} "${raw}" as minutes or hours.`);
        else if (note) warnings.push(`${label} "${raw}" → ${minutes} min (${note}).`);
        return minutes;
    };
    const prepTimeMinutes = time('Prep Time', 'prep time');
    const cookTimeMinutes = time('Cook Time', 'cook time');

    const servingsText = fields.servings;
    const { count: servings, note } = parseCount(servingsText);
    if (!servings) errors.push(servingsText ? `Couldn't read servings "${servingsText}".` : 'No "**Servings:**" line.');
    else if (note) warnings.push(`Servings "${servingsText}" → ${servings} (${note}).`);

    const nutrition = parseNutrition(fields);
    if (!nutrition) warnings.push('No complete nutrition (calories, protein, fat and carbs), so the recipe shows none.');

    return { difficultyLevel, prepTimeMinutes, cookTimeMinutes, servings, nutrition };
}

/** `Yes`/`No`; anything else is left to the default. */
export function parseYesNo(text) {
    if (!text) return null;
    if (/^\s*(yes|true|y)\b/i.test(text)) return true;
    if (/^\s*(no|false|n)\b/i.test(text)) return false;
    return null;
}

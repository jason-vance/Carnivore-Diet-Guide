import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { parseContent, parseCount, parseDifficulty, parseMinutes, parseRecipeDetails } from '../lib/parse.js';
import { findUpcomingFolders, readContentFolder } from '../lib/folder.js';

const ARTICLE = `Surviving the Holidays: Turkey, Ham, and Aunt Karen's Comments

**Summary:**
Turkey, ham and a nosy relative? Here's how to feast like a carnivore this holiday season.

---

**Category:** Traveling on Carnivore
**Topic:** Surviving the Holidays

---

Whether you're hosting or heading home, you know what's waiting.

### The First Feast Was Pretty Meaty

**Happy holidays!**


https://www.pilgrimhall.org/first-thanksgiving/
https://www.nichd.nih.gov/holidayweightgain
`;

test('an article: title, summary, category, body and citations', () => {
    const parsed = parseContent(ARTICLE, 'article');
    assert.equal(parsed.title, "Surviving the Holidays: Turkey, Ham, and Aunt Karen's Comments");
    assert.equal(parsed.summary, "Turkey, ham and a nosy relative? Here's how to feast like a carnivore this holiday season.");
    assert.equal(parsed.fields.category, 'Traveling on Carnivore');
    assert.ok(parsed.body.startsWith("Whether you're hosting"));
    assert.ok(parsed.body.endsWith('**Happy holidays!**'));
    assert.deepEqual(parsed.citations, ['https://www.pilgrimhall.org/first-thanksgiving/', 'https://www.nichd.nih.gov/holidayweightgain']);
    assert.deepEqual(parsed.errors, []);
});

test('links under a closing Sources heading are citations too', () => {
    const parsed = parseContent(`Title\n\n**Summary:** A summary that is long enough.\n\n---\n\nBody.\n\n### Sources\n\n* https://a.com/1\n* <https://b.com/2>\n`, 'article');
    assert.equal(parsed.body, 'Body.');
    assert.deepEqual(parsed.citations, ['https://a.com/1', 'https://b.com/2']);
});

test('a summary the app would hide is an error', () => {
    const parsed = parseContent(`Title\n\n**Summary:** ${'x'.repeat(129)}\n\n---\n\nBody`, 'article');
    assert.match(parsed.errors.join(), /129 characters/);
    assert.match(parseContent('Title\n\n---\n\nBody', 'article').errors.join(), /No summary/);
});

test('a recipe with bullets and a nutrition table across', () => {
    const parsed = parseContent(`Carnivore-Style "Shio" Beef Tongue (Gyutan)

**Summary:**
Tender, fatty beef tongue seasoned with sea salt and seared to perfection.

* **Difficulty:** Easy
* **Prep Time:** 10 mins
* **Cook Time:** 5 mins
* **Servings:** 2

---

### **Nutrition (Per Serving)**

| Calories | Protein | Fat | Carbs |
| --- | --- | --- | --- |
| 480 kcal | 32g | 38g | 0g |

---

### **Ingredients**

* **1 lb (450g)** Beef tongue
`, 'recipe');
    const details = parseRecipeDetails(parsed);
    assert.ok(parsed.body.startsWith('### **Ingredients**'));
    assert.deepEqual(details, {
        difficultyLevel: 'beginner', prepTimeMinutes: 10, cookTimeMinutes: 5, servings: 2,
        nutrition: { calories: 480, protein: 32, fat: 38, carbohydrates: 0 },
    });
    assert.deepEqual(parsed.warnings, []);
});

test('a recipe with tables down, notes and no summary label', () => {
    const parsed = parseContent(`Bacon-Seared Beef Liver

Tender beef liver seared in rich bacon fat. A nutrient-dense, high-protein meal.

---

### Recipe Overview
| Attribute | Details |
| --- | --- |
| **Difficulty** | Easy |
| **Prep Time** | 10 Minutes |
| **Cook Time** | 2 hours (plus 10 min rest) |
| **Servings** | 4 (about 12 meatballs) |

### Estimated Nutrition (Per Serving)
*(Based on a 12oz / 340g Ribeye)*
| Metric | Amount |
| --- | --- |
| **Calories** | ~420 kcal |
| **Protein** | 35g |
| **Fat** | 28g |
| **Carbs** | <1g |

---

### Ingredients

* liver
`, 'recipe');
    const details = parseRecipeDetails(parsed);
    assert.equal(parsed.summary, 'Tender beef liver seared in rich bacon fat. A nutrient-dense, high-protein meal.');
    assert.ok(parsed.body.startsWith('### Ingredients'));
    assert.equal(details.cookTimeMinutes, 120);
    assert.equal(details.servings, 4);
    assert.deepEqual(details.nutrition, { calories: 420, protein: 35, fat: 28, carbohydrates: 1 });
});

test('a recipe with its details in a row across and nutrition on one line', () => {
    const parsed = parseContent(`Short Ribs

**Summary:** Tender, fall-off-the-bone beef short ribs cooked in bone broth.

| **Level** | **Prep Time** | **Cook Time** | **Servings** |
| --- | --- | --- | --- |
| Hard | 10 mins | 60 mins (+ release) | 4 |

* **Calories:** ~650 kcal | **Protein:** 55g | **Fat:** 45g | **Carbs:** <1g

### Ingredients
`, 'recipe');
    const details = parseRecipeDetails(parsed);
    assert.equal(details.difficultyLevel, 'advanced');
    assert.equal(details.cookTimeMinutes, 60);
    assert.deepEqual(details.nutrition, { calories: 650, protein: 55, fat: 45, carbohydrates: 1 });
});

test('times, servings and difficulty', () => {
    assert.deepEqual(parseMinutes('10 mins'), { minutes: 10, note: null });
    assert.equal(parseMinutes('1 hour 30 minutes').minutes, 90);
    assert.equal(parseMinutes('1.5 hours').minutes, 90);
    assert.deepEqual(parseMinutes('3–4 hours (depending on size)'), { minutes: 240, note: 'used the top of the range' });
    assert.equal(parseMinutes('2.5 to 3 hours').minutes, 180);
    assert.deepEqual(parseMinutes('4 hours (High) or 7 hours (Low)'), { minutes: 240, note: 'used the first option' });
    assert.equal(parseMinutes('soon').minutes, null);
    assert.deepEqual(parseCount('6–8'), { count: 8, note: 'used the top of the range' });
    assert.deepEqual(parseCount('4 (approx. 12-15 meatballs)'), { count: 4, note: null });
    assert.deepEqual(parseDifficulty('Very Easy'), { level: 'beginner', note: null });
    assert.deepEqual(parseDifficulty('Easy/Medium'), { level: 'intermediate', note: 'used the harder one' });
    assert.deepEqual(parseDifficulty('Tricky'), { level: null, note: null });
});

test('a missing time is 0 with a note; an unreadable one is an error', () => {
    const parsed = parseContent('Drink\n\n**Summary:** A warm mug of salted bone broth.\n\n* **Difficulty:** Easy\n* **Prep Time:** 2 minutes\n* **Servings:** 1\n\n### Ingredients\n\n* broth', 'recipe');
    const details = parseRecipeDetails(parsed);
    assert.equal(details.cookTimeMinutes, 0);
    assert.match(parsed.warnings.join(), /No "\*\*Cook Time:\*\*" line/);
    assert.deepEqual(parsed.errors, []);
    const bad = parseContent('Drink\n\n**Summary:** A warm mug of salted bone broth.\n\n* **Difficulty:** Easy\n* **Prep Time:** a while\n* **Cook Time:** 2 min\n* **Servings:** 1\n\n### Ingredients\n\n* broth', 'recipe');
    parseRecipeDetails(bad);
    assert.match(bad.errors.join(), /Prep Time "a while"/);
});

// Folders

function makeFolder(root, relative, files) {
    const folder = path.join(root, relative);
    fs.mkdirSync(folder, { recursive: true });
    for (const [name, contents] of Object.entries(files)) fs.writeFileSync(path.join(folder, name), contents);
    return folder;
}

test('a folder goes live on its day at midnight, now if that is today, and not at all if it has passed', () => {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), 'publish-content-'));
    const now = new Date(2026, 10, 18, 9, 30);
    const files = { 'Surviving the Holidays': ARTICLE, 'cover.jpg': 'not really a jpeg' };
    const future = readContentFolder(makeFolder(root, 'Articles/2026/11/20', files), { now });
    assert.deepEqual(future.errors, []);
    assert.equal(future.type, 'article');
    assert.deepEqual(future.publicationDate, new Date(2026, 10, 20));
    assert.equal(future.isPremium, true);
    assert.deepEqual(future.categoryNames, ['Traveling on Carnivore']);

    assert.equal(readContentFolder(makeFolder(root, 'Articles/2026/11/18', files), { now }).publicationDate, now);
    assert.match(readContentFolder(makeFolder(root, 'Articles/2026/11/17', files), { now }).errors.join(), /has passed/);
    assert.equal(readContentFolder(path.join(root, 'Articles/2026/11/17'), { now, publishNow: true }).publicationDate, now);

    assert.deepEqual(findUpcomingFolders(root, now).map((folder) => path.relative(root, folder)), ['Articles/2026/11/18', 'Articles/2026/11/20']);
    fs.rmSync(root, { recursive: true });
});

test('a folder needs one text file, one cover and a category', () => {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), 'publish-content-'));
    const now = new Date(2026, 10, 18);
    const noCover = readContentFolder(makeFolder(root, 'Articles/2026/12/01', { 'Holidays': ARTICLE }), { now });
    assert.match(noCover.errors.join(), /No cover image/);
    const twoCovers = readContentFolder(makeFolder(root, 'Articles/2026/12/02', { 'Holidays': ARTICLE, 'a.jpg': '', 'b.png': '' }), { now });
    assert.match(twoCovers.errors.join(), /More than one image/);
    const noCategory = readContentFolder(makeFolder(root, 'Articles/2026/12/03', { 'Holidays': ARTICLE.replace(/\*\*Category:\*\*.*\n/, ''), 'a.jpg': '' }), { now });
    assert.match(noCategory.errors.join(), /No category/);
    const free = readContentFolder(makeFolder(root, 'Articles/2026/12/04', { 'Holidays': ARTICLE.replace('**Topic:**', '**Premium:** No\n**Topic:**'), 'a.jpg': '' }), { now });
    assert.equal(free.isPremium, false);
    fs.rmSync(root, { recursive: true });
});

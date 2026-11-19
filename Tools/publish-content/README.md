# publish-content

Publishes articles and recipes from `App Content` straight to the app. It writes exactly what the app's old
publisher screens wrote:

- the cover, resized like the app did it (shorter side 1024 px, JPEG), under `PostImages/<author>/<id>/`
- the `Articles` or `Recipes` document
- its `FeedItems` entry
- a `creation` entry in `ResourceActivities`

## One-time setup

```bash
cd "Tools/publish-content"
npm install
gcloud auth application-default login
```

The sign-in stores your Google credentials on this Mac, so there's no key file to keep track of. Your account
needs access to the `carnivore-diet-guide` Firebase project.

## Publishing

Put each piece in its own dated folder, with the text file and one cover image:

```
App Content/Articles/2026/11/20/Surviving the Holidays…   ← the text
App Content/Articles/2026/11/20/cover.jpg                  ← the cover (.jpg, .png or .webp)
```

Then, from the repo's root:

```bash
npm --prefix Tools/publish-content run publish
```

With no folders, it picks up every folder dated today or later. It checks each one and shows what would go
live, without publishing anything. If it all looks right, add `--publish`:

```bash
npm --prefix Tools/publish-content run publish -- --publish
```

To publish particular folders, name them:

```bash
npm --prefix Tools/publish-content run publish -- "App Content/Recipes/2026/11/21" --publish
```

### When it goes live

- **A future date:** midnight local time on that day. The app hides anything dated in the future, so you
  can schedule weeks of content in one run.
- **Today:** right away.
- **A past date:** refused. Use `--now` to publish it right away, or `--date YYYY-MM-DD` to schedule it.

Running it twice is safe. Anything already published under the same title is skipped.

### Options

| Option | |
| --- | --- |
| `--publish` | Publish everything that passes the checks. |
| `--now` | Go live right away instead of on the folder's date. |
| `--date YYYY-MM-DD` | Go live on this day instead. |
| `--free` / `--premium` | Free for everyone, or Carnivore+ only. Otherwise it's Carnivore+ unless the file says `**Premium:** No`. |
| `--author ID` | Publish as a different publisher than the one in `config.json`. |
| `--offline` | Only check the files, without looking anything up in Firebase. |

## The file format

The same layout the files in `App Content` already use.

### Articles

```markdown
The Title

**Summary:**
One or two sentences, 128 characters at most.

---

**Category:** Traveling on Carnivore

---

The article, in Markdown…

https://a-source.com/…
https://another-source.com/…
```

- **Category** must match a category in the app. Separate more than one with commas. A wrong name lists the
  valid ones.
- **Citations:** links on their own lines at the very end, with or without a "Sources" heading above them.
- **Optional:** `**Premium:** No` makes the article free. `**Topic:**` lines are ignored.

### Recipes

```markdown
The Title

**Summary:**
One or two sentences, 128 characters at most.

* **Difficulty:** Easy
* **Prep Time:** 10 mins
* **Cook Time:** 1 hour 30 minutes
* **Servings:** 4

| Calories | Protein | Fat | Carbs |
| --- | --- | --- | --- |
| 480 kcal | 32g | 38g | 0g |

### Ingredients
…
```

- **Details:** everything before the Ingredients heading. Bullets, `**Key:** value` lines, and tables (across or
  down) all work.
- **Difficulty:** Easy, Medium or Hard, or Beginner, Intermediate or Advanced.
- **Ranges:** "20–25 minutes" or "6–8 servings" use the top of the range, as you picked in the app. "4 hours
  (High) or 7 hours (Low)" uses the first option. These come with a note in the check, so you can see them.
- **Nutrition:** optional. Without all four values, the recipe shows no nutrition.

## Checks

Problems that would break something in the app stop that item from publishing:

- A summary outside 12–128 characters, which the app silently hides.
- A missing category, cover, difficulty or servings.
- A date that has passed.

## Testing

```bash
npm --prefix Tools/publish-content test
```

To try a real publish without touching the live app, run it against the Firebase emulators. Set **both**
variables, or the tool refuses to run:

```bash
FIRESTORE_EMULATOR_HOST=127.0.0.1:8085 FIREBASE_STORAGE_EMULATOR_HOST=127.0.0.1:9195 \
  npm --prefix Tools/publish-content run publish -- <folder> --publish
```

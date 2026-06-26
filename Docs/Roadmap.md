# Carnivore Diet Guide — Future Release Roadmap

*Created: June 25, 2026*

---

## v3.12 — Quick Wins & Reduced Friction

Low-effort, high-impact changes. No major new features — focus on converting more users and polishing the storefront.

### App Store Listing Improvements
- **Fill promotional text** (currently 0/170 chars) — free marketing real estate, updatable without a new build.
- **Improve "What's New" text** — highlight specific content and features instead of generic "UX improvements, minor bug fixes."
- **Add a proper privacy policy URL** — currently only links to Apple's standard EULA. Needed for compliance and user trust.

### Guest Browsing
- Allow unauthenticated users to browse free articles, recipes, and the feed before requiring sign-in.
- Move the sign-in wall to actions that require identity: favoriting, commenting, posting, subscribing.
- Goal: let users see value before asking for commitment. Reduces top-of-funnel drop-off.

### Housekeeping
- Gate admin tools (seed data, featured articles management) behind a build configuration or feature flag so they aren't shipped to regular users.

---

## v4.0 — Daily Tracking & Journaling

The marquee release. Transforms the app from a content library into a daily-use tool.

### Daily Journal / Food Log
- Log meals with optional photos, notes, and tags (beef, pork, organ meat, dairy, eggs, etc.).
- Track daily wellness signals: energy level, mood, sleep quality, digestion, symptoms.
- Calendar view to browse past entries.
- Data stored in Firestore under the user's profile for cloud sync across devices.
- Premium feature (Carnivore+).

### Progress Tracker
- Log weight and body measurements (waist, chest, arms, etc.) with date stamps.
- Progress photos with side-by-side comparison view.
- Simple charts showing trends over time (weekly/monthly).
- Photos stored in Firebase Storage; measurements in Firestore.
- Premium feature (Carnivore+).

### Streak & Badge Gamification
- Surface daily journal entries as a visible streak (consecutive days logged).
- Award badges for milestones: 7-day streak, 30-day streak, 100 entries, first progress photo, etc.
- Display streak and badges on the user's profile.
- Leverages the existing `DailyUserEngagementService` check-in data.

### Release Notes
- This is the release that justifies the subscription. Market it heavily in the promotional text and What's New.
- Consider a launch discount or trial extension to drive adoption.

---

## v4.1 — Widgets & Notifications

Build on the daily tracking habit with passive touchpoints outside the app.

### Home Screen Widgets (WidgetKit)
- **Streak widget** (small) — shows current streak count and a motivational nudge.
- **Daily tip widget** (medium) — rotating carnivore tips or facts.
- **Recipe of the day widget** (medium) — featured recipe with image, deep-links into the app.
- Requires a new WidgetKit extension target and shared data via App Groups.

### Smarter Notifications
- Streak reminders — "You haven't logged today, don't break your 12-day streak!"
- New content alerts — improve the existing background sync notifications with richer content (article title, recipe image).
- Notification preferences screen in Settings (already partially exists).

---

## v4.2 — Meal Plans & Offline Access

Utility features that deepen the app's value as a daily companion.

### Interactive Meal Plans with Grocery Lists
- Curated weekly meal plans (beginner, intermediate, budget-friendly, organ-meat-focused, etc.).
- Users can swap individual meals from the recipe library.
- Auto-generated grocery list from the selected plan, with quantities aggregated.
- Grocery list supports checkboxes and sharing via the system share sheet.
- Premium feature (Carnivore+).

### Offline Reading
- Cache favorited articles and recipes for offline access using the existing `Cache` infrastructure.
- Download article images alongside text for full offline rendering.
- Visual indicator showing which content is available offline.
- Manage storage usage in Settings.

---

## v5.0 — Platform Expansion

Extend the app's reach beyond the iPhone.

### Apple Watch Companion App
- Quick meal logging — tap to log common meals from a preset list.
- Daily stats: streak, meals logged, today's mood/energy.
- Complication showing current streak count.
- Syncs with the main app via Watch Connectivity or shared CloudKit/Firestore.
- Requires a new WatchKit extension target.

### Share Extension
- System share sheet extension to save recipes or articles from Safari/other apps into the user's favorites.
- Parse URL or selected text to create a saved bookmark within the app.
- Requires a new Share Extension target and shared data via App Groups.

### Siri Shortcuts & Spotlight
- Donate user actions (view article, open recipe, log meal) to Siri Suggestions.
- Index articles and recipes for Spotlight search via `CSSearchableIndex`.
- Support Siri Shortcuts for quick logging: "Log my breakfast on Carnivore."

---

## Ongoing (Every Release)

These aren't tied to a specific version — they should happen continuously.

- **Content publishing:** Maintain weekly cadence for articles and recipes. Gaps longer than 2 weeks risk subscriber churn.
- **Test coverage:** Add ViewModel and integration tests alongside each new feature. Current coverage (11 test files, mostly utils) is too thin for the app's complexity.
- **App Store optimization:** Update keywords, screenshots, and promotional text with each major release.

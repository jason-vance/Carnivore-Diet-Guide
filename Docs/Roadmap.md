# Carnivore Diet Guide — Future Release Roadmap

*Created: June 25, 2026*

---

## v2.6 — Daily Tracking & Journaling

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

## v2.7 — Widgets & Notifications

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

## v2.8 — Meal Plans & Offline Access

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

## v2.9 — Platform Expansion

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

## Deferred — Community / User Posts

*Decision: August 3, 2026*

The Community feed and Create Post button were removed from the tab bar. The code
(`Scenes/Feed`, `Scenes/Posts`, `Scenes/PostDetail`, and the Firestore post/feed/report
repositories) is left intact but dormant.

**Why:** the feature had been untouched since September 2024 while occupying 2 of 5 tabs,
including the prime center slot. At ~0.7 downloads/day there is nowhere near the user density
for a feed to feel alive, and an empty Community tab reads as an abandoned app to a new user.
It also carried an App Review risk (no post-level reporting, no user blocking — guideline 1.2)
and a moderation burden on a health topic.

**Revisit when:** the v2.6 journal and progress tracker have shipped and there is enough DAU to
fill a feed. The right shape then is a social layer *on top of* journaling (share a streak, a
before/after photo) — content that has a built-in reason to be posted — not a standalone forum.
Before reviving it, post-level reporting and user blocking must be implemented.

---

## Ongoing (Every Release)

These aren't tied to a specific version — they should happen continuously.

- **Content publishing:** Maintain weekly cadence for articles and recipes. Gaps longer than 2 weeks risk subscriber churn.
- **Test coverage:** Add ViewModel and integration tests alongside each new feature. Current coverage (11 test files, mostly utils) is too thin for the app's complexity.
- **App Store optimization:** Update keywords, screenshots, and promotional text with each major release.

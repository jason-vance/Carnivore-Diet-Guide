# Carnivore Diet Guide 2.6 — Release Checklist

*Created: November 11, 2026*

**What's in 2.6:** guest mode (browse without an account), Google ads removed, "go premium" rows in their place, Nutrient Logger cross-promo, Community tab retired, paywall and subscription fixes, the rating prompt moved to after real reading, and iPhone Duo layout support.

## Already done

- [x] Version set to 2.6 (`MARKETING_VERSION`). The build number is assigned by Xcode Organizer at upload, as with 2.5 (expect build 49).
- [x] Anonymous sign-in enabled in Firebase (needed for guest mode).
- [x] On the iPhone Duo simulator: guest sign-in, onboarding, paywall (prices, Restore, legal links, scrolling), browsing, premium rows, favorite/comment sign-in prompts, guest Profile and Settings, returning-guest restore, and the rating prompt trigger.

## 1. Before testing

- [x] **Commit** the review-prompt change, version bump and listing drafts on `dev`.
- [ ] **Tighten Firestore write rules for guests.** Guests now hold an anonymous Firebase token, so any rule that only checks `request.auth != null` also lets a guest write through the API, even though the app never does. Require a real sign-in for writes (comments, favorites, reports, user docs, activity) and keep reads open to guests:
  ```
  function isAccountUser() {
    return request.auth != null
      && request.auth.token.firebase.sign_in_provider != 'anonymous';
  }
  ```
  Check the change in the Rules Playground with an anonymous token before publishing.
- [ ] **Archive with Xcode 27.1 or later** (27.2 is installed). Building with the 27.1+ SDK is what turns on the iPhone Duo layout. Upload to TestFlight with "Manage version and build number" on.

## 2. Test on a real device

Use the TestFlight build unless a step says otherwise.

### Guest, fresh install
- [ ] Delete the app, install, and tap **Continue as Guest** → onboarding, then the paywall, then Home loads articles.
- [ ] Onboarding welcome and before/after screens: no community claims; quotes wrap rather than cut off.
- [ ] Open free articles and recipes → they load. Premium ones → the Carnivore+ paywall.
- [ ] Tap the heart, "Sign in to comment", and Report (article "…" menu and a comment's "…") → each shows the Sign in with Apple sheet with its own message. "Not Now" closes it.
- [ ] Comments are readable as a guest.
- [ ] Profile tab → guest sign-in card and a "Get more with Carnivore+" row. Settings → Account shows only **Sign In**.
- [ ] Force-quit and reopen → still a guest, no sign-in screen.

### Guest to account (needs real Apple IDs; not tested yet)
- [ ] As a guest, sign in with an Apple ID that has **never** used the app → profile setup screen → Home. Favoriting and commenting now work.
- [ ] As a guest, sign in with an Apple ID that **already has** an account → lands in that account with its profile and favorites, no error.
- [ ] Logout → sign-in screen showing both "Continue with Apple" and "Continue as Guest".
- [ ] Delete Account (test Apple ID only) → account removed, back to the sign-in screen.

### Existing users updating from 2.5
- [ ] Install 2.5 from the App Store, sign in, then install the 2.6 TestFlight build over it → still signed in, no onboarding, profile and favorites intact.
- [ ] A 2.5 subscriber stays Carnivore+ after the update.

### Subscriptions (sandbox Apple Account in TestFlight)
- [ ] Onboarding paywall shows prices, **Restore Purchases**, renewal terms, and Terms of Use / Privacy Policy links that open.
- [ ] Buy a plan → the Apple sheet shows the 7-day free trial → becomes Carnivore+, premium content unlocks, premium rows disappear.
- [ ] Start a purchase and cancel the Apple sheet → back on the paywall, no error, nothing changes.
- [ ] Restore with no subscription → "No Subscription Found". Restore as a guest on a fresh install with an active subscription → Carnivore+ unlocks.
- [ ] Turn on Airplane Mode and open a paywall → "Subscription options couldn't be loaded" with **Try Again**; reconnect and tap it → prices appear. (This is the fix for the UK "no option to upgrade" review.)
- [ ] Enter Discount Code opens Apple's offer-code sheet.
- [ ] Within 24 hours of onboarding the main paywall shows the 75%-off prices; after that, full price.

### Upsells and cross-promo
- [ ] "Go premium" rows show on Featured, the article lists, Recipes, article and recipe detail, and Profile; each opens the paywall. They're hidden once subscribed.
- [ ] The Nutrient Logger card at the end of an article opens its App Store page.
- [ ] Firebase DebugView shows `premium_cta_tapped` (with `placement`), `nutrient_logger_promo_tapped` and the paywall screen view named `MarketingView`.
- [ ] No ad banners or "Remove these ads" buttons anywhere.

### Content and publishing
- [ ] No Community tab; the profile has no Posts count.
- [ ] Publisher/admin account: Profile shows **Create** and the create flow opens (cancel without publishing).
- [ ] Article and recipe images, citations and the nutrition panel look right.

### Rating prompt (debug build on the simulator; it never appears in TestFlight)
- [ ] Finish onboarding → **no** rating prompt.
- [ ] Quit the app, seed four earlier reads from yesterday, relaunch, open one article and go back → the prompt appears after about half a second, not while reading:
  ```
  xcrun simctl spawn booted defaults write com.jasonsapps.carnivoredietguide contentReadLog.readIds -array a b c d
  xcrun simctl spawn booted defaults write com.jasonsapps.carnivoredietguide contentReadLog.readDays -array 2026-11-10
  ```
  Delete the app afterwards to clear the seed.

### Screen sizes and appearance (simulators are fine)
- [ ] **iPhone Duo** (Xcode 27.1+): fold/unfold and rotate while reading. Nothing hides under the side status bar, and there's no dark band beside hero images.
- [ ] **iPhone SE (3rd gen)**: the onboarding paywall scrolls and every button is reachable.
- [ ] **Dark Mode**: the sign-in sheet's Apple button turns white and all text stays readable.

## 3. App Store Connect (version 2.6 draft)

- [ ] Attach the build.
- [ ] Paste **What's New** and **Promotional Text** from `Docs/Listing/AppStoreListing.md`.
- [ ] Replace the **Description** with the one in that file. It drops "Community Support", "advanced meal plans" and "ad-free browsing".
- [ ] **Screenshots**: replace any that show the Community tab, ads or the old paywall. Optionally add iPhone Duo screenshots now for the Duo badge; they become required in April 2027.
- [ ] **App Privacy**: remove the advertising data types that came from AdMob (Third-Party Advertising purposes, and Device ID if nothing else uses it). Keep what Firebase Analytics and accounts need.
- [ ] **Subscriptions**: confirm each of the 4 Carnivore+ products has a 1-week free trial, since both paywalls promise one. Check that no display name or description promises "ad-free" or community.
- [ ] **Age rating**: there's a pending App Information update; finish the questionnaire (user comments, health/medical content).
- [ ] Copyright: "2018 Jason Vance" → "2026 Jason Vance". Support URL: `http://` → `https://`.
- [ ] **App Review notes**, for example: *"No account is needed: tap Continue as Guest to browse. Favorites and comments ask the user to Sign in with Apple. Carnivore+ is offered at the end of onboarding and from the 'Unlock every premium…' rows. Content creation is limited to staff accounts."*
- [ ] Decide whether to **Reset the summary rating** on release. Recommended: the current 2.29★ comes mostly from 2019–2022 reviews of the old paid app.
- [ ] Release type: Manual (current). Phased release is optional.

## 4. Outside App Store Connect

- [ ] **AdMob**: archive the app or pause its ad units; app-ads.txt is no longer needed for this app.
- [ ] **Firebase** (optional): turn on automatic cleanup of old anonymous accounts. Mark `premium_cta_tapped`, `nutrient_logger_promo_tapped` and `review_requested` as key events if you want them in reports.
- [ ] **Roadmap**: `Docs/Roadmap.md` still calls Daily Tracking & Journaling "v2.6"; renumber it.
- [ ] After approval, merge `dev` into `main` and tag `v2.6`.

## 5. After release

- [ ] Reply to the UK review about having no way to upgrade: the paywall now shows a retry when prices can't load.
- [ ] Watch Firebase for guest-to-account sign-ins, `premium_cta_tapped` by placement, and `review_requested`.
- [ ] In Nutrient Logger's App Analytics, check Sources → App Referrer for installs coming from Carnivore Diet Guide.

## Known gaps (not blocking)

- The unit test target doesn't compile, and didn't before this release either: `ArticleTests` is missing the `citations` argument, and the test target's membership exceptions pull in app files whose dependencies it doesn't have.
- `NSMicrophoneUsageDescription` reads "one of it's libraries might". Fix the wording, or remove the key if nothing still needs it.

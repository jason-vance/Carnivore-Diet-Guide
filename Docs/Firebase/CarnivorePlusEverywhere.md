# Carnivore+ on every platform

A Carnivore+ subscription bought in any store (the App Store, Google Play or Stripe on the web) unlocks
Carnivore+ in all three apps for the same account. This is the contract the Cloud Functions, the iOS app,
the Android app and the web app all build to.

Each store stays the source of truth for its own subscriptions. The server checks each one with its store,
writes one combined answer per account, and every app reads that answer alongside its own store's.

## `Entitlements/{uid}`

Written only by the Cloud Functions. The account itself can read it, guests included (a guest's anonymous
uid), so the apps listen to it directly.

```
Entitlements/{uid}
  carnivorePlus: Entitlement          // the combined answer; what every app reads
  sources:
    stripe:     Entitlement           // each present once that store has a subscription for this account
    appStore:   Entitlement
    googlePlay: Entitlement
  updatedAt: timestamp
```

`Entitlement` keeps the shape the web already writes, with `source` widened:

| Field | Type | |
| --- | --- | --- |
| `isActive` | bool | Carnivore+ is on through this source. |
| `source` | `"stripe"` \| `"appStore"` \| `"googlePlay"` | |
| `subscriptionId` | string \| null | Stripe subscription id, App Store `originalTransactionId`, or Play `latestOrderId`. |
| `plan` | `"monthly"` \| `"yearly"` \| null | |
| `productId` | string \| null | The store's own product id (see below). |
| `status` | string \| null | The store's own status, for support. |
| `isTrial` | bool | In the free week. |
| `willRenew` | bool | False once cancelled. |
| `periodEndsAt` | timestamp \| null | When access ends unless it renews, **including any billing grace period**. |

`carnivorePlus` is the active source whose `periodEndsAt` is latest, or, with none active, the one that ended
most recently. A document with no `sources` (written before this change) is read as `sources.stripe`.

### Product ids

| Plan | App Store | Google Play and Stripe |
| --- | --- | --- |
| Monthly | `carnivorePlus499` | `carnivore_plus_monthly` |
| Yearly | `carnivorePlusYearly` | `carnivore_plus_yearly` |
| Monthly, discounted | `carnivorePlusMonthlyDiscounted` | `carnivore_plus_monthly_discounted` |
| Yearly, discounted | `carnivorePlusYearlyDiscounted` | `carnivore_plus_yearly_discounted` |

## How an app decides

Carnivore+ is on when **either**:

- the app's own store says so (StoreKit on iOS, Play Billing on Android, nothing extra on the web), **or**
- `Entitlements/{uid}.carnivorePlus.isActive` is true **and** `periodEndsAt` is null or less than one day in
  the past. The day of slack covers a late renewal notification; without the date check, a missed
  notification would leave Carnivore+ on for good.

When Carnivore+ comes from **another** platform's store, the app doesn't sell it again: the paywall and
"go premium" rows hide as for any subscriber, and the subscription screen says where it's billed and where to
manage it ("Billed through the App Store. Manage it in your iPhone's Settings." / "…through Google Play…" /
"…on carnivoredietguide.com…"). The iOS app names the website as plain text, with no link, and never as a
place to buy.

## Telling the server about store purchases

The apps report their store's subscriptions to the server, signed in or as a guest:

- after a purchase, a restore or an offer code redemption,
- whenever the store reports an update (renewal, refund, upgrade),
- at launch once auth is ready, and whenever the signed-in uid changes (signing in, upgrading a guest,
  switching accounts).

### `syncAppStoreTransactions` (callable)

```
request:  { signedTransactions: string[] }   // VerificationResult.jwsRepresentation of each current
                                               // Carnivore+ entitlement (Transaction.currentEntitlements)
response: { carnivorePlus: Entitlement | null }
```

The server verifies each JWS against Apple's root CA G3 (bundle id `com.jasonsapps.carnivoredietguide`, app id
1440700246, Production or Sandbox), ignores products that aren't Carnivore+, and records it for the caller.
An empty list changes nothing: the subscription may belong to an Apple ID on another device, and it lapses on
its own at `periodEndsAt`.

### `syncGooglePlayPurchases` (callable)

```
request:  { purchases: [{ productId: string, purchaseToken: string }] }
response: { carnivorePlus: Entitlement | null }
```

The server looks each token up with the Google Play Developer API (`purchases.subscriptionsv2.get`, package
`com.jasonsapps.carnivoredietguide`) and records it for the caller. The Android app sets
`obfuscatedAccountId` to the hex SHA-256 of the uid when it starts a purchase.

### Responses and errors

In both callables' responses, `carnivorePlus` is the combined `Entitlement` as JSON. There `periodEndsAt` is an
ISO 8601 string (`"2026-12-02T21:00:27.000Z"`) or null; in the `Entitlements/{uid}` document it stays a Firestore
timestamp. `carnivorePlus` is null when no store has a subscription for the account. The apps can ignore the
response and rely on their `Entitlements/{uid}` listener.

Errors use the callable codes: `unauthenticated` (no Firebase user), `invalid-argument` (bad request shape),
`failed-precondition` (that store's verification isn't set up on the server yet), `internal`.

### Store notifications

So that renewals, cancellations and refunds reach the other platforms even when the phone app isn't opened:

- **`appStoreNotifications`** (HTTPS): App Store Server Notifications V2, for Production and Sandbox.
- **`googlePlayNotifications`** (Pub/Sub topic `play-billing`): Play real-time developer notifications. Each
  one is looked up again with the Developer API rather than trusted as sent.

## Which account owns a store subscription

`StoreSubscriptions/{store}:{id}` maps each store subscription to the uid it was last reported from (`appStore:`
plus the `originalTransactionId`; `googlePlay:` plus the SHA-256 of the purchase token, following
`linkedPurchaseToken` on upgrades). Clients can't read or write it.

When a subscription is reported from a different uid, it **moves** to that uid, and the previous account's
entitlement is worked out again without it. On iOS and Android the store's subscription follows the Apple ID or
Google account on the device anyway; this keeps one paid subscription from unlocking several accounts on the
other platforms.

Recording a store subscription also sets `Billing/{uid}.freeTrialUsed`, so the web doesn't offer a second free
week.

## Account deletion

Deleting an account deletes `Entitlements/{uid}` and its `StoreSubscriptions` entries. As today, a store
subscription keeps billing until it's cancelled in that store, so each app's delete confirmation says so to a
subscriber ("Deleting your account doesn't cancel Carnivore+. Cancel it where you subscribed…").

## Setup outside the code

- **App Store Connect › App Information › App Store Server Notifications:** Version 2, the
  `appStoreNotifications` URL, for both Production and Sandbox.
- **Google Play:** enable the Google Play Android Developer API in the Cloud project, give the functions'
  service account access in Play Console (Users and permissions: view financial data, manage orders and
  subscriptions), create the `play-billing` Pub/Sub topic with
  `google-play-developer-notifications@system.gserviceaccount.com` as a publisher, and select it under
  Monetization setup.
- **Firestore rules:** owners can read `Entitlements/{uid}` (in `firestore.rules`).

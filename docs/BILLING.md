# In-App Purchases (Play Billing)

The app gates premium features behind a binary `isPremium` entitlement. Purchases
are handled by `lib/services/billing_service.dart` via the `in_app_purchase`
plugin, surfaced through `lib/screens/paywall_screen.dart`.

## Products to create in Play Console

Create these with the **exact** IDs below (they are hard-coded in
`BillingService`). Both grant full premium.

| Product ID | Type | Suggested price | Notes |
|---|---|---|---|
| `caiib_premium_monthly` | **Subscription** (auto-renewing, monthly base plan) | ₹99/mo | Play Console → Monetize → Subscriptions |
| `caiib_premium_lifetime` | **In-app product** (one-time, non-consumable) | ₹499 | Play Console → Monetize → In-app products |

Steps:
1. Play Console → your app → **Monetize**.
2. **Subscriptions** → Create subscription → product ID `caiib_premium_monthly`,
   add a monthly base plan, set price, activate.
3. **In-app products** → Create → product ID `caiib_premium_lifetime`, set price,
   activate.
4. Add at least one **license tester** (Setup → License testing) so you can test
   purchases without being charged.
5. Upload a build to the **internal testing** track — IAP only works for builds
   distributed through Play (not local `flutter run`/sideload).

## How it behaves
- The paywall shows two plans with **localized prices** pulled from the store
  (falls back to ₹99/mo and ₹499 if the query fails).
- "Subscribe" / "Unlock Lifetime" starts the Play purchase sheet; on success the
  app persists `isPremium` and unlocks features. "Restore" re-delivers a prior
  purchase. Errors and cancellations are surfaced via snackbars.
- JAIIB and other exams are planned to be sold separately later — add new
  product IDs + an entitlement model when that lands.

## Hardening TODO (before scaling)
Entitlement is currently trusted client-side (persisted to SharedPreferences).
Add **server-side receipt verification**: a Cloud Function that validates the
purchase token against the Google Play Developer API and writes the entitlement
to Firestore, so it can't be spoofed and syncs across devices.

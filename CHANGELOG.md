## 0.0.4
### 🐞 Bugfixes
- Converted offerings.current back to a field instead of a method, and moved currentOfferingForPlacement to the top level Purchases object.
- Fixed issue when calling isAnonymous, appUserId and syncPurchases methods.

## 0.0.3
### 🐞 Bugfixes
- Fixed an issue when parsing lifetime entitlements with null expiration date.
- Fixed an issue when pasing non-subscription purchases.
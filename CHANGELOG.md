## 0.0.5
### ✨ New Features
- Added support for setting a user ID when configuring the SDK:
```brightscript
  Purchases().configure({
      "apiKey": "roku_XXXXX",
      "userId": "my_user_id" ' optional, will use an anonymous user id if not provided
  })
```
- Added support for synchronous execution of the `isAnonymous` and `appUserId` methods.
```brightscript
  isAnonymous = Purchases().isAnonymous()
  appUserId = Purchases().appUserId()
```

### 🔄 Other Changes
- On Roku devices, all apps from the same developer share the registry space.
  - We now namespace the registry using the App ID to allow for unique configurations per app.
  - If the app was previously installed, its existing configuration will be migrated to the first app that is opened.
- Extracted Logger, Registry, and AppInfo into separate functions so they can be used alongside Configuration in both the render thread and the task thread.
- Clarified where configuration is stored: in the GlobalAA when running tests from the main thread, and in the global SceneGraph node during normal operation. Added convenient getter and setter functions.

### 🐞 Bugfixes
- Migrated all tests to use the `Purchases()` singleton directly instead of accessing the internal object.
  - This was made possible by the fix in https://github.com/lvcabral/brs-engine/issues/494.
  - During this process, a bug in `currentOfferingForPlacement` was discovered and fixed.

## 0.0.4
### 🐞 Bugfixes
- Converted offerings.current back to a field instead of a method, and moved currentOfferingForPlacement to the top level Purchases object.
- Fixed issue when calling isAnonymous, appUserId and syncPurchases methods.
- Fixed an issue with the entitlement field `willRenew`.

### 🐞 Bugfixes
- Fixed an issue when parsing lifetime entitlements with null expiration date.
- Fixed an issue when pasing non-subscription purchases.
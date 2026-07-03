# Roku SDK Architecture

This SDK is a BrightScript and SceneGraph implementation of the RevenueCat Purchases API for Roku channels. The important design constraint is that Roku apps do not behave like a single-threaded script with unrestricted APIs. SceneGraph rendering, BrightScript components, channel storage, billing, and network work all have thread and component restrictions.

For Roku platform background, start with Roku's docs for [SceneGraph threading](https://developer.roku.com/en-gb/docs/developer-program/core-concepts/threads.md), [Task nodes](https://developer.roku.com/en-gb/docs/references/scenegraph/control-nodes/task.md), [BrightScript language concepts](https://developer.roku.com/en-gb/docs/references/brightscript/language/brightscript-language-reference.md), [`roRegistrySection`](https://developer.roku.com/en-gb/docs/references/brightscript/components/roregistrysection.md), [`roUrlTransfer`](https://developer.roku.com/en-gb/docs/references/brightscript/components/rourltransfer.md), and [`roChannelStore`](https://developer.roku.com/en-gb/docs/references/brightscript/components/rochannelstore.md).

## File Layout

- `source/Purchases.brs` is the SDK entry point and implementation. It defines the `Purchases()` singleton and internal helpers for configuration, registry access, identity, API calls, billing calls, offerings, purchase posting, subscriber mapping, logging, and HTTP fetches.
- `components/purchases/PurchasesTask.xml` declares the SceneGraph `Task` interface fields: `api`, `response`, and `callbackID`.
- `components/purchases/PurchasesTask.brs` starts the task run loop, observes incoming API requests, and writes results back to callback fields.
- `source/tests/**` contains the test suite and mocks used by `brs-engine`.
- `manifest` defines compile-time constants, including `runTests=false` by default.

## Threading Model

Roku SceneGraph apps have distinct execution contexts. The main BrightScript thread starts the app. The SceneGraph render thread owns UI component code. Task nodes run asynchronous work on separate task threads.

This SDK expects app-facing calls to happen from SceneGraph components because `Purchases()` needs access to `m.global` and the active scene. Normal SDK calls should not be added to `source/main.brs`.

The public singleton creates or finds a child `PurchasesTask` node with ID `purchasesTask`. Async SDK methods write an associative array to the task's `api` field:

```brightscript
{
    method: "getOfferings",
    args: {},
    callbackID: "1"
}
```

The task run loop receives the field event, invokes the internal method, and writes the result to the callback field on the task. The render-thread side observes that field and invokes either the anonymous callback function or named callback function supplied by the caller.

## Configuration And Identity

Configuration is not stored in the registry. The SDK stores runtime configuration in:

- `GetGlobalAA().rc_purchasesConfig` during local tests, because tests run from the main thread.
- `GetGlobalAA().global.rc_purchasesConfig` during normal SceneGraph execution, because the global node is shared between component and task contexts.

Identity is persisted in the Roku registry. The registry section is namespaced with the Roku app ID:

```brightscript
sectionName = "RevenueCat_" + appInfo.GetID()
```

This avoids cross-app collisions for the same developer account. The registry helper also migrates old data from the legacy `RevenueCat` section.

If no user ID has been configured or logged in, `appUserId()` generates and stores a RevenueCat anonymous user ID using the `$RCAnonymousID:` prefix.

## Network And Billing Boundaries

RevenueCat API calls use `_InternalPurchases_fetch()`, a small wrapper around `roUrlTransfer`. It returns an object with `status`, `ok`, `headers`, `text()`, `json()`, and `xml()` helpers.

Roku billing uses `roChannelStore` through the internal `billing` object:

- `purchase()` calls `SetOrder()` and `DoOrder()`.
- `getAllPurchases()` syncs existing Roku purchases.
- `getProductsById()` reads the Roku catalog and indexes products by `code`.

Keep network and billing behavior injectable. Tests replace the real API and billing methods through `configurePurchases()`.

## Offerings Flow

`getOfferings()` fetches RevenueCat offerings, fetches the Roku catalog, and merges each RevenueCat package with its matching Roku store product. The public result has:

- `current`: the current offering, with targeting context applied when available.
- `all`: all offerings keyed by offering identifier.
- Internal placement/targeting fields used by `currentOfferingForPlacement()`.

Placement lookups should not mutate the original offerings in `all`. The SDK uses the internal `m._deepCopy()` helper before adding targeting and placement context.

## Purchase Flow

`purchase()` accepts one of these inputs:

- `{ code: "product_id" }`
- `{ product: offering.current.annual.storeProduct }`
- `{ package: offering.current.annual }`

It optionally accepts `action: "Upgrade"` or `action: "Downgrade"`.

After Roku returns a transaction, the SDK posts the receipt to RevenueCat with:

- `fetch_token` from the Roku `purchaseId`.
- `app_user_id` from the current identity manager.
- `product_id` from the Roku product code.
- Price, trial, introductory pricing, and presented offering context when available.

The public purchase result contains the raw Roku transaction and the mapped RevenueCat subscriber object.

## Subscriber Mapping

`buildSubscriber()` transforms RevenueCat subscriber JSON into the public Roku SDK model. It converts date strings to `roDateTime` and builds:

- `entitlements.active`
- `entitlements.all`
- `activeSubscriptions`
- `allPurchasedProductIds`
- `allPurchaseDatesByProduct`
- `allExpirationDatesByProduct`
- `nonSubscriptionTransactions`
- `latestExpirationDate`

Be careful with lifetime purchases and non-subscription purchases. They may not have the same fields as subscriptions.

## Local Tests

`corepack yarn tests` runs `scripts/runLocal.sh`. That script stages the channel into `out/.staging`, rewrites the staged manifest to set `runTests=true`, zips the staged channel, and runs it with `brs-engine`.

The test entry point is `source/tests/main.brs`. It sets:

```brightscript
GetGlobalAA().isRunningRevenueCatTests = true
```

In test mode, public `Purchases()` methods call the injected internal test object instead of crossing through the SceneGraph task. This lets tests exercise the public API surface while replacing network and Roku billing calls.

Use physical Roku testing for changes that depend on real SceneGraph behavior, task scheduling, `roChannelStore`, or platform APIs that `brs-engine` only approximates.

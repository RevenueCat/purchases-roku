# Agent Guidance

This repository is the RevenueCat SDK for Roku. It is small, but the runtime model is unusual if you are coming from web, mobile, or server SDKs. Read this before making code changes.

## Project Map

- `source/Purchases.brs` contains the public `Purchases()` singleton, configuration, identity, network, billing orchestration, model mapping, and most test seams.
- `components/purchases/PurchasesTask.xml` and `components/purchases/PurchasesTask.brs` define the SceneGraph `Task` used for async work.
- `source/main.brs` starts the sample channel, or runs tests when the manifest compile-time flag sets `runTests=true`.
- `source/tests/**` contains the local test suite, fixtures, mocked API/billing implementations, and the vendored `roca` test helpers.
- `scripts/runLocal.sh` stages the channel, toggles `runTests=true`, zips it, and runs it with `brs-engine`.
- `scripts/runDevice.sh` and `scripts/deploy.js` deploy to a physical Roku using `.env` values.
- `docs/architecture.md` explains the Roku/BrightScript constraints behind this structure.

## Common Commands

Use Corepack because `package.json` declares Yarn 1:

```sh
corepack yarn install --frozen-lockfile
corepack yarn tests
corepack yarn lint
corepack yarn checkFormat
corepack yarn format
```

Device testing requires a `.env` file with `ROKU_IP_ADDRESS` and `ROKU_PASSWORD`:

```sh
corepack yarn deviceTests
corepack yarn device
```

If lint or format checks fail before your change, report the exact pre-existing failures instead of mixing broad cleanup into an unrelated patch.

## Roku Runtime Rules

- Public SDK calls are intended for SceneGraph component code. Do not move normal SDK usage into `source/main.brs` or into arbitrary task components.
- Blocking or platform operations such as network requests and `roChannelStore` billing must stay behind the `PurchasesTask` flow or test doubles.
- The render thread and task thread communicate through SceneGraph node fields. Preserve the `api` field request path and callback-field response path unless you are intentionally redesigning threading.
- `m.global` is available in SceneGraph components, while tests run from the main thread. Keep `_InternalPurchases_GetPurchasesConfig()` and `_InternalPurchases_SetPurchasesConfig()` behavior compatible with both modes.

## BrightScript Notes

- `invalid` is the null-like value. Check it explicitly before indexing nested associative arrays.
- Associative arrays and arrays are mutable. Use `_deepCopy()` when adding targeting context to offerings that should not mutate the original object.
- Callback APIs support both anonymous functions and callback function names. Preserve both `roFunction`/`Function` and `roString`/`String` paths.
- BrightScript identifiers are easy to shadow in surprising ways. Be careful when renaming parameters or local variables, especially near scoped functions.
- Date values exposed by the SDK are `roDateTime` objects created from RevenueCat ISO 8601 strings.
- Use `1000&` style long-integer literals where large millisecond timestamps could overflow an integer.

## RevenueCat SDK Behavior To Preserve

- `Purchases()` is a singleton stored on `GetGlobalAA().rc_purchasesSingleton`.
- Configuration stores the API key and optional proxy/log settings outside the registry; identity persists in the registry.
- Registry storage is namespaced as `RevenueCat_` plus the Roku app ID. Keep legacy migration from the old `RevenueCat` section.
- `logIn` and `logOut` call RevenueCat identify endpoints and update the stored app user ID.
- `getOfferings` merges RevenueCat offerings with Roku catalog products from `roChannelStore`.
- Purchases can be made by `code`, `product`, or `package`, and package purchases may carry presented offering, placement, and targeting context to the receipt endpoint.
- Subscriber/customer info returned from RevenueCat is mapped to the public Roku SDK shape in `buildSubscriber`.

## Testing Guidance

- Local tests run with `brs-engine`; they do not exercise full SceneGraph rendering or real Roku billing.
- Test mode sets `GetGlobalAA().isRunningRevenueCatTests = true` and routes public `Purchases()` calls to `GetGlobalAA().rc_internalTestPurchases`.
- Prefer adding focused tests in the matching file under `source/tests`.
- Use `configurePurchases()` to inject mocked API or billing behavior.
- Use real device tests for changes involving `roChannelStore`, Task behavior, SceneGraph threading, or anything that `brs-engine` cannot faithfully simulate.

## Documentation Guidance

- Keep README examples focused on SDK consumers.
- Put contributor/runtime explanations in `docs/architecture.md` or this file.
- Avoid generic AI-assistant instructions. This file should document repo-specific constraints that prevent plausible but wrong changes.

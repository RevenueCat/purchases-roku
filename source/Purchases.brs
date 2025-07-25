function Purchases() as object
    if GetGlobalAA().rc_purchasesSingleton = invalid then
        task = invalid
        if GetGlobalAA().isRunningRevenueCatTests = invalid
            globalAA = GetGlobalAA().global
            if globalAA = invalid then
                throw "The RevenueCat SDK can only be called from SceneGraph components where the m.global object is available."
            end if

            task = globalAA.getScene().findNode("purchasesTask")
            if task = invalid then
                task = globalAA.getScene().createChild("PurchasesTask")
                task.id = "purchasesTask"
                ' The global AA is a SceneGraph node, need to manually add the field
                globalAA.addFields({ rc_purchasesConfig: {} })
            end if
        end if
        m.context = {}

        appInfo = _InternalPurchases_AppInfo()
        sectionName = "RevenueCat_" + appInfo.GetID()
        registry = _InternalPurchases_Registry(sectionName)
        configuration = _InternalPurchases_Configuration({ registry: registry })
        identityManager = _InternalPurchases_IdentityManager({ registry: registry })

        GetGlobalAA().rc_purchasesSingleton = {
            purchase: sub(inputArgs = {} as object, callbackFunc = invalid as dynamic)
                m._internal.invoke("purchase", inputArgs, callbackFunc)
            end sub,
            syncPurchases: sub(callbackFunc = invalid as dynamic)
                m._internal.invoke("syncPurchases", {}, callbackFunc)
            end sub,
            configure: sub(inputArgs = {} as object)
                m._internal.configuration.configure(inputArgs)
            end sub,
            isConfigured: function() as boolean
                return m._internal.configuration.isConfigured()
            end function,
            setProxyURL: sub(proxyURL as string)
                m._internal.configuration.set({ proxyUrl: proxyURL })
            end sub,
            proxyURL: function() as object
                return m._internal.configuration.get().proxyUrl
            end function,
            setLogLevel: sub(logLevel as string)
                m._internal.configuration.set({ logLevel: logLevel })
            end sub,
            logLevel: function() as string
                return _PurchasesLogger().logLevelString()
            end function,
            isAnonymous: sub(callbackFunc = invalid as dynamic) as object
                isAnonymous = m._internal.identityManager.isAnonymous()
                if callbackFunc <> invalid then
                    callbackFunc(isAnonymous, invalid)
                end if
                return isAnonymous
            end sub,
            appUserId: sub(callbackFunc = invalid as dynamic) as object
                appUserId = m._internal.identityManager.appUserId()
                if callbackFunc <> invalid then
                    callbackFunc(appUserId, invalid)
                end if
                return appUserId
            end sub,
            logIn: sub(inputArgs = {} as object, callbackFunc = invalid as dynamic)
                m._internal.invoke("logIn", inputArgs, callbackFunc)
            end sub,
            logOut: sub(callbackFunc = invalid as dynamic)
                m._internal.invoke("logOut", {}, callbackFunc)
            end sub,
            getCustomerInfo: sub(callbackFunc = invalid as dynamic)
                m._internal.invoke("getCustomerInfo", {}, callbackFunc)
            end sub,
            setAttributes: sub(inputArgs = {} as object, callbackFunc = invalid as dynamic)
                m._internal.invoke("setAttributes", inputArgs, callbackFunc)
            end sub,
            getOfferings: sub(callbackFunc = invalid as dynamic)
                m._internal.invoke("getOfferings", {}, callbackFunc)
            end sub,
            currentOfferingForPlacement: sub(inputArgs = {} as object, callbackFunc = invalid as dynamic)
                m._internal.invoke("currentOfferingForPlacement", inputArgs, callbackFunc)
            end sub,
            _internal: {
                configuration: configuration,
                identityManager: identityManager,
                callbackContext: m.context,
                setCallbackID: function(callbackFunc as dynamic) as string
                    m.task.callbackID++
                    if (m.task.callbackID >= 100000) then
                        m.task.callbackID = 1
                    end if
                    callbackID = m.task.callbackID.tostr()
                    m.task.addField(callbackID, "assocarray", false)
                    valueType = type(callbackFunc)
                    if valueType = "roFunction" or valueType = "Function" then
                        m.task.observeField(callbackID, "_InternalPurchases_invokeCallbackFunction")
                        m.callbackContext[callbackID] = callbackFunc
                    else if valueType = "roString" or valueType = "String" then
                        m.task.observeField(callbackID, callbackFunc)
                    else
                        m.task.observeField(callbackID, "")
                    end if
                    return callbackID
                end function,
                invoke: function(name as string, inputArgs = {}, callbackFunc = invalid as dynamic)
                    if GetGlobalAA().isRunningRevenueCatTests <> invalid
                        if GetGlobalAA().rc_internalTestPurchases = invalid then
                            throw "Purchases SDK not configured for testing"
                        end if
                        result = GetGlobalAA().rc_internalTestPurchases[name](inputArgs)
                        valueType = type(callbackFunc)
                        if valueType = "roFunction" or valueType = "Function" then
                            callbackFunc(result.data, result.error)
                        else if valueType = "roString" or valueType = "String" then
                            m[callbackFunc](result.data, result.error)
                        end if
                    else
                        m.task["api"] = {
                            method: name,
                            args: inputArgs,
                            callbackID: m.setCallbackID(callbackFunc),
                        }
                    end if
                end function
                task: task,
            }
        }
    end if
    return GetGlobalAA().rc_purchasesSingleton
end function

function _InternalPurchases_GetPurchasesConfig() as object
    config = invalid
    if GetGlobalAA().isRunningRevenueCatTests <> invalid then
        ' Tests are always run from the main thread so we can use the global AA
        config = GetGlobalAA().rc_purchasesConfig
    else
        ' When running from a SceneGraph component, use the global node to share config between task and SDK
        config = GetGlobalAA().global.rc_purchasesConfig
    end if
    if config = invalid then return {}
    return config
end function

function _InternalPurchases_SetPurchasesConfig(config as object) as void
    if GetGlobalAA().isRunningRevenueCatTests <> invalid then
        GetGlobalAA().rc_purchasesConfig = config
    else
        GetGlobalAA().global.rc_purchasesConfig = config
    end if
end function

sub _InternalPurchases_invokeCallbackFunction(e as object)
    data = e.getData()
    m.context[e.getField()](data.data, data.error)
end sub

function _InternalPurchases_Configuration(o = {} as object) as object
    return {
        _registry: o.registry,
        get: function() as object
            return _InternalPurchases_GetPurchasesConfig()
        end function,
        configure: function(config as object) as object
            if config.apiKey = invalid then
                _PurchasesLogger().error("Missing apiKey in configuration")
            end if
            if config.userId <> invalid and config.userId <> ""
                valueType = type(config.userId)
                if valueType = "roString" or valueType = "String" then
                    m._registry.setUserId(config.userId)
                else
                    _PurchasesLogger().error("Invalid userId in configuration")
                end if
            end if
            m.set(config)
        end function,
        set: function(config as object) as void
            _InternalPurchases_SetPurchasesConfig({
                apiKey: config.apiKey,
                logLevel: config.logLevel,
                proxyUrl: config.proxyUrl,
            })
        end function,
        assert: function() as void
            if m.get().apiKey = invalid then
                throw "Purchases SDK not configured"
            end if
        end function,
        isConfigured: function() as boolean
            if m.get().apiKey = invalid then return false
            return true
        end function,
    }
end function

function _PurchasesLogger() as object
    if GetGlobalAA().rc_logger = invalid then
        GetGlobalAA().rc_logger = {
        logLevel: function() as integer
            level = _InternalPurchases_GetPurchasesConfig().logLevel
            if level <> invalid and m.levels[level] <> invalid then return m.levels[level]
            return m.levels.info
        end function,
        logLevelString: function() as string
            level = m.logLevel()
            for each key in m.levels
                if m.levels[key] = level then return key
            end for
            return "info"
        end function,
        levels: {
            error: 3,
            warn: 2,
            info: 1,
            debug: 0,
        }
        error: function(message) as void
            if m.logLevel() > m.levels.error then return
            print("😿‼️  Error: " + m.convertToString(message))
        end function,
        info: function(message) as void
            if m.logLevel() > m.levels.info then return
            print("ℹ️  Info: " + m.convertToString(message))
        end function,
        warn: function(message) as void
            if m.logLevel() > m.levels.warn then return
            print("⚠️  Warning: " + message)m.convertToString(message)
        end function,
        debug: function(message) as void
            if m.logLevel() > m.levels.debug then return
            print("🐞 Debug: " + m.convertToString(message))
        end function,
        convertToString: function(message) as string
            if type(message) = "roString" or type(message) = "String" then return message
            return FormatJson(message)
        end function,
        }
    end if
    return GetGlobalAA().rc_logger
end function

function _InternalPurchases_AppInfo(o = {} as object) as object
    return {
        appInfo: CreateObject("roAppInfo")
        GetID: function()
        return m.appInfo.GetID()
        end function,
        IsDev: function()
            return m.appInfo.IsDev()
        end function,
        GetVersion: function()
            return m.appInfo.GetVersion()
        end function,
        GetTitle: function()
            return m.appInfo.GetTitle()
        end function,
        GetDevID: function()
            return m.appInfo.GetDevID()
        end function,
    }
end function

function _InternalPurchases_Registry(sectionName) as object
    return {
        sectionName: sectionName,
        set: function(newEntries as object) as void
            entries = m.get()
            if entries <> invalid
                for each key in newEntries
                    entries[key] = newEntries[key]
                end for
            end if
            section = createObject("roRegistrySection", m.sectionName)
            section.write("Storage", formatJson(entries))
            section.flush()
        end function,
        get: function() as object
            section = createObject("roRegistrySection", m.sectionName)
            if section.exists("Storage") = false then return {}
            try
                entries = parseJson(section.read("Storage"))
            catch e
                _PurchasesLogger().error("Failed to read registry:" + e.message)
            end try
            if type(entries) <> "roAssociativeArray" then return {}
            return entries
        end function,
        clear: function() as void
            section = createObject("roRegistrySection", m.sectionName)
            section.delete("Storage")
        end function,
        migrateLegacyData: function() as void
            legacySection = createObject("roRegistrySection", "RevenueCat")
            if legacySection.exists("Storage") then
                try
                    legacyEntries = parseJson(legacySection.read("Storage"))
                catch e
                end try

                if type(legacyEntries) = "roAssociativeArray" then
                    section = createObject("roRegistrySection", m.sectionName)
                    section.write("Storage", formatJson(legacyEntries))
                    section.flush()
                    legacySection.delete("Storage")
                end if
            end if
        end function,
        setUserId: function(userId as string) as void
            m.set({ userId: userId })
        end function,
    }
end function

function _InternalPurchases_IdentityManager(o = {} as object) as object
    return  {
        registry: o.registry,
        setUserId: function(userId as string) as void
            m.registry.setUserId(userId)
        end function,
        appUserId: function() as string
            entries = m.registry.get()
            if entries <> invalid and entries.userId <> invalid then return entries.userId
            anonUserID = m.generateAnonUserId()
            m.registry.setUserId(anonUserID)
            return anonUserID
        end function,
        isAnonymous: function() as boolean
            return m.appUserId().startsWith("$RCAnonymousID:")
        end function,
        generateAnonUserId: function() as string
            r = CreateObject("roRegex", "-", "i")
            uuid = r.ReplaceAll(LCase(createObject("roDeviceInfo").getRandomUUID()), "")
            return "$RCAnonymousID:" + uuid
        end function,
    }
end function

function _InternalPurchases(o = {} as object) as object
    ERRORS = {
        purchaseInvalidError: {
            message: "One or more of the arguments provided are invalid."
            code: 4
            codeName: "PURCHASE_INVALID"
        },
        invalidAppUserIdError: {
            message: "The app user id is not valid."
            code: 14
            codeName: "INVALID_APP_USER_ID"
        },
        invalidSubscriberAttributesError: {
            message: "One or more of the attributes sent could not be saved."
            code: 21
            codeName: "INVALID_SUBSCRIBER_ATTRIBUTES"
        },
        configurationError: {
            message: "There is an issue with your configuration."
            code: 23
            codeName: "CONFIGURATION_ERROR"
        }
    }

    STRINGS = {
        FAILED_TO_FETCH_PRODUCTS: "Failed to fetch products from the Roku store. This can happen if billing testing is not correctly configured or a Beta Channel expired. Please review the 'How to setup a channel' section of the README."
    }

    appInfo = _InternalPurchases_AppInfo()
    sectionName = "RevenueCat_" + appInfo.GetID()
    registry = _InternalPurchases_Registry(sectionName)
    registry.migrateLegacyData()
    configuration = _InternalPurchases_Configuration({ registry: registry })

    billing = {
        logStoreEvent: function(event as object) as void
            if event.isRequestSucceeded() then
                _PurchasesLogger().debug("Store Request success")
                _PurchasesLogger().debug(event.GetResponse())
            else if event.isRequestFailed() then
                _PurchasesLogger().debug("Store Request failure")
                _PurchasesLogger().debug(event.GetStatus())
                _PurchasesLogger().debug(event.GetStatusMessage())
            else if event.isRequestInterrupted() then
                _PurchasesLogger().debug("Store Request interrupted")
                _PurchasesLogger().debug(event.GetStatus())
                _PurchasesLogger().debug(event.GetStatusMessage())
            end if
        end function
        purchase: function(inputArgs = {}) as object
            port = CreateObject("roMessagePort")
            store = CreateObject("roChannelStore")
            store.SetMessagePort(port)
            store.SetOrder([{ code: inputArgs.code, qty: 1 }], { action: inputArgs.action })
            store.DoOrder()
            msg = wait(0, port)
            if (type(msg) = "roChannelStoreEvent")
                m.logStoreEvent(msg)
            end if

            if msg.isRequestSucceeded() then
                return { data: msg.GetResponse() }
            else if msg.isRequestFailed() then
                return {
                    error: {
                        code: msg.GetStatus(),
                        message: msg.GetStatusMessage(),
                    }
                }
            else if msg.isRequestInterrupted() then
                return {
                    error: {
                        code: msg.GetStatus(),
                        message: msg.GetStatusMessage(),
                    }
                }
            end if
        end function,
        getAllPurchases: function() as object
            port = CreateObject("roMessagePort")
            store = CreateObject("roChannelStore")
            store.SetMessagePort(port)
            store.GetAllPurchases()
            msg = wait(0, port)
            if (type(msg) = "roChannelStoreEvent")
                m.logStoreEvent(msg)
            end if
            if msg.isRequestSucceeded() then
                return { data: msg.GetResponse() }
            else if msg.isRequestFailed() then
                return {
                    error: {
                        code: msg.GetStatus(),
                        message: msg.GetStatusMessage(),
                    }
                }
            else if msg.isRequestInterrupted() then
                return {
                    error: {
                        code: msg.GetStatus(),
                        message: msg.GetStatusMessage(),
                    }
                }
            end if
        end function,
        getProductsById: function() as object
            port = CreateObject("roMessagePort")
            store = CreateObject("roChannelStore")
            store.SetMessagePort(port)
            store.GetCatalog()
            msg = wait(0, port)
            if (type(msg) = "roChannelStoreEvent")
                m.logStoreEvent(msg)
            end if
            if msg.isRequestSucceeded() then
                products = msg.GetResponse()
                productsByID = {}
                for each product in products
                    productsByID[product.code] = product
                end for
                return { data: productsByID }
            else if msg.isRequestFailed() then
                return {
                    error: {
                        code: msg.GetStatus(),
                        message: msg.GetStatusMessage(),
                    }
                }
            else if msg.isRequestInterrupted() then
                return {
                    error: {
                        code: msg.GetStatus(),
                        message: msg.GetStatusMessage(),
                    }
                }
            end if
        end function,
    }
    if o.billing <> invalid then
        billing = o.billing
    end if

    identityManager = _InternalPurchases_IdentityManager({ registry: registry })

    deviceInfo = {
        deviceInfo: CreateObject("roDeviceInfo")
        GetUserCountryCode: function()
            return m.deviceInfo.GetUserCountryCode()
        end function,
        GetCurrentLocale: function()
            return m.deviceInfo.GetCurrentLocale()
        end function,
        GetCountryCode: function()
            return m.deviceInfo.GetCountryCode()
        end function,
        GetOSVersion: function()
            v = m.deviceInfo.GetOSVersion()
            return v.major + "." + v.minor + "." + v.revision
        end function,
    }
    if o.deviceInfo <> invalid then
        deviceInfo = o.deviceInfo
    end if

    api = {
        appInfo: appInfo,
        deviceInfo: deviceInfo,
        identityManager: identityManager,
        _defaultHeaders: {
            "X-Platform-Flavor": "native",
            "X-Platform": "roku",
            "X-Client-Bundle-ID": appInfo.GetID(),
            "X-Client-Version": appInfo.GetVersion(),
            "X-Version": "0.0.2",
            "X-Platform-Version": deviceInfo.GetOSVersion(),
            "X-Storefront": deviceInfo.GetCountryCode(),
            "X-Is-Sandbox": appInfo.IsDev().ToStr(),
        }
        configuration: configuration,
        headers: function() as object
            headers = {
                "Authorization": "Bearer " + m.configuration.get().apiKey,
                "Content-Type": "application/json",
            }
            headers.Append(m._defaultHeaders)
            return headers
        end function,
        getBaseUrl: function() as string
            proxyUrl = m.configuration.get().proxyUrl
            if proxyUrl <> invalid then return proxyUrl
            return "https://api.revenuecat.com/v1/"
        end function,
        urls: function() as object
            return {
                getCustomerInfo: m.getBaseUrl() + "subscribers/" + m.identityManager.appUserId(),
                getOfferings: m.getBaseUrl() + "subscribers/" + m.identityManager.appUserId() + "/offerings"
                postSubscriberAttributes: m.getBaseUrl() + "subscribers/" +  m.identityManager.appUserId() + "/attributes",
                identify: m.getBaseUrl() + "subscribers/identify",
                postReceipt: m.getBaseUrl() + "receipts",
            }
        end function,
        getOfferings: function(inputArgs = {}) as object
            result = _InternalPurchases_fetch({
                url: m.urls().getOfferings,
                headers: m.headers(),
                method: "GET"
            })
            if result.ok
                return {
                    data: result.json()
                }
            else
                return {
                    error: result.json()
                }
            end if
        end function,
        identify: function(inputArgs = {}) as object
            result = _InternalPurchases_fetch({
                url: m.urls().identify,
                headers: m.headers(),
                method: "POST",
                body: FormatJson({
                    "app_user_id": inputArgs.userId,
                    "new_app_user_id": inputArgs.newUserId,
                })
            })
            if result.ok
                return {
                    data: result.json()
                }
            else
                return {
                    error: result.json()
                }
            end if
        end function,
        getCustomerInfo: function(inputArgs = {}) as object
            result = _InternalPurchases_fetch({
                url: m.urls().getCustomerInfo,
                headers: m.headers(),
                method: "GET"
            })
            if result.ok
                return {
                    data: result.json()
                }
            else
                return {
                    error: result.json()
                }
            end if
        end function,
        postSubscriberAttributes: function(inputArgs = {}) as object
            attributes = {}
            for each attribute in inputArgs.attributes.Items()
                key = attribute.key
                value = attribute.value
                attributes[key] = {
                    ' The & here casts the Integer to LongInteger so it can handle larger numbers like timestamps in milliseconds without overflowing
                    ' https://developer.roku.com/docs/references/brightscript/language/expressions-variables-types.md#numeric-literals
                    "updated_at_ms": CreateObject("roDateTime").AsSeconds() * 1000&,
                    "value": value
                }
            end for
            result = _InternalPurchases_fetch({
                url: m.urls().postSubscriberAttributes,
                headers: m.headers(),
                method: "POST",
                body: FormatJson({
                    "attributes": attributes
                })
            })
            if result.ok
                return {
                    data: result.json()
                }
            else
                return {
                    error: result.json()
                }
            end if
        end function,
        postReceipt: function(inputArgs = {}) as object
            transaction = inputArgs.transaction
            app_user_id = inputArgs.userId
            presentedOfferingIdentifier = invalid
            presentedPlacementIdentifier = invalid
            appliedTargetingRule = invalid
            if inputArgs.presentedOfferingContext <> invalid
                presentedOfferingIdentifier = inputArgs.presentedOfferingContext.offeringIdentifier
                presentedPlacementIdentifier = inputArgs.presentedOfferingContext.placementIdentifier
                appliedTargetingRule = inputArgs.presentedOfferingContext.targetingRule
            end if

            introductory_duration = invalid
            introductory_price = invalid
            if transaction.trialQuantity <> invalid and transaction.trialQuantity > 0
                introductory_duration = transaction.trialQuantity.ToStr() + " " + transaction.trialType
                introductory_price = transaction.trialCost
            end if

            free_trial_duration = invalid
            if transaction.freeTrialQuantity <> invalid and transaction.freeTrialQuantity > 0
                free_trial_duration = transaction.freeTrialQuantity.ToStr() + " " + transaction.freeTrialType
            end if

            price = transaction.total
            if price = invalid
                price = transaction.cost
            end if

            result = _InternalPurchases_fetch({
                url: m.urls().postReceipt,
                headers: m.headers(),
                method: "POST",
                body: FormatJson({
                    fetch_token: transaction.purchaseId,
                    app_user_id: app_user_id,
                    product_id: transaction.code,
                    price: price,
                    intro_duration: introductory_duration,
                    trial_duration: free_trial_duration,
                    introductory_price: introductory_price,
                    presented_offering_identifier: presentedOfferingIdentifier,
                    presented_placement_identifier: presentedPlacementIdentifier,
                    applied_targeting_rule: appliedTargetingRule,
                })
            })
            if result.ok
                return {
                    data: result.json()
                }
            else
                return {
                    error: result.json()
                }
            end if
        end function,
    }
    if o.api <> invalid then
        api = o.api
    end if

    return {
        errors: ERRORS,
        strings: STRINGS,
        billing: billing,
        api: api,
        registry: registry,
        configuration: configuration,
        identityManager: identityManager,
        logIn: function(userId as string) as object
            m.configuration.assert()
            if userId = invalid or userId = ""
                _PurchasesLogger().error("Missing userId in logIn")
                return {
                    error: m.errors.invalidAppUserIdError
                }
            end if
            valueType = type(userId)
            if valueType <> "roString" and valueType <> "String" then
                _PurchasesLogger().error("Invalid userId in logIn")
                return {
                    error: m.errors.invalidAppUserIdError
                }
            end if
            currentUserID = m.identityManager.appUserId()
            if userId = currentUserID
                _PurchasesLogger().info("User already logged in")
                return m.getCustomerInfo()
            end if
            m.identityManager.setUserId(userId)
            result = m.api.identify({
                userId: currentUserID
                newUserId: userId
            })
            if result.error <> invalid
                return result
            end if
            return { data: m.buildSubscriber(result.data) }
        end function,
        logOut: function(inputArgs = {}) as object
            m.configuration.assert()
            currentUserID = m.identityManager.appUserId()
            anonUserID = m.identityManager.generateAnonUserID()
            m.identityManager.setUserId(anonUserID)
            result = m.api.identify({
                userId: currentUserID
                newUserId: anonUserID
            })
            if result.error <> invalid
                return result
            end if
            return { data: m.buildSubscriber(result.data) }
        end function,
        getCustomerInfo: function(inputArgs = {}) as object
            m.configuration.assert()
            result = m.api.getCustomerInfo({ userId: m.identityManager.appUserId() })
            if result.error <> invalid
                return result
            end if
            return { data: m.buildSubscriber(result.data) }
        end function,
        setAttributes: function(inputArgs = {}) as object
            m.configuration.assert()

            for each entry in inputArgs.Items()
                if (type(entry.key) <> "roString" and type(entry.key) <> "String") or (type(entry.value) <> "roString" and type(entry.value) <> "String")
                    return {
                        error: m.errors.invalidSubscriberAttributesError
                    }
                end if
            end for

            result = m.api.postSubscriberAttributes({ userId: m.identityManager.appUserId(), attributes: inputArgs })
            if result.error <> invalid
                return result
            end if
            return { data: true }
        end function,
        purchase: function(inputArgs = {}) as object
            m.configuration.assert()
            code = ""
            action = ""
            if inputArgs.action <> invalid
                if inputArgs.action <> "Upgrade" and inputArgs.action <> "Downgrade"
                    _PurchasesLogger().error("Ivalid action in purchase")
                    return {
                        error: m.errors.purchaseInvalidError
                    }
                end if
                action = inputArgs.action
            end if
            presentedOfferingContext = invalid
            if inputArgs.code <> invalid
                code = inputArgs.code
            else if inputArgs.package <> invalid and inputArgs.package.storeProduct <> invalid and inputArgs.package.storeProduct.code <> invalid
                code = inputArgs.package.storeProduct.code
                if inputArgs.package.presentedOfferingContext <> invalid
                    presentedOfferingContext = inputArgs.package.presentedOfferingContext
                end if
            else if inputArgs.product <> invalid and inputArgs.product.code <> invalid
                code = inputArgs.product.code
            end if
            if code = "" then
                _PurchasesLogger().error("Ivalid product identifier in purchase")
                return {
                    error: m.errors.purchaseInvalidError
                }
            end if
            result = m.billing.purchase({ code: code, action: action })

            if result.error <> invalid
                if result.error.code = 2
                    result.data = { userCancelled: true }
                end if
                return result
            end if

            transactions = result.data

            result = m.api.postReceipt({
                userId: m.identityManager.appUserId(),
                transaction: transactions[0],
                presentedOfferingContext: presentedOfferingContext,
            })
            if result.error <> invalid
                return result
            end if
            return {
                data: {
                    transaction: transactions[0],
                    subscriber: m.buildSubscriber(result.data)
                }
            }
        end function,
        syncPurchases: function(inputArgs = {}) as object
            m.configuration.assert()
            result = m.billing.getAllPurchases()
            if result.error <> invalid
                return result
            end if
            allPurchases = result.data
            for each purchase in allPurchases
                result = m.api.postReceipt({
                    userId: m.identityManager.appUserId(),
                    transaction: purchase,
                })
                if result.error <> invalid
                    return result
                end if
            end for
            return m.getCustomerInfo()
        end function,
        getOfferings: function(inputArgs = {}) as object
            m.configuration.assert()
            result = m.api.getOfferings({ userId: m.identityManager.appUserId() })
            if result.error <> invalid
                return result
            end if
            offerings = result.data
            all_offerings = {}
            result = m.billing.getProductsById()

            if result.error <> invalid
                return result
            end if

            productsByID = result.data

            if productsByID.Count() = 3 and (productsByID["PROD1"] <> invalid or productsByID["PROD2"] <> invalid or productsByID["FAILPROD"] <> invalid)
                _PurchasesLogger().error(m.strings.FAILED_TO_FETCH_PRODUCTS)
            end if

            for each offering in offerings.offerings
                annual = invalid
                monthly = invalid
                availablePackages = []
                presentedOfferingContext = {
                    offeringIdentifier: offering.identifier,
                }
                for each package in offering.packages
                    product = productsByID[package.platform_product_identifier]
                    if product = invalid then continue for
                    if package.identifier = "$rc_annual"
                        annual = {
                            identifier: package.identifier,
                            packageType: "annual",
                            presentedOfferingContext: presentedOfferingContext,
                            storeProduct: productsByID[package.platform_product_identifier],
                        }
                        availablePackages.push(annual)
                    else if package.identifier = "$rc_monthly"
                        monthly = {
                            identifier: package.identifier,
                            packageType: "monthly",
                            presentedOfferingContext: presentedOfferingContext,
                            storeProduct: productsByID[package.platform_product_identifier],
                        }
                        availablePackages.push(monthly)
                    else
                        availablePackages.push({
                            identifier: package.identifier,
                            packageType: "custom",
                            presentedOfferingContext: presentedOfferingContext,
                            storeProduct: productsByID[package.platform_product_identifier],
                        })
                    end if
                end for
                o = {
                    identifier: offering.identifier,
                    metadata: offering.metadata,
                    description: offering.description,
                    annual: annual,
                    monthly: monthly,
                    availablePackages: availablePackages,
                }
                all_offerings[offering.identifier] = o
            end for

            ' Find the current offering and make a copy of it with targeting information
            current = invalid
            if offerings.current_offering_id <> invalid
                currentOffering = all_offerings[offerings.current_offering_id]
                if currentOffering <> invalid
                    current = m._offeringWithTargeting({
                        offering: currentOffering,
                        targetingRule: offerings.targeting
                    })
                end if
            end if

            return {
                data: {
                    current: current,
                    all: all_offerings,
                    _placements: offerings.placements,
                    _targeting: offerings.targeting,
                }
            }
        end function,
        currentOfferingForPlacement: sub(inputArgs = {}) as object
            offerings = inputArgs.offerings
            placement_id = inputArgs.placementId

            if offerings = invalid then return { data: invalid }
            if placement_id = invalid then return { data: invalid }

            if offerings._placements = invalid then return { data: invalid }
            if offerings._placements.offering_ids_by_placement = invalid then return { data: invalid }
            placement_offering_id = offerings._placements.offering_ids_by_placement[placement_id]
            offering = invalid
            if placement_offering_id <> invalid
                offering = offerings.all[placement_offering_id]
                ' if the placement exists but we could not find its offering, return the fallback offering
                if offering = invalid
                    fallback_offering_id = offerings._placements.fallback_offering_id
                    if fallback_offering_id <> invalid
                        fallback_offering = offerings.all[fallback_offering_id]
                        if fallback_offering <> invalid
                            offering = fallback_offering
                        end if
                    end if
                end if
            end if
            return {
                data: m._offeringWithTargeting({
                    offering: offering,
                    placementIdentifier: placement_id
                    targetingRule: offerings._targeting
                })
            }
        end sub,
        _deepCopy: function(original as Object) as Object
            if original = invalid then
                return invalid
            end if
            if type(original) <> "roAssociativeArray" and type(original) <> "roArray"
                return original
            end if
            if type(original) = "roAssociativeArray"
                copy = {}
                for each key in original
                    value = original[key]
                    copy[key] = m._deepCopy(value)
                end for
                return copy
            end if
            if type(original) = "roArray"
                copy = []
                for each value in original
                    copy.push(m._deepCopy(value))
                end for
                return copy
            end if
            return original
        end function,
        _offeringWithTargeting: sub(inputArgs = {}) as object
            offering = m._deepCopy(inputArgs.offering)
            if offering = invalid then return invalid
            for each package in offering.availablePackages
                package.presentedOfferingContext["targetingRule"] = inputArgs.targetingRule
                package.presentedOfferingContext["placementIdentifier"] = inputArgs.placementIdentifier
            end for
            if offering.annual <> invalid
                offering.annual.presentedOfferingContext["targetingRule"] = inputArgs.targetingRule
                offering.annual.presentedOfferingContext["placementIdentifier"] = inputArgs.placementIdentifier
            end if
            if offering.monthly <> invalid
                offering.monthly.presentedOfferingContext["targetingRule"] = inputArgs.targetingRule
                offering.monthly.presentedOfferingContext["placementIdentifier"] = inputArgs.placementIdentifier
            end if
            return offering
        end sub,
        buildDateFromString: function(dateString)
            if dateString = invalid then return invalid
            date = CreateObject("roDateTime")
            date.FromISO8601String(dateString)
            return date
        end function,
        buildProductId: function(productId, purchase) as string
            if purchase.product_plan_identifier <> invalid
                return productId + ":" + purchase.product_plan_identifier
            end if
            return productId
        end function
        willRenew: function(purchase) as boolean
            isPromo = purchase.store = "promotional"
            isLifetime = purchase.expires_date = invalid
            hasUnsubscribed = purchase.unsubscribe_detected_at <> invalid
            hasBillingIssues = purchase.billing_issue_detected_at <> invalid
            return (isPromo or isLifetime or hasUnsubscribed or hasBillingIssues) = false
        end function,
        isActive: function(entitlement, requestDate) as boolean
            expirationDate = m.buildDateFromString(entitlement.expires_date)
            if expirationDate = invalid then return true
            return expirationDate.asSeconds() > requestDate.asSeconds()
        end function,
        latestPurchase: function(product_identifier, subscriber) as object
            purchase = subscriber.subscriptions[product_identifier]
            if purchase = invalid
                nonSubscriptionPurchases = subscriber.non_subscriptions[product_identifier]
                if nonSubscriptionPurchases <> invalid
                    ' Find the latest purchase date
                    nonSubscriptionPurchases.sortBy("purchase_date")
                    if nonSubscriptionPurchases.Count() > 0
                        purchase = nonSubscriptionPurchases[nonSubscriptionPurchases.Count() - 1]
                    end if
                    ' Default values for fields not present in non-subscription purchases
                    purchase.period_type = "normal"
                    purchase.ownership_type = "PURCHASED"
                end if
            end if
            if purchase = invalid
                _PurchasesLogger().error("Could not find purchase for entitlement with product_id" + product_identifier)
            end if
            return purchase
        end function,
        buildSubscriber: function(response as object) as object
            requestDate = m.buildDateFromString(response.request_date)
            subscriber = response.subscriber
            firstSeen = m.buildDateFromString(subscriber.first_seen)
            lastSeen = m.buildDateFromString(subscriber.last_seen)
            allEntitlements = {}
            activeEntitlements = {}
            for each entry in subscriber.entitlements.Items()
                entitlement = entry.value
                expirationDate = m.buildDateFromString(entitlement.expires_date)
                purchaseDate = m.buildDateFromString(entitlement.purchase_date)
                purchase = m.latestPurchase(entitlement.product_identifier, subscriber)
                isActive = m.isActive(entitlement, requestDate)
                value = {
                    identifier: entry.key,
                    isActive: isActive,
                    willRenew: m.willRenew(purchase),
                    expirationDate: expirationDate,
                    productIdentifier: m.buildProductId(entitlement.product_identifier, purchase),
                    latestPurchaseDate: purchaseDate,
                    originalPurchaseDate: m.buildDateFromString(purchase.original_purchase_date),
                    isSandbox: purchase.is_sandbox,
                    ownershipType: purchase.ownership_type,
                    store: purchase.store,
                    periodType: purchase.period_type,
                    unsubscribeDetectedAt: m.buildDateFromString(purchase.unsubscribe_detected_at),
                    billingIssueDetectedAt: m.buildDateFromString(purchase.billing_issue_detected_at),
                    productPlanIdentifier: entitlement.product_plan_identifier,
                }
                if isActive then activeEntitlements.AddReplace(entry.key, value)
                allEntitlements.AddReplace(entry.key, value)
            end for
            allPurchasedProductIds = []
            allPurchaseDatesByProduct = {}
            allExpirationDatesByProduct = {}
            for each entry in subscriber.subscriptions.Items()
                subscription = entry.value
                productIdentifier = m.buildProductId(entry.key, entry.value)
                allPurchasedProductIds.push(productIdentifier)
                allPurchaseDatesByProduct.AddReplace(productIdentifier, m.buildDateFromString(subscription.purchase_date))
                allExpirationDatesByProduct.AddReplace(productIdentifier, m.buildDateFromString(subscription.expires_date))
            end for
            activeSubscriptions = []
            for each entry in allExpirationDatesByProduct.Items()
                if entry.value <> invalid and entry.value.asSeconds() > requestDate.asSeconds()
                    activeSubscriptions.push(entry.key)
                end if
            end for
            nonSubscriptionTransactions = []
            for each entry in subscriber.non_subscriptions.Items()
                for each transaction in entry.value
                    nonSubscriptionTransactions.push({
                        purchaseDate: m.buildDateFromString(transaction.purchase_date),
                        originalPurchaseDate: m.buildDateFromString(transaction.original_purchase_date),
                        transactionIdentifier: transaction.id,
                        storeTransactionIdentifier: transaction.store_transaction_id,
                        store: transaction.store,
                        isSandbox: transaction.is_sandbox,
                        productIdentifier: entry.key,
                    })
                end for
                allPurchasedProductIds.push(productIdentifier)
            end for
            latestExpirationDate = invalid
            for each item in allExpirationDatesByProduct.Items()
                if latestExpirationDate = invalid or item.value.asSeconds() > latestExpirationDate.asSeconds()
                    latestExpirationDate = item.value
                end if
            end for
            return {
                requestDate: requestDate,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                managementUrl: subscriber.management_url,
                originalAppUserId: subscriber.original_app_user_id,
                originalApplicationVersion: subscriber.original_application_version,
                originalPurchaseDate: m.buildDateFromString(subscriber.original_purchase_date),
                entitlements: {
                    active: activeEntitlements,
                    all: allEntitlements,
                },
                nonSubscriptionTransactions: nonSubscriptionTransactions,
                activeSubscriptions: activeSubscriptions,
                allPurchasedProductIds: allPurchasedProductIds,
                allPurchaseDatesByProduct: allPurchaseDatesByProduct,
                allExpirationDatesByProduct: allExpirationDatesByProduct,
                latestExpirationDate: latestExpirationDate
            }
        end function,
        invokeMethod: function(args) as void
            result = m[args.method](args.args)
            if result <> invalid then
                callbackField = args.callbackID
                _PurchasesLogger().debug("callbackField: " + callbackField.ToStr())
                _PurchasesLogger().debug("method: " + args.method.ToStr())
                m.task[callbackField] = result
                m.task.unobserveField(callbackField)
                m.task.removeField(callbackField)
            end if
        end function,
        task: o.task
    }
end function

' Extracted from: https://github.com/briandunnington/roku-fetch
' License: MIT

' options: {
'     url:     [req] string - http or https url
'     timeout: [opt] int - ms to wait before timeout (defaults to 0 (no timeout))
'     headers: [opt] assocarray - list of request headers where key=headername and val=headervalue
'     method:  [opt] string - the HTTP method. GET|POST|PUT|DELETE|etc (defaults to GET)
'                if you are doing a normal GET or POST, you can omit this - it is only useful for the other verbs
'     body:    [opt] string - the preformatted request body (ie: form data).
'                if specified, the request method will default to POST unless overridden with options.method
' }
'
' returns Response object: {
'    status:  int - the HTTP status code (ex: 200); can be negative to indicate transport error
'    ok:      bool - true if the response is successful (200-299)
'    headers: assocarray - where each header name is a key and the value is an object
'    text():  string - function that returns the raw string response
'    json():  object - function that returns the response parsed as JSON
'    xml():   object - function that returns the response parsed as an roXmlElement
' }

function _InternalPurchases_fetch(options)
    timeout = options.timeout
    if timeout = invalid then timeout = 0

    response = invalid
    port = CreateObject("roMessagePort")
    request = CreateObject("roUrlTransfer")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.InitClientCertificates()
    request.RetainBodyOnError(true)
    request.SetMessagePort(port)
    if options.headers <> invalid
        for each header in options.headers
            val = options.headers[header]
            if val <> invalid then request.addHeader(header, val)
        end for
    end if
    if options.method <> invalid
        request.setRequest(options.method)
    end if
    request.SetUrl(options.url)

    requestSent = invalid
    if options.body <> invalid
        requestSent = request.AsyncPostFromString(options.body)
    else
        requestSent = request.AsyncGetToString()
    end if
    if (requestSent)
        msg = wait(timeout, port)
        status = -999
        body = "(TIMEOUT)"
        headers = {}
        if (type(msg) = "roUrlEvent")
            status = msg.GetResponseCode()
            headersArray = msg.GetResponseHeadersArray()
            for each headerObj in headersArray
                for each headerName in headerObj
                    val = {
                        value: headerObj[headerName]
                        next: invalid
                    }
                    current = headers[headerName]
                    if current <> invalid
                        prev = current
                        while current <> invalid
                            prev = current
                            current = current.next
                        end while
                        prev.next = val
                    else
                        headers[headerName] = val
                    end if
                end for
            end for
            body = msg.GetString()
            if status < 0 then body = msg.GetFailureReason()
        end if

        response = {
            _body: body,
            status: status,
            ok: (status >= 200 and status < 300),
            headers: headers,
            text: function()
                return m._body
            end function,
            json: function()
                return ParseJSON(m._body)
            end function,
            xml: function()
                if m._body = invalid then return invalid
                xml = CreateObject("roXMLElement") '
                if not xml.Parse(m._body) then return invalid
                return xml
            end function
        }
    end if

    return response
end function

function Purchases() as object
    if GetGlobalAA().rc_purchasesSingleton = invalid then
        if m.global = invalid then
            throw "The RevenueCat SDK can only be called from SceneGraph components where the m.global object is available."
        end if
        if m.global.isRunningRevenueCatTests = invalid
            task = m.global.getScene().findNode("purchasesTask")
            if task = invalid then
                task = m.global.getScene().createChild("PurchasesTask")
                task.id = "purchasesTask"
                m.global.addFields({ revenueCatSDKConfig: {} })
            end if
        end if
        m.context = {}

        configuration = _InternalPurchases_Configuration({ global: m.global })
        log = _InternalPurchases_Logger({ configuration: configuration })
        configuration.log = log

        GetGlobalAA().rc_purchasesSingleton = {
            purchase: sub(inputArgs = {} as object, callbackFunc = invalid as dynamic)
                m._internal.invoke("purchase", inputArgs, callbackFunc)
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
                logLevel = m._internal.configuration.get().logLevel
                if logLevel = invalid then return "info"
                return logLevel
            end function,
            isAnonymous: sub(callbackFunc = invalid as dynamic)
                m._internal.invoke("isAnonymous", {}, callbackFunc)
            end sub,
            appUserId: sub(callbackFunc = invalid as dynamic)
                m._internal.invoke("appUserId", {}, callbackFunc)
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
            getOfferings: sub(callbackFunc = invalid as dynamic)
                m._internal.invoke("getOfferings", {}, callbackFunc)
            end sub,
            _internal: {
                configuration: configuration,
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
                    m.task["api"] = {
                        method: name,
                        args: inputArgs,
                        callbackID: m.setCallbackID(callbackFunc),
                    }
                end function
                task: task,
            }
        }
    end if
    return GetGlobalAA().rc_purchasesSingleton
end function

sub _InternalPurchases_invokeCallbackFunction(e as object)
    data = e.getData()
    m.context[e.getField()](data.data, data.error)
end sub

function _InternalPurchases_Configuration(o = {} as object) as object
    return {
        _global: o.global,
        log: o.log,
        get: function() as object
            if m._global.revenueCatSDKConfig = invalid then return {}
            return m._global.revenueCatSDKConfig
        end function,
        configure: function(config as object) as object
            if config.apiKey = invalid then
                m.log.error("Missing apiKey in configuration")
            end if
            m.set(config)
        end function,
        set: function(config as object) as void
            m._global.revenueCatSDKConfig = {
                apiKey: config.apiKey,
                logLevel: config.logLevel,
                proxyUrl: config.proxyUrl,
            }
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

function _InternalPurchases_Logger(o = {} as object) as object
    return {
        configuration: o.configuration,
        logLevel: function() as integer
            level = m.configuration.get().logLevel
            if level <> invalid and m.levels[level] <> invalid then return m.levels[level]
            return m.levels.info
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
end function

function _InternalPurchases(o = {} as object) as object
    _internal_global = o.global
    if _internal_global = invalid
        _internal_global = {}
    end if

    ERRORS = {
        configurationError: {
            message: "There is an issue with your configuration."
            code: 23
            codeName: "CONFIGURATION_ERROR"
        }
    }

    STRINGS = {
        FAILED_TO_FETCH_PRODUCTS: "Failed to fetch products from the Roku store. This can happen if billing testing is not correctly consfigured. Please review the 'How to setup a channel' section of the README."
    }

    configuration = _InternalPurchases_Configuration({ global: _internal_global })
    log = _InternalPurchases_Logger({ configuration: configuration })
    if o.log <> invalid then
        log = o.log
    end if

    configuration.log = log

    registry = {
        log: log,
        set: function(newEntries as object) as void
            entries = m.get()
            if entries <> invalid
                for each key in newEntries
                    entries[key] = newEntries[key]
                end for
            end if
            section = createObject("roRegistrySection", "RevenueCat")
            section.write("Storage", formatJson(entries))
            section.flush()
        end function,
        get: function() as object
            section = createObject("roRegistrySection", "RevenueCat")
            if section.exists("Storage") = false then return {}
            try
                entries = parseJson(section.read("Storage"))
            catch e
                m.log.error("Failed to read registry:" + e.message)
            end try
            if type(entries) <> "roAssociativeArray" then return {}
            return entries
        end function,
        clear: function() as void
            section = createObject("roRegistrySection", "RevenueCat")
            section.delete("Storage")
        end function,
    }

    billing = {
        log: log,
        logStoreEvent: function(event as object) as void
            if event.isRequestSucceeded() then
                m.log.debug("Store Request success")
                m.log.debug(event.GetResponse())
            else if event.isRequestFailed() then
                m.log.debug("Store Request failure")
                m.log.debug(event.GetStatus())
                m.log.debug(event.GetStatusMessage())
            else if event.isRequestInterrupted() then
                m.log.debug("Store Request interrupted")
                m.log.debug(event.GetStatus())
                m.log.debug(event.GetStatusMessage())
            end if
        end function
        purchase: function(inputArgs = {}) as object
            port = CreateObject("roMessagePort")
            store = CreateObject("roChannelStore")
            store.SetMessagePort(port)
            ' store.SetOrder([{ code: inputArgs.code, qty: inputArgs.qty }], { action: "Upgrade" })
            store.SetOrder([{ code: inputArgs.code, qty: 1 }])
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

    api = {
        _defaultHeaders: {
            "X-Platform-Flavor": "native",
            "X-Platform": "roku",
            "X-Client-Build-Version": "1",
            "X-Client-Bundle-ID": "com.revenuecat.sampleapp",
            "X-Client-Version": "1.0",
            "X-Version": "0.0.1",
            "X-Platform-Version": "roku",
            "X-Observer-Mode-Enabled": "false",
            "X-Storefront": "ESP",
            "X-Is-Sandbox": "true",
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
                subscribers: m.getBaseUrl() + "subscribers/",
                identify: m.getBaseUrl() + "subscribers/identify",
                receipts: m.getBaseUrl() + "receipts",
            }
        end function,
        getOfferings: function(inputArgs = {}) as object
            result = _fetch({
                url: m.urls().subscribers + inputArgs.userId + "/offerings",
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
            result = _fetch({
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
        subscriber: function(inputArgs = {}) as object
            result = _fetch({
                url: m.urls().subscribers + inputArgs.userId,
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
        postReceipt: function(inputArgs = {}) as object
            transaction = inputArgs.transaction
            app_user_id = inputArgs.userId
            result = _fetch({
                url: m.urls().receipts,
                headers: m.headers(),
                method: "POST",
                body: FormatJson({
                    fetch_token: transaction.purchaseId,
                    app_user_id: app_user_id,
                    product_id: transaction.code,
                    price: transaction.amount,
                    currency: "USD",
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
        log: log,
        errors: ERRORS,
        strings: STRINGS,
        billing: billing,
        api: api,
        registry: registry,
        configuration: configuration,
        updateCustomerCache: function(customer as object) as void
            ' save customer info to disk cache
        end function,
        getCustomerCache: function() as object
            ' read customer info from disk cache if not stale
        end function,
        updateOfferingsCache: function(offerings as object) as void
            ' save offerings to disk cache
        end function,
        getOfferingsCache: function() as object
            ' read offerings from disk cache if not stale
        end function,
        setUserId: function(userId as string) as void
            m.registry.set({ userId: userId })
        end function,
        appUserId: function() as string
            entries = m.registry.get()
            if entries <> invalid and entries.userId <> invalid then return entries.userId
            anonUserID = m.generateAnonUserId()
            m.registry.set({ userId: anonUserId })
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
        logIn: function(userId as string) as object
            m.configuration.assert()
            if userId = invalid
                m.log.error("Missing userId in logIn")
                return {
                    error: m.errors.configurationError
                }
            end if
            valueType = type(userId)
            if valueType <> "roString" and valueType <> "String" then
                m.log.error("Invalid userId in logIn")
                return {
                    error: m.errors.configurationError
                }
            end if
            currentUserID = m.appUserId()
            if userId = currentUserID
                m.log.info("User already logged in")
                return m.getCustomerInfo()
            end if
            m.setUserId(userId)
            result =  m.api.identify({
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
            currentUserID = m.appUserId()
            anonUserID = m.generateAnonUserID()
            m.setUserId(anonUserID)
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
            result = m.api.subscriber({ userId: m.appUserId() })
            if result.error <> invalid
                return result
            end if
            return { data: m.buildSubscriber(result.data) }
        end function,
        purchase: function(inputArgs = {}) as object
            m.configuration.assert()
            code = ""
            valueType = type(inputArgs)
            if inputArgs.code <> invalid
                code = inputArgs.code
            else if inputArgs.storeProduct <> invalid and inputArgs.storeProduct.code <> invalid
                code = inputArgs.storeProduct.code
            else if valueType = "roString" or valueType = "String"
                code = inputArgs
            end if
            if code = "" then
                m.log.error("Ivalid product identifier in purchase")
                return {
                    error: m.errors.configurationError
                }
            end if
            result = m.billing.purchase({ code: code })

            if result.error <> invalid
                if result.error.code = 2
                    result.data = { userCancelled: true }
                end if
                return result
            end if

            transactions = result.data

            result = m.api.postReceipt({
                userId: m.appUserId(),
                transaction: transactions[0],
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
        getOfferings: function(inputArgs = {}) as object
            m.configuration.assert()
            result = m.api.getOfferings({ userId: m.appUserId() })
            if result.error <> invalid
                return result
            end if
            offerings = result.data
            current_offering_id = offerings.current_offering_id
            current_offering = invalid
            all_offerings = []
            result = m.billing.getProductsById()

            if result.error <> invalid
                return result
            end if

            productsByID = result.data

            if productsByID.Count() = 3 and (productsByID["PROD1"] <> invalid or productsByID["PROD2"] <> invalid or productsByID["FAILPROD"] <> invalid)
                m.log.error(m.strings.FAILED_TO_FETCH_PRODUCTS)
            end if

            for each offering in offerings.offerings
                annual = invalid
                monthly = invalid
                availablePackages = []
                for each package in offering.packages
                    product = productsByID[package.platform_product_identifier]
                    if product = invalid then continue for
                    if package.identifier = "$rc_annual"
                        annual = {
                            identifier: package.identifier,
                            packageType: "annual"
                            storeProduct: productsByID[package.platform_product_identifier],
                        }
                        availablePackages.push(annual)
                    else if package.identifier = "$rc_monthly"
                        monthly = {
                            identifier: package.identifier,
                            packageType: "monthly"
                            storeProduct: productsByID[package.platform_product_identifier],
                        }
                        availablePackages.push(monthly)
                    else
                        availablePackages.push({
                            identifier: package.identifier,
                            packageType: "custom"
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
                all_offerings.push(o)
                if offering.identifier = current_offering_id
                    current_offering = o
                end if
            end for
            return {
                data: {
                    current: current_offering,
                    all: all_offerings,
                }
            }
        end function,
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
            isLifetime = purchase.expirationDate = invalid
            hasUnsubscribed = purchase.unsubscribeDetectedAt <> invalid
            hasBillingIssues = purchase.billingIssueDetectedAt <> invalid
            return (isPromo or isLifetime or hasUnsubscribed or hasBillingIssues) = false
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
                gracePeriodExpiresDate = invalid
                if entitlement.grace_period_expires_date <> invalid
                    gracePeriodExpiresDate = CreateObject("roDateTime")
                    gracePeriodExpiresDate.FromISO8601String(entitlement.grace_period_expires_date)
                end if
                isActive = expirationDate.asSeconds() > requestDate.asSeconds()
                purchase = subscriber.subscriptions[entitlement.product_identifier]
                if purchase = invalid
                    purchase = subscriber.non_subscriptions[entitlement.product_identifier]
                end if
                if purchase = invalid
                    m.log.error("Could not find purchase for entitlement with product_id" + entitlement.product_identifier)
                end if
                value = {
                    identifier: entry.key,
                    isActive: isActive,
                    willRenew: m.willRenew(purchase),
                    expirationDate: expirationDate,
                    gracePeriodExpiresDate: gracePeriodExpiresDate,
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

                allPurchaseDatesByProduct.AddReplace(
                    productIdentifier, m.buildDateFromString(subscription.purchase_date)
                )
                allExpirationDatesByProduct.AddReplace(
                    productIdentifier, m.buildDateFromString(subscription.expires_date)
                )
            end for
            activeSubscriptions = []
            for each entry in allExpirationDatesByProduct.Items()
                if entry.value.asSeconds() > requestDate.asSeconds()
                    activeSubscriptions.push(entry.key)
                end if
            end for
            nonSubscriptionTransactions = {}
            for each entry in subscriber.non_subscriptions.Items()
                allTransactions = []
                for each transaction in entry.value
                    allTransactions.push({
                        purchaseDate: m.buildDateFromString(transaction.purchase_date),
                        originalPurchaseDate: m.buildDateFromString(transaction.original_purchase_date),
                        transactionIdentifier: transaction.id,
                        storeTransactionIdentifier: transaction.store_transaction_id,
                        store: transaction.store,
                        isSandbox: transaction.is_sandbox,
                    })
                end for
                productIdentifier = m.buildProductId(entry.key, entry.value)
                allPurchasedProductIds.push(productIdentifier)
                nonSubscriptionTransactions.AddReplace(productIdentifier, allTransactions)
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
                m.log.debug("callbackField: " + callbackField.ToStr())
                m.log.debug("method: " + args.method.ToStr())
                m.log.debug("result: " + formatJson(result))
                m.task[callbackField] = result
                m.task.unobserveField(callbackField)
                m.task.removeField(callbackField)
            end if
        end function,
        task: o.task
    }
end function

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

function _fetch(options)
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
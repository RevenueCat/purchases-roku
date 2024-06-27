function Purchases() as object
    if GetGlobalAA().rc_purchasesSingleton = invalid then
        print("Creating Purchases singleton")
        task = m.global.getScene().findNode("purchasesTask")
        if task = invalid then
            print("Creating Purchases task")
            task = m.global.getScene().createChild("PurchasesTask")
            task.id = "purchasesTask"
            m.global.addFields({ revenueCatSDKConfig: {} })
        end if
        m.context = {}
        GetGlobalAA().rc_purchasesSingleton = {
            _context: m.context,
            _global: m.global,
            purchase: sub(inputArgs = {} as object, callbackFunc = invalid as dynamic)
                m._invoke("purchase", inputArgs, callbackFunc)
            end sub,
            configure: sub(inputArgs = {} as object, callbackFunc = invalid as dynamic)
                m._invoke("configure", inputArgs, callbackFunc)
            end sub,
            logIn: sub(inputArgs = {} as object, callbackFunc = invalid as dynamic)
                m._invoke("logIn", inputArgs, callbackFunc)
            end sub,
            logOut: sub(callbackFunc = invalid as dynamic)
                m._invoke("logOut", {}, callbackFunc)
            end sub,
            getCustomerInfo: sub(callbackFunc = invalid as dynamic)
                m._invoke("getCustomerInfo", {}, callbackFunc)
            end sub,
            getOfferings: sub(callbackFunc = invalid as dynamic)
                m._invoke("getOfferings", {}, callbackFunc)
            end sub,
            _setCallbackID: function(callbackFunc as dynamic) as string
                m._task.callbackID++
                if (m._task.callbackID >= 100000) then
                    m._task.callbackID = 1
                end if
                callbackID = m._task.callbackID.tostr()
                m._task.addField(callbackID, "assocarray", false)
                valueType = type(callbackFunc)
                if valueType = "roFunction" or valueType = "Function" then
                    m._task.observeField(callbackID, "_invokeCallbackFunction")
                    m._context[callbackID] = callbackFunc
                else if valueType = "roString" or valueType = "String" then
                    m._task.observeField(callbackID, callbackFunc)
                else
                    m._task.observeField(callbackID, "")
                end if
                return callbackID
            end function,
            _invoke: function(name as string, inputArgs = {}, callbackFunc = invalid as dynamic)
                m._task["api"] = {
                    method: name,
                    args: inputArgs,
                    callbackID: m._setCallbackID(callbackFunc),
                }
            end function
            _task: task,
        }
    end if
    return GetGlobalAA().rc_purchasesSingleton
end function

sub _invokeCallbackFunction(e as object)
    data = e.getData()
    m.context[e.getField()](data.data, data.error)
end sub

function _PurchasesSDK(o = {} as object) as object
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

    billing = {
        purchase: function(inputArgs = {}) as object
            port = CreateObject("roMessagePort")
            store = CreateObject("roChannelStore")
            store.SetMessagePort(port)
            ' store.SetOrder([{ code: inputArgs.code, qty: inputArgs.qty }], { action: "Upgrade" })
            store.SetOrder([{ code: inputArgs.code, qty: 1 }])
            store.DoOrder()
            msg = wait(0, port)
            if (type(msg) = "roChannelStoreEvent")
                ProcessRoChannelStoreEvent(msg)
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
                ProcessRoChannelStoreEvent(msg)
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
                ProcessRoChannelStoreEvent(msg)
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
        _global: _internal_global,
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
        headers: function() as object
            headers = {
                "Authorization": "Bearer " + m._global.revenueCatSDKConfig.apiKey,
                "Content-Type": "application/json",
            }
            headers.Append(m._defaultHeaders)
            return headers
        end function,
        getBaseUrl: function() as string
            proxyUrl = m._global.revenueCatSDKConfig.proxyUrl
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
                    data: result.json().subscriber
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
                    data: result.json().subscriber
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
                    data: result.json().subscriber
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

    log = {
        error: function(message as string) as void
            print("😿‼️  Error: " + message)
        end function,
        info: function(message as string) as void
            print("ℹ️  Info: " + message)
        end function,
        warning: function(message as string) as void
            print("⚠️  Warning: " + message)
        end function,
    }

    return {
        log: log,
        errors: ERRORS,
        billing: billing,
        api: api,
        _global: _internal_global,
        saveConfig: function(newConfig as object) as void
            config = m.getConfig()
            if config <> invalid
                for each key in newConfig
                    config[key] = newConfig[key]
                end for
            end if
            section = createObject("roRegistrySection", "RevenueCatConfig")
            section.write("Config", formatJson(config))
            section.flush()
        end function,
        getConfig: function() as object
            section = createObject("roRegistrySection", "RevenueCatConfig")
            if section.exists("Config")
                try
                    config = parseJson(section.read("Config"))
                catch e
                    print("Failed to read config:" + e.message)
                end try
                if type(config) = "roAssociativeArray" then return config
            end if
        end function,
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
            m.saveConfig({ userId: userId })
        end function,
        getUserId: function() as string
            config = m.getConfig()
            if config <> invalid and config.userId <> invalid then return config.userId
            anonUserID = m.generateAnonUserId()
            m.saveConfig({ userId: anonUserId })
            return anonUserID
        end function,
        generateAnonUserId: function() as string
            r = CreateObject("roRegex", "-", "i")
            uuid = r.ReplaceAll(LCase(createObject("roDeviceInfo").getRandomUUID()), "")
            return "$RCAnonymousID:" + uuid
        end function,
        configure: function(inputArgs = {}) as object
            if inputArgs.apiKey = invalid then
                m.log.error("Missing apiKey in configuration")
                return {
                    error: m.errors.configurationError
                }
            end if
            m._global.revenueCatSDKConfig = inputArgs
            return {
                data: {
                    apiKey: inputArgs.apiKey
                }
            }
        end function,
        logIn: function(userId as string) as object
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
            currentUserID = m.getUserID()
            if userId = currentUserID
                m.log.info("User already logged in")
                return m.getCustomerInfo()
            end if
            m.setUserId(userId)
            return m.api.identify({
                userId: currentUserID
                newUserId: userId
            })
        end function,
        logOut: function(inputArgs = {}) as object
            anonUserID = m.generateAnonUserID()
            return m.api.identify(anonUserID)
        end function,
        getCustomerInfo: function(inputArgs = {}) as object
            return m.api.subscriber({ userId: m.getUserID() })
        end function,
        purchase: function(inputArgs = {}) as object
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
                userId: m.getUserID(),
                transaction: transactions[0],
            })
            if result.error <> invalid
                return result
            end if
            return {
                data: {
                    transaction: transactions[0],
                    subscriber: result.data
                }
            }
        end function,
        getOfferings: function(inputArgs = {}) as object
            result = m.api.getOfferings({ userId: m.getUserID() })
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
        invokeMethod: function(args) as void
            result = m[args.method](args.args)
            if result <> invalid then
                callbackField = args.callbackID
                print "callbackField: "; callbackField
                print "method: "; args.method
                print "result: "; result
                m.task[callbackField] = result
                m.task.unobserveField(callbackField)
                m.task.removeField(callbackField)
            end if
        end function,
        task: o.task
    }
end function

function ProcessRoChannelStoreEvent(event as object) as void
    if event.isRequestSucceeded() then
        print("Store Request success")
        print(event.GetResponse())
    else if event.isRequestFailed() then
        print("Store Request failure")
        print(event.GetStatus())
        print(event.GetStatusMessage())
    else if event.isRequestInterrupted() then
        print("Store Request interrupted")
        print(event.GetStatus())
        print(event.GetStatusMessage())
    end if
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
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
            logOut: sub(inputArgs as object, callbackFunc = invalid as dynamic)
                m._invoke("logOut", inputArgs, callbackFunc)
            end sub,
            setAttributes: sub(inputArgs = {} as object, callbackFunc = invalid as dynamic)
                m._invoke("setAttributes", inputArgs, callbackFunc)
            end sub,
            getCustomerInfo: sub(inputArgs = {} as object, callbackFunc = invalid as dynamic)
                m._invoke("getCustomerInfo", inputArgs, callbackFunc)
            end sub,
            syncPurchases: sub(inputArgs = {} as object, callbackFunc = invalid as dynamic)
                m._invoke("syncPurchases", inputArgs, callbackFunc)
            end sub,
            getOfferings: sub(inputArgs = {} as object, callbackFunc = invalid as dynamic)
                m._invoke("getOfferings", inputArgs, callbackFunc)
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
    m.context[e.getField()](e.getData())
end sub

function _PurchasesSDK(o as object) as object
    _baseURL = "https://api.revenuecat.com/v1/"

    global = o.global
    if global = invalid
        global = {}
    end if

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
            transactions = msg.GetResponse()
            return { transactions: transactions }
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
            transactions = msg.GetResponse()
            return transactions
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
            products = msg.GetResponse()
            productsByID = {}
            for each product in products
                productsByID[product.code] = product
            end for
            return productsByID
        end function,
    }
    if o.billing <> invalid then
        billing = o.billing
    end if

    api = {
        _global: o.global,
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
                "Authorization": "Bearer " + m._global.revenueCatSDKConfig.api_key,
                "Content-Type": "application/json",
            }
            headers.Append(m._defaultHeaders)
            return headers
        end function,
        _urls: {
            subscribers: _baseURL + "subscribers/",
            identify: _baseURL + "subscribers/identify/",
            receipts: _baseURL + "receipts/",
        },
        getOfferings: function(inputArgs = {}) as object

            result = _fetch({
                url: m._urls.subscribers + inputArgs.userID + "/offerings",
                headers: m.headers(),
                method: "GET"
            })
            return result.json()
        end function,
        identify: function(inputArgs = {}) as object
            return _fetch({
                url: m._urls.identify,
                headers: m.headers(),
                method: "POST",
                body: FormatJson({
                    "app_user_id": inputArgs,
                    "new_app_user_id": inputArgs,
                })
            })
        end function,
        subscriber: function(inputArgs = {}) as object
            result = _fetch({
                url: m._urls.subscribers + inputArgs.userID,
                headers: m.headers(),
                method: "GET"
            })
        end function,
        postReceipt: function(inputArgs = {}) as object
            purchase = inputArgs.purchase
            app_user_id = inputArgs.userID
            _fetch({
                url: m._urls.receipts,
                headers: m.headers(),
                method: "POST",
                body: FormatJson({
                    fetch_token: purchase.purchaseId,
                    app_user_id: app_user_id,
                    product_id: purchase.code,
                    price: purchase.amount,
                    currency: "USD",
                })
            })
        end function,

    }
    if o.api <> invalid then
        api = o.api
    end if

    return {
        billing: billing,
        api: api,
        _global: global,
        saveConfig: function(config as object) as void
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
        updateCustomerCache: function(customer as Object) as Void
            ' save customer info to disk cache
        end function,
        getCustomerCache: function() as Object
            ' read customer info from disk cache if not stale
        end function,
        updateOfferingsCache: function(offerings as Object) as Void
            ' save offerings to disk cache
        end function,
        getOfferingsCache: function() as Object
            ' read offerings from disk cache if not stale
        end function,
        configure: function(inputArgs = {}) as object
            m._global.revenueCatSDKConfig = inputArgs
            return {}
        end function,
        logIn: function(inputArgs = {}) as object
            m.saveConfig({ userID: inputArgs })
            result = m.api.identify(inputArgs)
            return {}
        end function,
        logOut: function(inputArgs = {}) as object
            result = m.api.identify("anon_user")
            return {}
        end function,
        getCustomerInfo: function(inputArgs = {}) as object
            return m.api.subscriber({ userID: m.getConfig().userID })
        end function,
        setAttributes: function(inputArgs = {}) as object
            print("setAttributes")
            return {}
        end function,
        purchase: function(inputArgs = {}) as object
            return m.billing.purchase(inputArgs)
        end function,
        syncPurchases: function(inputArgs = {}) as object
            purchase = inputArgs.purchase
            m.api.postReceipt({
                userID: m.getConfig().userID,
                purchase: purchase,
            })
            return {}
        end function,
        getOfferings: function(inputArgs = {}) as object
            offerings = m.api.getOfferings({ userID: m.getConfig().userID })
            current_offering_id = offerings.current_offering_id
            current_offering = invalid
            all_offerings = []
            productsByID = m.billing.getProductsById()
            for each offering in offerings.offerings
                annual = invalid
                monthly = invalid
                packages = []
                for each package in offering.packages
                    product = productsByID[package.platform_product_identifier]
                    if product = invalid then continue for
                    if package.identifier = "$rc_annual"
                        annual = {
                            identifier: package.identifier,
                            packageType: "annual"
                            product: productsByID[package.platform_product_identifier],
                        }
                        packages.push(annual)
                    else if package.identifier = "$rc_monthly"
                        monthly = {
                            identifier: package.identifier,
                            packageType: "monthly"
                            product: productsByID[package.platform_product_identifier],
                        }
                        packages.push(monthly)
                    else
                        packages.push({
                            identifier: package.identifier,
                            packageType: "custom"
                            product: productsByID[package.platform_product_identifier],
                        })
                    end if
                end for
                o = {
                    identifier: offering.identifier,
                    metadata: offering.metadata,
                    description: offering.description,
                    annual: annual,
                    monthly: monthly,
                    packages: packages,
                }
                all_offerings.push(o)
                if offering.identifier = current_offering_id
                    current_offering = o
                end if
            end for
           return {
                current: current_offering,
                all: all_offerings,
            }
        end function,
        invokeMethod: function(args) as void
            result = m[args.method](args.args)
            if result <> invalid then
                callbackField = args.callbackID
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
        print("Request success")
        print(event.GetResponse())
    else if event.isRequestFailed() then
        print("Request failure")
        print(event.GetStatus())
        print(event.GetStatusMessage())
    else if event.isRequestInterrupted() then
        print("Request interrupted")
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
            ok: (status >= 200 AND status < 300),
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
                if NOT xml.Parse(m._body) then return invalid
                return xml
            end function
        }
    end if

    return response
end function
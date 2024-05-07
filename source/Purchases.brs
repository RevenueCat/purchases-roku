function Purchases() as object
    if GetGlobalAA().rc_purchasesSingleton = invalid then
        print("Creating Purchases singleton")
        task = m.global.getScene().findNode("purchasesTask")
        if task = invalid then
            print("Creating Purchases task")
            task = m.global.getScene().createChild("PurchasesTask")
            task.id = "purchasesTask"
            m.global.addFields({revenueCatSDKConfig: {}})
        end if
        m.context = {}
        GetGlobalAA().rc_purchasesSingleton = {
            _context: m.context,
            _global: m.global,
            purchase: sub(inputArgs = {} as object, callbackFunc = invalid as dynamic)
                m._invoke("purchase", inputArgs, callbackFunc)
            end sub,
            configure: sub(inputArgs = {} as object)
                m._global.revenueCatSDKConfig = inputArgs
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
                    args: [inputArgs, m._setCallbackID(callbackFunc), callbackFunc]
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

function _PurchasesSDK(task as object) as object
    _baseURL = "https://api.revenuecat.com/v1/"
    return {
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
        _urls: {
            subscribers: _baseURL + "subscribers/",
            identify: _baseURL + "subscribers/identify/",
            receipts: _baseURL + "receipts/",
        }
        _global: m.global,
        saveConfig: function(config as Object) as Void
            section = createObject("roRegistrySection", "RevenueCatConfig")
            section.write("Config", formatJson(config))
            section.flush()
        end function,
        getConfig: function() as Object
            section = createObject("roRegistrySection", "RevenueCatConfig")
            if section.exists("Config")
                try
                    config = parseJson(section.read("Config"))
                    if type(config) = "roAssociativeArray" then return config
                catch e
                    print("Failed to read config:" + e.message)
                end try
            end if
        end function,
        purchase: function(inputArgs = {}, callbackField = "", callbackFunc = "") as void
            port = CreateObject("roMessagePort")
            store = CreateObject("roChannelStore")
            store.SetMessagePort(port)
            ' store.SetOrder([{ code: inputArgs.code, qty: inputArgs.qty }], { action: "Upgrade" })
            store.SetOrder([{ code: inputArgs.code, qty: inputArgs.qty }])
            store.DoOrder()
            msg = wait(0, port)
            if (type(msg) = "roChannelStoreEvent")
                ProcessRoChannelStoreEvent(msg)
            end if
            transactions = msg.GetResponse()
            for each transaction in transactions
                m.syncPurchases({purchase: transaction})
              end for
            m.task[callbackField] = { transactions: transactions }
            m.task.unobserveField(callbackField)
            m.task.removeField(callbackField)
        end function,
        identify: function(inputArgs = {}) as object
            headers = {
                "Authorization": "Bearer " + m._global.revenueCatSDKConfig.api_key,
                "Content-Type": "application/json",
            }
            headers.Append(m._defaultHeaders)
            return _fetch({
                url: m._urls.identify,
                headers: {
                    "Content-Type": "application/json"
                },
                method: "POST",
                body: FormatJson({
                    "app_user_id": inputArgs,
                    "new_app_user_id": inputArgs,
                })
            })
        end function,
        logIn: function(inputArgs = {}, callbackField = "", callbackFunc = "") as void
            m.saveConfig({ userID: inputArgs })
            result = m.identify(inputArgs)
            m.task[callbackField] = result.json().subscriber
            m.task.unobserveField(callbackField)
            m.task.removeField(callbackField)
        end function,
        logOut: function(inputArgs = {}, callbackField = "", callbackFunc = "") as void
            result = m.identify("anon_user")
            m.task[callbackField] = result.json().subscriber
            m.task.unobserveField(callbackField)
            m.task.removeField(callbackField)
        end function,
        getCustomerInfo: function(inputArgs = {}, callbackField = "", callbackFunc = "") as void
            headers = {
                "Authorization": "Bearer " + m._global.revenueCatSDKConfig.api_key,
            }
            headers.Append(m._defaultHeaders)
            result = _fetch({
                url: m._urls.subscribers + m.getConfig().userID,
                headers: headers,
                method: "GET"
            })
            m.task[callbackField] = result.json().subscriber
            m.task.unobserveField(callbackField)
            m.task.removeField(callbackField)
        end function,
        setAttributes: function(inputArgs = {}, callbackField = "", callbackFunc = "") as void
            print("setAttributes")
            m.task[callbackField] = {}
            m.task.unobserveField(callbackField)
            m.task.removeField(callbackField)
        end function,
        syncPurchases: function(inputArgs = {}, callbackField = "", callbackFunc = "") as void
            purchase = inputArgs.purchase
            _fetch({
                url: "https://webhook.site/markrokureceipt"
                headers: {
                    "Content-Type": "application/json"
                },
                method: "POST",
                body: FormatJson({
                    code: purchase.code,
                    cost: purchase.cost,
                    description: purchase.description,
                    expirationDate: purchase.expirationDate
                    freeTrialQuantity: purchase.freeTrialQuantity,
                    freeTrialType: purchase.freeTrialType,
                    inDunning: purchase.inDunning,
                    name: purchase.name,
                    productType: purchase.productType,
                    purchaseChannel: purchase.purchaseChannel,
                    purchaseContext: purchase.purchaseContext,
                    purchaseDate: purchase.purchaseDate,
                    purchaseId: purchase.purchaseId,
                    qty: purchase.qty,
                    renewalDate: purchase.renewalDate,
                    status: purchase.status,
                    trialCost: purchase.trialCost,
                    trialQuantity: purchase.trialQuantity,
                    trialType: purchase.trialType,
                })
            })
            m.task[callbackField] = {}
            m.task.unobserveField(callbackField)
            m.task.removeField(callbackField)
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
        getOfferings: function(inputArgs = {}, callbackField = "", callbackFunc = "") as void
            headers = {
                "Authorization": "Bearer " + m._global.revenueCatSDKConfig.api_key,
            }
            headers.Append(m._defaultHeaders)
            result = _fetch({
                url: m._urls.subscribers + m.getConfig().userID + "/offerings",
                headers: headers,
                method: "GET"
            })
            offerings = result.json()
            current_offering_id = offerings.current_offering_id
            current_offering = invalid
            all_offerings = []
            productsByID = m.getProductsById()
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
            m.task[callbackField] = {
                current: current_offering,
                all: all_offerings,
            }
            m.task.unobserveField(callbackField)
            m.task.removeField(callbackField)
        end function,
        task: task
    }
end function

function ProcessRoChannelStoreEvent(event as object) as void
    if event.isRequestSucceeded() then
        ' print("Request success")
        print(event.GetResponse())
    else if event.isRequestFailed() then
        ' print("Request failure")
        print(event.GetStatus())
        print(event.GetStatusMessage())
    else if event.isRequestInterrupted() then
        ' print("Request interrupted")
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
function Purchases() as object
    if GetGlobalAA().rc_purchasesSingleton = invalid then
        print("Creating Purchases singleton")
        task = m.global.getScene().findNode("purchasesTask")
        if task = invalid then
            print("Creating Purchases task")
            task = m.global.getScene().createChild("PurchasesTask")
            task.id = "purchasesTask"
        end if
        m.context = {}
        GetGlobalAA().rc_purchasesSingleton = {
            _context: m.context,
            purchase: function(inputArgs = {}, callbackFunc = invalid as dynamic) as void
                callbackField = m._setCallbackField(callbackFunc)
                m._invokeFunction("purchase", [inputArgs, callbackField, callbackFunc])
            end function,
            configure: function(inputArgs = {}) as void
                print("configure")
            end function,
            logIn: function(inputArgs = {}, callbackFunc = invalid as dynamic) as void
                callbackField = m._setCallbackField(callbackFunc)
                m._invokeFunction("logIn", [inputArgs, callbackField, callbackFunc])
            end function,
            logOut: function(inputArgs = {}, callbackFunc = invalid as dynamic) as void
                callbackField = m._setCallbackField(callbackFunc)
                m._invokeFunction("logOut", [inputArgs, callbackField, callbackFunc])
            end function,
            getCustomerInfo: function(inputArgs = {}, callbackFunc = invalid as dynamic) as void
                callbackField = m._setCallbackField(callbackFunc)
                m._invokeFunction("getCustomerInfo", [inputArgs, callbackField, callbackFunc])
            end function,
            syncPurchases: function(inputArgs = {}, callbackFunc = invalid as dynamic) as void
                callbackField = m._setCallbackField(callbackFunc)
                m._invokeFunction("syncPurchases", [inputArgs, callbackField, callbackFunc])
            end function,
            getOfferings: function(inputArgs = {}, callbackFunc = invalid as dynamic) as void
                callbackField = m._setCallbackField(callbackFunc)
                m._invokeFunction("getOfferings", [inputArgs, callbackField, callbackFunc])
            end function,
            _setCallbackField: function(callbackFunc as dynamic) as string
                m._task.callbackID++
                if (m._task.callbackID >= 100000) then
                    m._task.callbackID = 1
                end if
                callbackField = m._task.callbackID.tostr()
                m._task.addField(callbackField, "assocarray", false)
                valueType = type(callbackFunc)
                if valueType = "roFunction" or valueType = "Function" then
                    m._task.observeField(callbackField, "_invokeCallbackFunction")
                    m._context[callbackField] = callbackFunc
                else if valueType = "roString" or valueType = "String" then
                    m._task.observeField(callbackField, callbackFunc)
                else
                    m._task.observeField(callbackField, "")
                end if
                return callbackField
            end function,
            _invokeFunction: function(name as string, args)
                invocation = {}
                invocation.method = name
                invocation.args = args
                m._task["api"] = invocation
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
    return {
        purchase: function(inputArgs = {}, callbackField = "", callbackFunc = "") as void
            port = CreateObject("roMessagePort")
            store = CreateObject("roChannelStore")
            store.SetMessagePort(port)
            store.SetOrder([{ code: inputArgs.code, qty: inputArgs.qty }])
            store.DoOrder()
            msg = wait(0, port)
            print("msg: ")
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
        logIn: function(inputArgs = {}, callbackField = "", callbackFunc = "") as void
            print("logIn")
        end function,
        logOut: function(inputArgs = {}, callbackField = "", callbackFunc = "") as void
            print("logOut")
        end function,
        getCustomerInfo: function(inputArgs = {}, callbackField = "", callbackFunc = "") as void
            print("getCustomerInfo")
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
        end function,
        getOfferings: function(inputArgs = {}, callbackField = "", callbackFunc = "") as void
            port = CreateObject("roMessagePort")
            store = CreateObject("roChannelStore")
            store.SetMessagePort(port)
            store.GetCatalog()
            msg = wait(0, port)
            if (type(msg) = "roChannelStoreEvent")
                ProcessRoChannelStoreEvent(msg)
            end if
            m.task[callbackField] = { "products": msg.GetResponse() }
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
function init()
    print("Initializing Purchases Task")
    if m.global.getField("purchases_task_initialized") = invalid then
        m.global.addFields({"purchases_task_initialized": true})
        m.port = CreateObject("roMessagePort")
        m.top.observeField("api", m.port)
        m.top.functionName = "runloop"
        m.top.control = "RUN"
        m.store = CreateObject("roChannelStore")
        m.store.SetMessagePort(m.port)
        m.purchases = _PurchasesSDK(m.top)
        m.callbackCounter = 0
    else
        print("ERROR: PurchasesTask already initialized. Aborting")
    end if
end function

sub runloop()
    print("Running Purchases Task")
    while true
        msg = wait(5*1000, m.port)
        if msg = invalid then
            print "Invalid message"
        else
            messageType = type(msg)
            if messageType = "roSGNodeEvent" then
                if msg.getField()="api"
                    _execute(msg.getData())
                else if msg.getField()="response"
                    data = msg.getData()
                    m.top[data.callbackfield] = data.response
                    m.top.unobserveField(data.callbackField)
                    m.top.removeField(data.callbackField)
                end if
            else if messageType = "roChannelStoreEvent" then
                print("roChannelStoreEvent Event")
            else
                print("Unknown message type: " + messageType)
            end if
        end if
    end while
end sub

function _execute(apiCall as Object)
    args = apiCall.args
    length = args.count()
    target = m.purchases
    methodName = apiCall.method

    if (length = 0) then
        target[methodName]()
    else if (length = 1) then
        target[methodName](args[0])
    else if (length = 2) then
        target[methodName](args[0], args[1])
    else if (length = 3) then
        target[methodName](args[0], args[1], args[2])
    else if (length = 4) then
        target[methodName](args[0], args[1], args[2], args[3])
    else if (length = 5) then
        target[methodName](args[0], args[1], args[2], args[3], args[4])
    else if (length = 6) then
        target[methodName](args[0], args[1], args[2], args[3], args[4], args[5])
    else if (length = 7) then
        target[methodName](args[0], args[1], args[2], args[3], args[4], args[5], args[6])
    end if
end function
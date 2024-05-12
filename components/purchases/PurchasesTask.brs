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
        m.purchases = _PurchasesSDK({ task: m.top })
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
                    m.purchases.invokeMethod(msg.getData())
                else if msg.getField()="response"
                    data = msg.getData()
                    m.top[data.callbackfield] = data.response
                    m.top.unobserveField(data.callbackField)
                    m.top.removeField(data.callbackField)
                end if
            else
                print("Unknown message type: " + messageType)
            end if
        end if
    end while
end sub

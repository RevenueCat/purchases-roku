function init()
    if m.global.getField("rc_taskInitialized") = invalid then
        m.global.addFields({ "rc_taskInitialized": true })
        m.port = CreateObject("roMessagePort")
        m.top.observeField("api", m.port)
        m.top.functionName = "runloop"
        m.top.control = "RUN"
        m.store = CreateObject("roChannelStore")
        m.store.SetMessagePort(m.port)
        m.purchases = _InternalPurchases({ task: m.top })
        m.callbackCounter = 0
    end if
end function

sub runloop()
    while true
        msg = wait(5 * 1000, m.port)
        if msg = invalid then
            print "Invalid message"
        else
            messageType = type(msg)
            if messageType = "roSGNodeEvent" then
                if msg.getField() = "api"
                    m.purchases.invokeMethod(msg.getData())
                else if msg.getField() = "response"
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

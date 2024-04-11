Sub Init()
    m.top.functionName = "ListenInput"
End Sub

function ListenInput()
    port = CreateObject("romessageport")
    inputObject = CreateObject("roInput")
    inputObject.SetMessagePort(port)

    while true
        msg = port.WaitMessage(500)

        if type(msg)="roInputEvent" then
            if msg.isInput()
                inputData = msg.getInfo()
                print "InputEventTask : Input Event Data " inputData
                m.top.inputEventData = inputData
            end if
        end if
    end while
end function

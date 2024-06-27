'********** Copyright 2020 Roku Corp.  All Rights Reserved. **********
sub RunUserInterface(args as object)
    screen = CreateObject("roSGScreen")

    if screen = invalid then
        print "Running tests"
        runTests()
        return
    end if

    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    scene = screen.CreateScene("MainScene")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub
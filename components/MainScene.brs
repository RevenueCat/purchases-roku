function init()
    ' Initialise the SDK
    if Purchases().isConfigured() <> true
        Purchases().configure({
            "apiKey": "roku_XXXXXXXXX",
            ' "proxyUrl": "",
        })
    end if
    ' Login the user
    Purchases().logIn("mark_roku_test", sub(subscriber, error)
        Purchases().setAttributes({ "email": "foo@example.com" })
        ' Get current offerings
        if error = invalid
            Purchases().getOfferings(sub(offerings, error)
                print "offerings"; offerings.current
                if error = invalid
                    ' Purchase the annual product of the current offering
                    if offerings.current <> invalid and offerings.current.annual <> invalid
                        Purchases().purchase({ package: offerings.current.annual, action: "Downgrade" }, sub(result, error)
                            if error = invalid
                                print "Purchase successful"
                                print FormatJson(result.transaction)
                                print result.subscriber
                                print result
                                print error
                            else
                                print "Purchase failed"
                                print error
                                print result
                            end if
                        end sub)
                    end if
                end if
            end sub)
        end if
    end sub)
end function
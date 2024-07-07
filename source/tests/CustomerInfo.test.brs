function customerInfoTests(t)
    t.describe("CustomerInfo Tests", sub(t)
        t.it("Can call getCustomerInfo", sub(t)
            purchases = _InternalPurchases()
            purchases.configuration.configure({ apiKey: Constants().TEST_API_KEY })
            purchases.registry.clear()
            purchases.login("user1")

            result = purchases.getCustomerInfo()
            t.assert.isValid(result, "CustomerInfo result error")
            t.assert.isInvalid(result.error, "Unexpected error")
            assertSubscriberIsValid(t, result.data)
            t.pass()
        end sub)

        t.it("Can parse complex getCustomerInfo", sub(t)
            p = _InternalPurchases({
                api: {
                    subscriber: function(inputArgs = {})
                        return {
                            data: subscriberFixture()
                        }
                    end function
                }
            })
            p.configuration.configure({ apiKey: Constants().TEST_API_KEY })
            result = p.getCustomerInfo()
            t.assert.isValid(result, "CustomerInfo result error")
            t.assert.isInvalid(result.error, "Unexpected error")
            assertSubscriberIsValid(t, result.data)
            t.pass()
        end sub)
    end sub)
end function
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
                    getCustomerInfo: function(inputArgs = {})
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

        t.it("Can set subscriber attributes", sub(t)
            p = _InternalPurchases()
            p.configuration.configure({ apiKey: Constants().TEST_API_KEY })
            p.registry.clear()
            p.login("user1")

            result = p.setAttributes({
                email: "example@example.com"
            })
            t.assert.isValid(result, "CustomerInfo result error")
            t.assert.isInvalid(result.error, "Unexpected error")
            t.pass()
        end sub)

        t.it("Rejects invalid subscriber attributes", sub(t)
            p = _InternalPurchases()
            p.configuration.configure({ apiKey: Constants().TEST_API_KEY })
            p.registry.clear()
            p.login("user1")
            result = p.setAttributes({ dictionary: {} })
            t.assert.isValid(result.error, "Expected error")
            t.assert.equal(result.error.code, 21, "Unexpected error")
            result = p.setAttributes({ date: CreateObject("roDateTime") })
            t.assert.isValid(result.error, "Expected error")
            t.assert.equal(result.error.code, 21, "Unexpected error")
            result = p.setAttributes({ invalid: invalid })
            t.assert.isValid(result.error, "Expected error")
            t.assert.equal(result.error.code, 21, "Unexpected error")
            t.pass()
        end sub)
    end sub)
end function
function customerInfoTests(t)
    t.describe("CustomerInfo Tests", sub(t)
        t.it("Can call getCustomerInfo", sub(t)
            configurePurchases({ t: t })
            t.purchases.registry.clear()
            t.purchases.login("user1")

            result = t.purchases.getCustomerInfo()
            userId = t.purchases.api.getCustomerInfoInputArgs.userId
            t.assert.isTrue(type(userId) = "roString" or type(userId) = "String", "Unexpected user id type")
            t.assert.equal(userId, "user1", "Unexpected user id")

            t.assert.isValid(result, "CustomerInfo result error")
            t.assert.isInvalid(result.error, "Unexpected error")
            assertSubscriberIsValid(t, result.data)
            t.pass()
        end sub)

        t.it("Can parse complex getCustomerInfo", sub(t)
            configurePurchases({ t: t })
            result = t.purchases.getCustomerInfo()
            t.assert.isValid(result, "CustomerInfo result error")
            t.assert.isInvalid(result.error, "Unexpected error")
            assertSubscriberIsValid(t, result.data)
            t.pass()
        end sub)

        t.it("Can set subscriber attributes", sub(t)
            configurePurchases({ t: t })
            t.purchases.registry.clear()
            t.purchases.login("user1")

            result = t.purchases.setAttributes({
                email: "example@example.com"
            })

            userId = t.purchases.api.postSubscriberAttributesInputArgs.userId
            t.assert.isTrue(type(userId) = "roString" or type(userId) = "String", "Unexpected user id type")
            t.assert.equal(userId, "user1", "Unexpected user id")

            t.assert.isValid(result, "CustomerInfo result error")
            t.assert.isInvalid(result.error, "Unexpected error")
            t.assert.equal(result.data, true, "Unexpected data")
            t.pass()
        end sub)

        t.it("Rejects invalid subscriber attributes", sub(t)
            configurePurchases({ t: t })
            t.purchases.registry.clear()
            t.purchases.login("user1")
            result = t.purchases.setAttributes({ dictionary: {} })
            t.assert.isValid(result.error, "Expected error")
            t.assert.equal(result.error.code, 21, "Unexpected error")
            result = t.purchases.setAttributes({ date: CreateObject("roDateTime") })
            t.assert.isValid(result.error, "Expected error")
            t.assert.equal(result.error.code, 21, "Unexpected error")
            result = t.purchases.setAttributes({ invalid: invalid })
            t.assert.isValid(result.error, "Expected error")
            t.assert.equal(result.error.code, 21, "Unexpected error")
            t.pass()
        end sub)
    end sub)
end function
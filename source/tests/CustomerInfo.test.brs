function customerInfoTests(t)
    t.describe("CustomerInfo Tests", sub(t)
        t.beforeEach(sub(t)
            configurePurchases({ t: t })
        end sub)

        t.it("Can call getCustomerInfo", sub(t)
            Purchases().logIn("user1", sub(subscriber, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                assertSubscriberIsValid(m.t, subscriber)
            end sub)

            Purchases().getCustomerInfo(sub(result, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                assertSubscriberIsValid(m.t, result)

                userId = internalTestPurchases().api.getCustomerInfoInputArgs.userId
                m.t.assert.isTrue(type(userId) = "roString" or type(userId) = "String", "Unexpected user id type")
                m.t.assert.equal(userId, "user1", "Unexpected user id")

                m.t.assert.isInvalid(error, "Unexpected error")
                assertSubscriberIsValid(m.t, result)
            end sub)
        end sub)

        t.it("Can parse complex getCustomerInfo", sub(t)
            Purchases().getCustomerInfo(sub(result, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                assertSubscriberIsValid(m.t, result)
            end sub)
        end sub)

        t.it("Includes subscription and non-subscription products in allPurchasedProductIds", sub(t)
            Purchases().getCustomerInfo(sub(result, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                productIds = result.allPurchasedProductIds
                m.t.assert.equal(productIds.Count(), 3, "Unexpected number of product ids")
                m.t.assert.isTrue(arrayContainsString(productIds, "mark_premium"), "Missing subscription product id")
                m.t.assert.isTrue(arrayContainsString(productIds, "upgrade_downgrade:month"), "Missing subscription product id")
                m.t.assert.isTrue(arrayContainsString(productIds, "com.revenuecat.product.tip"), "Missing non-subscription product id")
            end sub)
        end sub)

        t.it("Includes non-subscription products in allPurchasedProductIds without subscriptions", sub(t)
            configurePurchases({
                t: t, api: {
                    getCustomerInfo: function(inputArgs = {})
                        response = subscriberFixture()
                        response.subscriber.entitlements = {}
                        response.subscriber.subscriptions = {}
                        return { data: response }
                    end function,
                }
            })

            Purchases().getCustomerInfo(sub(result, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                productIds = result.allPurchasedProductIds
                m.t.assert.equal(productIds.Count(), 1, "Unexpected number of product ids")
                m.t.assert.isTrue(arrayContainsString(productIds, "com.revenuecat.product.tip"), "Missing non-subscription product id")
                m.t.assert.equal(result.nonSubscriptionTransactions[0].productIdentifier, "com.revenuecat.product.tip", "Unexpected transaction product id")
            end sub)
        end sub)

        t.it("Can set subscriber attributes", sub(t)
            Purchases().logIn("user1", sub(subscriber, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                assertSubscriberIsValid(m.t, subscriber)
            end sub)

            result = Purchases().setAttributes({
                email: "example@example.com"
            }, sub(data, error)
                userId = internalTestPurchases().api.postSubscriberAttributesInputArgs.userId
                m.t.assert.isTrue(type(userId) = "roString" or type(userId) = "String", "Unexpected user id type")
                m.t.assert.equal(userId, "user1", "Unexpected user id")

                m.t.assert.isInvalid(error, "Unexpected error")
                m.t.assert.equal(data, true, "Unexpected data")
            end sub)
        end sub)

        t.it("Rejects invalid subscriber attributes", sub(t)
            Purchases().logIn("user1", sub(subscriber, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                assertSubscriberIsValid(m.t, subscriber)
            end sub)

            result = Purchases().setAttributes({ dictionary: {} }, sub(data, error)
                m.t.assert.isValid(error, "Expected error")
                m.t.assert.equal(error.code, 21, "Unexpected error")
            end sub)

            result = Purchases().setAttributes({ date: CreateObject("roDateTime") }, sub(data, error)
                m.t.assert.isValid(error, "Expected error")
                m.t.assert.equal(error.code, 21, "Unexpected error")
            end sub)

            result = Purchases().setAttributes({ invalid: invalid }, sub(data, error)
                m.t.assert.isValid(error, "Expected error")
                m.t.assert.equal(error.code, 21, "Unexpected error")
            end sub)
        end sub)
    end sub)
end function
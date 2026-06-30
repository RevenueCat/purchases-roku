function PurchaseTests(t)
    t.describe("Purchase Tests", sub(t)
        t.beforeEach(sub(t)
            billing = {
                purchase: function(inputArgs = {})
                    if inputArgs.code <> "product_id"
                        throw "Unexpected product ID"
                    end if
                    return { data: purchasedTransactionFixture() }
                end function,
                getAllPurchases: function()
                    return { data: purchaseHistoryFixture() }
                end function
            }
            configurePurchases({ t: t, billing: billing })
            Purchases().logIn("mark_roku_test", sub(subscriber, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                assertSubscriberIsValid(m.t, subscriber)
            end sub)
        end sub)

        t.it("Can call purchase", sub(t)
            purchase_params = [
                { code: "product_id" },
                { code: "product_id", action: "Upgrade" },
                { code: "product_id", action: "Downgrade" },
                { package: { storeProduct: { code: "product_id" } } },
                { package: { storeProduct: { code: "product_id" } }, action: "Upgrade" },
                { package: { storeProduct: { code: "product_id" } }, action: "Downgrade" },
                { product: { code: "product_id" } },
                { product: { code: "product_id" }, action: "Upgrade" },
                { product: { code: "product_id" }, action: "Downgrade" }
            ]
            for each params in purchase_params
                Purchases().purchase(params, sub(data, error)
                    m.t.assert.isValid(data, "Purchase data error")
                    transaction = data.transaction
                    m.t.assert.isValid(transaction, "Transaction error")

                    subscriber = data.subscriber
                    assertSubscriberIsValid(m.t, subscriber)

                    userId = internalTestPurchases().api.postReceiptInputArgs.userId
                    m.t.assert.isTrue(type(userId) = "roString" or type(userId) = "String", "Unexpected user id type")
                    transaction = internalTestPurchases().api.postReceiptInputArgs.transaction
                    m.t.assert.isValid(transaction, "Transaction error")
                end sub)
            end for

            Purchases().purchase({}, sub(data, error)
                m.t.assert.isValid(error, "Expected error")
                m.t.assert.equal(error.code, internalTestPurchases().errors.purchaseInvalidError.code, "Unexpected error code")
                m.t.assert.equal(error.message, internalTestPurchases().errors.purchaseInvalidError.message, "Unexpected error message")
                m.t.assert.isInvalid(data, "Unexpected data")
            end sub)

            Purchases().purchase({ code: "product_id", action: "Invalid" }, sub(data, error)
                m.t.assert.isValid(error, "Expected error")
                m.t.assert.equal(error.code, internalTestPurchases().errors.purchaseInvalidError.code, "Unexpected error code")
                m.t.assert.equal(error.message, internalTestPurchases().errors.purchaseInvalidError.message, "Unexpected error message")
                m.t.assert.isInvalid(data, "Unexpected data")
            end sub)

            t.pass()
        end sub)

        t.it("Can syncPurchases", sub(t)
            Purchases().syncPurchases(sub(subscriber, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                assertSubscriberIsValid(m.t, subscriber)
                userId = internalTestPurchases().api.postReceiptInputArgs.userId
                m.t.assert.isTrue(type(userId) = "roString" or type(userId) = "String", "Unexpected user id type")
                transaction = internalTestPurchases().api.postReceiptInputArgs.transaction
                m.t.assert.isValid(transaction, "Transaction error")
            end sub)
        end sub)

        t.it("Syncs Roku customer ID as a reserved subscriber attribute after purchase", sub(t)
            Purchases().purchase({ code: "product_id" }, sub(data, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                attributes = internalTestPurchases().api.postSubscriberAttributesInputArgs.attributes
                m.t.assert.equal(attributes["$rokuCustomerId"], data.transaction.rokuCustomerId, "Unexpected Roku customer ID attribute")
            end sub)
        end sub)

        t.it("Syncs the first Roku customer ID as a reserved subscriber attribute during syncPurchases", sub(t)
            purchaseItems = [
                { code: "first_product", purchaseId: "first_purchase" },
                { code: "second_product", purchaseId: "second_purchase", rokuCustomerId: "roku_customer_id" },
                { code: "third_product", purchaseId: "third_purchase", rokuCustomerId: "different_roku_customer_id" },
            ]
            api = mockApi()
            api.postSubscriberAttributesCallCount = 0
            api.postSubscriberAttributes = function(inputArgs = {})
                m.postSubscriberAttributesCallCount++
                m.postSubscriberAttributesInputArgs = inputArgs
                return { data: true }
            end function
            configurePurchases({ t: t, api: api })
            internalTestPurchases().billing.purchases = purchaseItems
            internalTestPurchases().billing.getAllPurchases = function()
                return { data: m.purchases }
            end function

            Purchases().syncPurchases(sub(subscriber, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                m.t.assert.equal(internalTestPurchases().api.postSubscriberAttributesCallCount, 1, "Expected one subscriber attribute update")
                attributes = internalTestPurchases().api.postSubscriberAttributesInputArgs.attributes
                m.t.assert.equal(attributes["$rokuCustomerId"], "roku_customer_id", "Unexpected Roku customer ID attribute")
            end sub)
        end sub)

        t.it("Skips Roku customer ID sync when purchase data does not include a valid string ID", sub(t)
            api = mockApi()
            api.postSubscriberAttributesCallCount = 0
            api.postSubscriberAttributes = function(inputArgs = {})
                m.postSubscriberAttributesCallCount++
                m.postSubscriberAttributesInputArgs = inputArgs
                return { data: true }
            end function
            configurePurchases({ t: t, api: api })

            result = internalTestPurchases().syncRokuCustomerIDAttributeFromTransactions([])
            m.t.assert.isFalse(result.data, "Expected empty purchases to skip attribute sync")

            result = internalTestPurchases().syncRokuCustomerIDAttributeFromTransactions([
                { rokuCustomerId: "" },
                { rokuCustomerId: 12345 },
                { rokuCustomerId: false },
                {},
            ])
            m.t.assert.isFalse(result.data, "Expected invalid Roku customer IDs to skip attribute sync")
            m.t.assert.equal(internalTestPurchases().api.postSubscriberAttributesCallCount, 0, "Expected no subscriber attribute updates")
        end sub)

        t.it("Does not sync duplicate Roku customer ID attributes for the same app user ID", sub(t)
            purchaseItems = [
                { code: "product", purchaseId: "purchase", rokuCustomerId: "roku_customer_id" },
            ]
            api = mockApi()
            api.postSubscriberAttributesCallCount = 0
            api.postSubscriberAttributes = function(inputArgs = {})
                m.postSubscriberAttributesCallCount++
                m.postSubscriberAttributesInputArgs = inputArgs
                return { data: true }
            end function
            configurePurchases({ t: t, api: api })
            internalTestPurchases().billing.purchases = purchaseItems
            internalTestPurchases().billing.getAllPurchases = function()
                return { data: m.purchases }
            end function

            Purchases().syncPurchases(sub(subscriber, error)
                m.t.assert.isInvalid(error, "Unexpected error")
            end sub)
            Purchases().syncPurchases(sub(subscriber, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                m.t.assert.equal(internalTestPurchases().api.postSubscriberAttributesCallCount, 1, "Expected one subscriber attribute update")
            end sub)
        end sub)

        t.it("Re-syncs Roku customer ID attributes after the app user ID changes", sub(t)
            purchaseItems = [
                { code: "product", purchaseId: "purchase", rokuCustomerId: "roku_customer_id" },
            ]
            api = mockApi()
            api.postSubscriberAttributesCallCount = 0
            api.postSubscriberAttributes = function(inputArgs = {})
                m.postSubscriberAttributesCallCount++
                m.postSubscriberAttributesInputArgs = inputArgs
                return { data: true }
            end function
            configurePurchases({ t: t, api: api })
            internalTestPurchases().billing.purchases = purchaseItems
            internalTestPurchases().billing.getAllPurchases = function()
                return { data: m.purchases }
            end function

            Purchases().syncPurchases(sub(subscriber, error)
                m.t.assert.isInvalid(error, "Unexpected error")
            end sub)
            Purchases().logIn("different_user", sub(subscriber, error)
                m.t.assert.isInvalid(error, "Unexpected error")
            end sub)
            Purchases().syncPurchases(sub(subscriber, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                m.t.assert.equal(internalTestPurchases().api.postSubscriberAttributesCallCount, 2, "Expected subscriber attribute update after app user ID change")
                m.t.assert.equal(internalTestPurchases().api.postSubscriberAttributesInputArgs.userId, "different_user", "Unexpected subscriber attribute user ID")
            end sub)
        end sub)

        t.it("Does not fail purchase when Roku customer ID attribute sync fails", sub(t)
            api = mockApi()
            api.postSubscriberAttributes = function(inputArgs = {}) as object
                m.postSubscriberAttributesInputArgs = inputArgs
                return {
                    error: {
                        code: 500,
                        message: "Server error",
                    }
                }
            end function
            configurePurchases({ t: t, api: api })

            Purchases().purchase({ code: "product_id" }, sub(data, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                m.t.assert.isValid(data, "Expected purchase data")
                m.t.assert.isTrue(_PurchasesLogger().hasLoggedMessage("Failed to sync Roku customer ID subscriber attribute"), "Expected warning log")
            end sub)
        end sub)
    end sub)
end function

sub callbackFunc(data, error)
    print "callbackFunc"
    print "data: "; data
    print "error: "; error
end sub

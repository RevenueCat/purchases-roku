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
    end sub)
end function

sub callbackFunc(data, error)
    print "callbackFunc"
    print "data: "; data
    print "error: "; error
end sub
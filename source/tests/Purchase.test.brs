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
            t.purchases.login("mark_roku_test")
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
                result = t.purchases.purchase(params)
                t.assert.isValid(result, "Purchase result error")
                t.assert.isInvalid(result.error, "Unexpected error")
                data = result.data
                t.assert.isValid(data, "Purchase data error")
                transaction = data.transaction
                t.assert.isValid(transaction, "Transaction error")

                subscriber = data.subscriber
                assertSubscriberIsValid(t, subscriber)
            end for

            result = t.purchases.purchase({})
            t.assert.isValid(result, "Purchase result error")
            t.assert.isValid(result.error, "Expected error")
            t.assert.equal(result.error.code, t.purchases.errors.purchaseInvalidError.code, "Unexpected error code")
            t.assert.equal(result.error.message, t.purchases.errors.purchaseInvalidError.message, "Unexpected error message")
            t.assert.isInvalid(result.data, "Unexpected data")

            result = t.purchases.purchase({ code: "product_id", action: "Invalid" })
            t.assert.isValid(result, "Purchase result error")
            t.assert.isValid(result.error, "Expected error")
            t.assert.equal(result.error.code, t.purchases.errors.purchaseInvalidError.code, "Unexpected error code")
            t.assert.equal(result.error.message, t.purchases.errors.purchaseInvalidError.message, "Unexpected error message")
            t.assert.isInvalid(result.data, "Unexpected data")

            t.pass()
        end sub)

        t.it("Can syncPurchases", sub(t)
            result = t.purchases.syncPurchases()
            t.assert.isValid(result, "SyncPurchases result error")
            t.assert.isInvalid(result.error, "Unexpected error")
            assertSubscriberIsValid(t, result.data)
            t.pass()
        end sub)
    end sub)
end function
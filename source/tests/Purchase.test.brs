function PurchaseTests(t)
    t.describe("Purchase Tests", sub(t)
        t.beforeEach(sub(t)
            billing = {
                purchase: function(inputArgs = {})
                    if inputArgs.code <> "product_id"
                        throw "Unexpected product ID"
                    end if
                    return { data: purchasedTransactionFixture() }
                end function
            }
            p = _InternalPurchases({ billing: billing })
            p.configuration.configure({ apiKey: Constants().TEST_API_KEY })
            p.login("mark_roku_test")
            t.addContext({ purchases: p })
        end sub)

        t.it("Can call purchase", sub(t)
            result = t.purchases.purchase({ code: "product_id" })
            result = t.purchases.purchase({ storeProduct: { code: "product_id" } })
            result = t.purchases.purchase("product_id")

            t.assert.isValid(result, "Purchase result error")
            t.assert.isInvalid(result.error, "Unexpected error")

            data = result.data
            t.assert.isValid(data, "Purchase data error")

            transaction = data.transaction
            t.assert.isValid(transaction, "Transaction error")

            subscriber = data.subscriber
            t.assert.isValid(subscriber, "Subscriber error")
            t.assert.isValid(subscriber.entitlements, "Entitlements error")
            t.assert.isValid(subscriber.first_seen, "First seen error")
            t.assert.isValid(subscriber.last_seen, "Last seen error")
            t.assert.isInvalid(subscriber.management_url, "Management URL error")
            t.assert.isValid(subscriber.non_subscriptions, "Non subscriptions error")
            t.assert.isValid(subscriber.original_app_user_id, "Original app user ID error")
            t.assert.isInvalid(subscriber.original_application_version, "Original application version error")
            t.assert.isInvalid(subscriber.original_purchase_date, "Original purchase date error")
            t.assert.isValid(subscriber.other_purchases, "Other purchases error")
            t.assert.isValid(subscriber.subscriptions, "Subscriptions error")
            t.pass()
        end sub)
    end sub)
end function
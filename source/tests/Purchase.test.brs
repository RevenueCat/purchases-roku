function PurchaseTests(t)
    t.describe("Purchase Tests", sub(t)
        billing = {
            purchase: function(inputArgs = {})
                return { transactions: purchasedTransactionFixture() }
            end function
            getProductsByID: function()
            return {
                "monthly_product": {}
                "yearly_subscription_product": {}
            }
            end function
        }
        purchases = _PurchasesSDK({ billing: billing, global: {} })
        purchases.configure({ api_key: "appl_KhXKryBEHUWEdShrggQyjyzHKHW"})
        purchases.login("user1")
        result = purchases.purchase({ code: "monthly_product" })
        print(result)
    end sub)
end function
function customerInfoTests(t)
    t.describe("CustomerInfo Tests", sub(t)
        t.beforeEach(sub(t)
            api = {
                subscriber: subscriber
                identify: identify
                getOfferings: offerings
            }
            billing = {
                getProductsByID: function()
                return {
                    "monthly_product": {}
                    "yearly_subscription_product": {}
                }
                end function
            }
            purchases = _PurchasesSDK({ billing: billing, api: api, global: {} })
            purchases.configure({ api_key: "appl_KhXKryBEHUWEdShrggQyjyzHKHW"})
            purchases.login("user1")

            t.addContext({ purchases: purchases })
        end sub)

        t.it("Can call getCustomerInfo", sub(t)
            result = t.purchases.getCustomerInfo()
        end sub)

        t.it("can call getOfferings", sub(t)
            if t.purchases.getOfferings().current <> invalid
                t.pass()
            else
                t.fail()
            end if
        end sub)
    end sub)
end function
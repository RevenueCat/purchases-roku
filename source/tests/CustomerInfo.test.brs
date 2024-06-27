function customerInfoTests(t)
    t.describe("CustomerInfo Tests", sub(t)
        t.beforeEach(sub(t)
            p = _PurchasesSDK()
            p.configure({ apiKey: Constants().TEST_API_KEY })
            p.login("user1")
            t.addContext({ purchases: p })
        end sub)

        t.it("Can call getCustomerInfo", sub(t)
            result = t.purchases.getCustomerInfo()
            t.assert.isValid(result, "CustomerInfo result error")
            t.assert.isInvalid(result.error, "Unexpected error")
            data = result.data
            t.assert.isValid(data, "CustomerInfo data error")
            t.assert.isValid(data.entitlements, "Entitlements error")
            t.assert.isValid(data.first_seen, "First seen error")
            t.assert.isValid(data.last_seen, "Last seen error")
            t.assert.isInvalid(data.management_url, "Management URL error")
            t.assert.isValid(data.non_subscriptions, "Non subscriptions error")
            t.assert.isValid(data.original_app_user_id, "Original app user ID error")
            t.assert.isInvalid(data.original_application_version, "Original application version error")
            t.assert.isInvalid(data.original_purchase_date, "Original purchase date error")
            t.assert.isValid(data.other_purchases, "Other purchases error")
            t.assert.isValid(data.subscriptions, "Subscriptions error")
            t.pass()
        end sub)
    end sub)
end function
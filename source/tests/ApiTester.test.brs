' function ApiTester(t)
'     t.describe("Purchases API", sub(t)
'         api = {
'             subscriber: subscriber
'             identify: identify
'             getOfferings: offerings
'         }
'         billing = {
'             getProductsByID: function()
'                 return {
'                     "monthly_product": {}
'                     "yearly_subscription_product": {}
'                 }
'             end function
'         }
'         purchases = _InternalPurchases({ billing: billing, api: api, global: {} })
'         purchases.appUserID()
'         purchases.apiKey()
'         purchases.setProxyURL("https://example.com")
'         purchases.proxyURL()
'         purchases.setLogLevel("info")
'         purchases.logLevel()
'         purchases.isAnonymous()
'         purchases.onUpdateCustomerInfo(sub(customerInfo)
'         end sub)
'         purchases.configure({ apiKey: "appl_KhXKryBEHUWEdShrggQyjyzHKHW" })
'         purchases.isConfigured()
'         purchases.login("user1", sub(customerInfo, error, wasCreated)
'         end sub)
'         purchases.logout(sub(customerInfo, error)
'         end sub)
'         purchases.getCustomerInfo({ fetchPolicy: "fetchCurrent" }, sub(customerInfo, error)
'         end sub)
'         purchases.cachedCustomerInfo()
'         purchases.getOfferings(sub(offerings, error)
'         end sub)
'         purchases.cachedOfferings()
'         purchases.getProducts(["productIdentifier"], sub(products, error)
'         end sub)
'         purchases.purchase({ product: {}, action: "upgrade" }, sub(transactions, customerInfo, error, userCancelled)
'         end sub)
'         purchases.purchase({ package: {}, action: "upgrade" }, sub(transactions, customerInfo, error, userCancelled)
'         end sub)
'         purchases.invalidateCustomerInfoCache()
'         purchases.restorePurchases(sub(customerInfo, error)
'         end sub)
'         purchases.syncPurchases(sub(customerInfo, error)
'         end sub)
'         purchases.attribution.setAttributes({
'             foo: "bar"
'         })
'         purchases.attribution.setEmail("email")
'         purchases.attribution.setPhoneNumber("phone")
'         purchases.syncAttributesAndOfferingsIfNeeded(sub(customerInfo, error)
'         end sub)

'     end sub)
' end function
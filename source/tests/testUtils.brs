function configurePurchases(inputArgs = {} as object)
    fixtureProducts = catalogFixture()
    if inputArgs.products <> invalid
        fixtureProducts = inputArgs.products
    end if

    billing = {
        fixtureProducts: fixtureProducts,
        getProductsById: function()
            productsByID = {}
            for each product in m.fixtureProducts
                productsByID[product.code] = product
            end for
            return { data: productsByID }
        end function,
        getAllPurchases: function()
            return { data: purchaseHistoryFixture() }
        end function,
        purchase: function(inputArgs = {})
            return { data: purchasedTransactionFixture() }
        end function,
    }
    p = _InternalPurchases({ billing: billing, log: TestLogger() })

    ' By default, mock the API calls
    if inputArgs.mockApi <> false
        for each item in mockApi().Items()
            p.api[item.key] = item.value
        end for
    end if

    ' Override the implementations of the API object if provided
    if inputArgs.api <> invalid
        for each item in inputArgs.api.Items()
            p.api[item.key] = item.value
        end for
    end if

    p.configuration.configure({ apiKey: Constants().TEST_API_KEY })
    inputArgs.t.addContext({ purchases: p })
end function

function mockApi()
    return {
        getOfferings: function(inputArgs = {}) as object
            m.getOfferingsInputArgs = inputArgs
            return {
                data: offeringsFixture()
            }
        end function,
        postReceipt: function(inputArgs = {}) as object
            m.postReceiptInputArgs = inputArgs
            return {
                data: subscriberFixture()
            }
        end function,
        getCustomerInfo: function(inputArgs = {})
            m.getCustomerInfoInputArgs = inputArgs
            return {
                data: subscriberFixture()
            }
        end function,
        identify: function(inputArgs = {})
            m.identifyInputArgs = inputArgs
            return {
                data: subscriberFixture()
            }
        end function,
        postSubscriberAttributes: function(inputArgs = {})
            m.postSubscriberAttributesInputArgs = inputArgs
            return {
                data: true
            }
        end function,
    }
end function

function assertSubscriberIsValid(t, subscriber)
    t.assert.isValid(subscriber, "Subscriber error")
    t.assert.isValid(subscriber.entitlements, "Entitlements error")
    for each entry in subscriber.entitlements.all.Items()
        entitlement = entry.value
        t.assert.isValid(entitlement.isActive, "Entitlements isActive error")
        t.assert.isValid(entitlement.identifier, "Entitlements identifier error")
        t.assert.isValid(entitlement.willRenew, "Entitlements willRenew error")
        ' t.assert.isValid(entitlement.expirationDate, "Entitlements expirationDate error")
        t.assert.isValid(entitlement.productIdentifier, "Entitlements productIdentifier error")
        t.assert.isValid(entitlement.latestPurchaseDate, "Entitlements latestPurchaseDate error")
        t.assert.isValid(entitlement.originalPurchaseDate, "Entitlements originalPurchaseDate error")
        t.assert.isValid(entitlement.productIdentifier, "Entitlements productIdentifier error")
        t.assert.isValid(entitlement.isSandbox, "Entitlements isSandbox error")
        ' t.assert.isValid(entitlement.ownershipType, "Entitlements ownershipType error")
        t.assert.isValid(entitlement.store, "Entitlements store error")
        t.assert.isValid(entitlement.periodType, "Entitlements periodType error")
        ' t.assert.isValid(entitlement.unsubscribeDetectedAt, "Entitlements unsubscribeDetectedAt error")
        ' t.assert.isValid(entitlement.billingIssueDetectedAt, "Entitlements billingIssueDetectedAt error")
        ' t.assert.isValid(entitlement.productPlanIdentifier, "Entitlements productPlanIdentifier error")
    end for
    t.assert.isValid(subscriber.entitlements, "Entitlements error")
    t.assert.isValid(subscriber.firstSeen, "First seen error")
    t.assert.isValid(subscriber.lastSeen, "Last seen error")
    t.assert.isInvalid(subscriber.managementUrl, "Management URL error")
    t.assert.isValid(subscriber.originalAppUserId, "Original app user ID error")
    ' t.assert.isInvalid(subscriber.originalApplicationVersion, "Original application version error")
    ' t.assert.isInvalid(subscriber.originalPurchaseDate, "Original purchase date error")
    t.assert.isValid(subscriber.allExpirationDatesByProduct, "allExpirationDatesByProduct error")
    t.assert.isValid(subscriber.allPurchaseDatesByProduct, "allPurchaseDatesByProduct error")
    t.assert.isValid(subscriber.allPurchasedProductIds, "allPurchasedProductIds error")
    t.assert.isValid(subscriber.activeSubscriptions, "activeSubscriptions error")
    if subscriber.activeSubscriptions.Count() > 0
        t.assert.isValid(subscriber.latestExpirationDate, "latestExpirationDate error")
    end if
    t.assert.isValid(subscriber.nonSubscriptionTransactions, "nonSubscriptionTransactions error")
    for each transaction in subscriber.nonSubscriptionTransactions
        t.assert.isValid(transaction.isSandbox, "nonSubscriptionTransactions isSandbox error")
        t.assert.isValid(transaction.originalPurchaseDate, "nonSubscriptionTransactions originalPurchaseDate error")
        t.assert.isValid(transaction.purchaseDate, "nonSubscriptionTransactions purchaseDate error")
        t.assert.isValid(transaction.store, "nonSubscriptionTransactions store error")
        t.assert.isValid(transaction.storeTransactionIdentifier, "nonSubscriptionTransactions storeTransactionIdentifier error")
        t.assert.isValid(transaction.transactionIdentifier, "nonSubscriptionTransactions transactionIdentifier error")
        t.assert.isValid(transaction.productIdentifier, "nonSubscriptionTransactions productIdentifier error")
    end for
end function
function assertSubscriberIsValid(t, subscriber)
    t.assert.isValid(subscriber, "Subscriber error")
    t.assert.isValid(subscriber.entitlements, "Entitlements error")
    for each entry in subscriber.entitlements.all.Items()
        entitlement = entry.value
        t.assert.isValid(entitlement.isActive, "Entitlements isActive error")
        t.assert.isValid(entitlement.identifier, "Entitlements identifier error")
        t.assert.isValid(entitlement.isActive, "Entitlements isActive error")
        t.assert.isValid(entitlement.willRenew, "Entitlements willRenew error")
        t.assert.isValid(entitlement.expirationDate, "Entitlements expirationDate error")
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
    for each entry in subscriber.nonSubscriptionTransactions.Items()
        transactions = entry.value
        for each transaction in transactions
            t.assert.isValid(transaction.isSandbox, "nonSubscriptionTransactions isSandbox error")
            t.assert.isValid(transaction.originalPurchaseDate, "nonSubscriptionTransactions originalPurchaseDate error")
            t.assert.isValid(transaction.purchaseDate, "nonSubscriptionTransactions purchaseDate error")
            t.assert.isValid(transaction.store, "nonSubscriptionTransactions store error")
            t.assert.isValid(transaction.storeTransactionIdentifier, "nonSubscriptionTransactions storeTransactionIdentifier error")
            t.assert.isValid(transaction.transactionIdentifier, "nonSubscriptionTransactions transactionIdentifier error")
        end for
    end for
end function
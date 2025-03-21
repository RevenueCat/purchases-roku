function IdentityTests(t)
    t.describe("Identity Tests", sub(t)
        t.beforeEach(sub(t)
            configurePurchases({ t: t })
            t.purchases.registry.clear()
        end sub)

        t.it("Generates anonymous user ids", sub(t)
            t.assert.isTrue(t.purchases.isAnonymous().data, "Expected anonymous user id")
            t.assert.isTrue(t.purchases.appUserId().data.startsWith("$RCAnonymousID:"), "Expected anonymous user id")
            t.pass()
        end sub)

        t.it("Logs in with app user id", sub(t)
            result = t.purchases.login("myappuserid")
            t.assert.isFalse(t.purchases.isAnonymous().data, "Expected non-anonymous user id")
            t.assert.equal(t.purchases.appUserId().data, "myappuserid", "Unexpected user id")

            userId = t.purchases.api.identifyInputArgs.userId
            t.assert.isTrue(type(userId) = "roString" or type(userId) = "String", "Unexpected user id type")
            newUserId = t.purchases.api.identifyInputArgs.newUserId
            t.assert.isTrue(type(newUserId) = "roString" or type(newUserId) = "String", "Unexpected new user id type")
            t.assert.equal(newUserId, "myappuserid", "Unexpected new user id")

            t.assert.isValid(result, "Login result error")
            t.assert.isInvalid(result.error, "Unexpected error")
            assertSubscriberIsValid(t, result.data)
            t.pass()
        end sub)

        t.it("Returns error when using invalid id", sub(t)
            result = t.purchases.login("")
            t.assert.isTrue(t.purchases.isAnonymous().data, "Unxpected non-anonymous user id")
            t.assert.isValid(result, "Login result error")
            t.assert.isValid(result.error, "Expected error")
            t.assert.isInvalid(result.data, "Unexpected data")
            t.assert.equal(result.error.code, t.purchases.errors.invalidAppUserIdError.code, "Unexpected error code")
            t.pass()
        end sub)

        t.it("Log out generates new anonymous id", sub(t)
            t.assert.isTrue(t.purchases.isAnonymous().data, "Expected anonymous user id")
            t.assert.isTrue(t.purchases.appUserId().data.startsWith("$RCAnonymousID:"), "Expected anonymous user id")
            initialAnonymousId = t.purchases.appUserId().data
            t.purchases.login("myappuserid")
            t.assert.isFalse(t.purchases.isAnonymous().data, "Expected non-anonymous user id")
            t.assert.equal(t.purchases.appUserId().data, "myappuserid", "Unexpected user id")
            result = t.purchases.logout()

            t.assert.isTrue(t.purchases.isAnonymous().data, "Expected anonymous user id")
            t.assert.isTrue(t.purchases.appUserId().data.startsWith("$RCAnonymousID:"), "Expected anonymous user id")
            t.assert.notEqual(t.purchases.appUserId().data, initialAnonymousId, "Unexpected user id")

            userId = t.purchases.api.identifyInputArgs.userId
            t.assert.isTrue(type(userId) = "roString" or type(userId) = "String", "Unexpected user id type")
            t.assert.equal(userId, "myappuserid", "Unexpected old user id")
            newUserId = t.purchases.api.identifyInputArgs.newUserId
            t.assert.isTrue(type(newUserId) = "roString" or type(newUserId) = "String", "Unexpected new user id type")

            t.assert.isValid(result, "Logout result error")
            t.assert.isInvalid(result.error, "Unexpected error")
            assertSubscriberIsValid(t, result.data)
            t.pass()
        end sub)
    end sub)
end function
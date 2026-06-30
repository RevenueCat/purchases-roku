function ConfigurationTests(t)
    t.describe("Configuration Tests", sub(t)
        t.beforeEach(sub(t)
            configurePurchases({ t: t })
        end sub)

        t.it("Can be configured with apiKey", sub(t)
            clearConfiguration()

            p = Purchases()
            t.assert.isFalse(p.isConfigured(), "Expected not configured")
            p.configure({ apiKey: Constants().TEST_API_KEY })
            t.assert.isTrue(p.isConfigured(), "Expected configured")
        end sub)

        t.it("Can be configured with apiKey and userId", sub(t)
            clearConfiguration()
            t.assert.isFalse(Purchases().isConfigured(), "Expected not configured")
            Purchases().configure({ apiKey: Constants().TEST_API_KEY, userId: "test_user_id" })
            t.assert.isTrue(Purchases().isConfigured(), "Expected configured")
            Purchases().isAnonymous(sub(result, error)
                m.t.assert.isFalse(result, "Expected non-anonymous user id")
            end sub)
            Purchases().appUserId(sub(result, error)
                m.t.assert.equal(result, "test_user_id", "Unexpected user id")
            end sub)
        end sub)

        t.it("Auto syncs purchases on configure by default", sub(t)
            billing = {
                getAllPurchasesCount: 0,
                getAllPurchases: function()
                    m.getAllPurchasesCount++
                    return { data: purchaseHistoryFixture() }
                end function,
            }
            configurePurchases({ t: t, billing: billing })
            clearConfiguration()

            Purchases().configure({ apiKey: Constants().TEST_API_KEY })

            t.assert.equal(internalTestPurchases().billing.getAllPurchasesCount, 1, "Expected auto sync to fetch purchases")
        end sub)

        t.it("Can disable auto sync purchases on configure", sub(t)
            billing = {
                getAllPurchasesCount: 0,
                getAllPurchases: function()
                    m.getAllPurchasesCount++
                    return { data: purchaseHistoryFixture() }
                end function,
            }
            configurePurchases({ t: t, billing: billing })
            clearConfiguration()

            Purchases().configure({ apiKey: Constants().TEST_API_KEY, autoSyncPurchases: false })

            t.assert.equal(internalTestPurchases().billing.getAllPurchasesCount, 0, "Expected auto sync to be disabled")
        end sub)

        t.it("Auto sync failures do not break configure", sub(t)
            api = {
                postReceipt: function(inputArgs = {})
                    return {
                        error: {
                            code: 500,
                            message: "Server error",
                        }
                    }
                end function,
            }
            configurePurchases({ t: t, api: api })
            clearConfiguration()

            Purchases().configure({ apiKey: Constants().TEST_API_KEY })

            t.assert.isTrue(Purchases().isConfigured(), "Expected configured")
            t.assert.isTrue(_PurchasesLogger().hasLoggedMessage("Auto sync purchases failed"), "Expected auto sync failure to be logged")
        end sub)

        t.it("Throws assertion if used before configuring", sub(t)
            clearConfiguration()

            try
                result = _InternalPurchases().getOfferings()
                t.fail()
            catch e
                t.assert.equal(e.message, "Purchases SDK not configured", "Unexpected error message")
            end try
        end sub)

        t.it("Can configure Proxy", sub(t)
            t.assert.isInvalid(Purchases().proxyUrl(), "Unexpected proxy URL")
            Purchases().setProxyUrl("http://localhost:8080")
            t.assert.equal(Purchases().proxyUrl(), "http://localhost:8080", "Unexpected proxy URL")
        end sub)

        t.it("Can configure LogLevel", sub(t)
            t.assert.equal(Purchases().logLevel(), "info", "Unexpected log level")
            Purchases().setLogLevel("debug")
            t.assert.equal(Purchases().logLevel(), "debug", "Unexpected log level")
        end sub)

        t.it("Can migrate legacy registry data", sub(t)
            Purchases().isAnonymous(sub(result, error)
                m.t.assert.isTrue(result, "Expected anonymous user id")
            end sub)

            legacySection = createObject("roRegistrySection", "RevenueCat")
            legacySection.write("Storage", formatJson({ userId: "test_user_id" }))
            legacySection.flush()

            p = internalTestPurchases()
            p.registry.migrateLegacyData()

            Purchases().isAnonymous(sub(result, error)
                m.t.assert.isFalse(result, "Expected non-anonymous user id")
            end sub)

            Purchases().appUserId(sub(result, error)
                m.t.assert.equal(result, "test_user_id", "Unexpected user id")
            end sub)
        end sub)
    end sub)
end function

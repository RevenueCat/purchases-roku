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
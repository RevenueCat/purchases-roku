function ConfigurationTests(t)
    t.describe("Configuration Tests", sub(t)
        t.beforeEach(sub(t)
            configurePurchases({ t: t })
        end sub)

        t.it("Can be configured with apiKey", sub(t)
            p = Purchases()
            t.assert.isFalse(p.isConfigured(), "Expected not configured")
            p.configure({ apiKey: Constants().TEST_API_KEY })
            t.assert.isTrue(p.isConfigured(), "Expected configured")
        end sub)

        t.it("Throws assertion if used before configuring", sub(t)
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
    end sub)
end function
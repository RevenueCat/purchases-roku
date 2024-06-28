function ConfigurationTests(t)
    t.describe("Configuration Tests", sub(t)
        t.it("Can be configured with apiKey", sub(t)
            result = _InternalPurchases().configure({ apiKey: Constants().TEST_API_KEY })
            t.assert.isValid(result.data, "Expected data")
            t.assert.isInvalid(result.error, "Unexpected error")
        end sub)

        t.it("Throws assertion if used before configuring", sub(t)
            try
                result = _InternalPurchases().getOfferings()
                t.fail()
            catch e
                t.assert.equal(e.message, "Purchases SDK not configured", "Unexpected error message")
            end try
        end sub)

        t.it("Returns an error when missing required fields", sub(t)
            result = _InternalPurchases().configure({})
            t.assert.isValid(result.error, "Expected error")
            t.assert.isInvalid(result.data, "Unexpected data")
        end sub)

        t.it("Returns the correct value from isConfigured", sub(t)
            p = _InternalPurchases()
            t.assert.isFalse(p.configuration.isConfigured(), "Expected not configured")
            p.configure({ apiKey: Constants().TEST_API_KEY })
            t.assert.isTrue(p.configuration.isConfigured(), "Expected configured")
        end sub)
    end sub)
end function
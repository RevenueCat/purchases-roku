function ConfigurationTests(t)
    t.describe("Configuration Tests", sub(t)
        t.it("Fails", sub(t)
            result = _PurchasesSDK({}).configure()
            t.assert.isValid(result, "Configuration error")
        end sub)
    end sub)
end function
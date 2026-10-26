function NetworkTests(t)
    t.describe("Network Tests", sub(t)
        t.beforeEach(sub(t)
            configurePurchases({ t: t, mockApi: false })
            ' Nothing listens on the discard port, so every request fails before receiving an HTTP response
            Purchases().configure({ apiKey: Constants().TEST_API_KEY, proxyUrl: "http://127.0.0.1:9/" })
        end sub)

        t.it("Returns a network error when getCustomerInfo cannot reach the server", sub(t)
            result = {}
            try
                Purchases().getCustomerInfo(sub(data, error)
                    m.networkTestResult = { data: data, error: error }
                end sub)
                result = m.networkTestResult
            catch e
                result = { exception: e.message }
            end try
            assertNetworkError(t, result)
        end sub)

        t.it("Returns a network error when getOfferings cannot reach the server", sub(t)
            result = {}
            try
                Purchases().getOfferings(sub(data, error)
                    m.networkTestResult = { data: data, error: error }
                end sub)
                result = m.networkTestResult
            catch e
                result = { exception: e.message }
            end try
            assertNetworkError(t, result)
        end sub)

        t.it("Returns a network error when logIn cannot reach the server", sub(t)
            result = {}
            try
                Purchases().logIn("network_test_user", sub(data, error)
                    m.networkTestResult = { data: data, error: error }
                end sub)
                result = m.networkTestResult
            catch e
                result = { exception: e.message }
            end try
            assertNetworkError(t, result)
        end sub)
    end sub)
end function

function assertNetworkError(t, result)
    m.networkTestResult = invalid
    t.assert.isInvalid(result.exception, "Unexpected exception")
    t.assert.isInvalid(result.data, "Unexpected data")
    t.assert.isValid(result.error, "Expected error")
    if result.error = invalid then return invalid
    t.assert.equal(result.error.code, 10, "Unexpected error code")
    t.assert.equal(result.error.codeName, "NETWORK_ERROR", "Unexpected error code name")
end function

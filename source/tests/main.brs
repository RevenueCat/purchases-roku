function runTests() as void
    tapInstance = tap()
    tapInstance.version()
    tapInstance.plan(1)
    args = {
        exec: true
        index: 0
        tap: tapInstance
    }

    GetGlobalAA().isRunningRevenueCatTests = true

    suite = roca(args).describe("Tests", sub(t)
        ConfigurationTests(t)
        CustomerInfoTests(t)
        OfferingsTests(t)
        PurchaseTests(t)
        IdentityTests(t)
    end sub)

    if countFailedTests(suite) > 0 then
        throw "Tests failed"
    end if
end function

' Each describe block only counts its own cases, so failures in nested blocks have to be added up
function countFailedTests(suite as object) as integer
    failed = suite.__state.results.failed
    for each child in suite.__state.suites
        failed += countFailedTests(child)
    end for
    return failed
end function

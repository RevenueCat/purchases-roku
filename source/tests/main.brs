function runTests() as void
  tapInstance = tap()
  tapInstance.version()
  tapInstance.plan(1)
  args = {
    exec: true
    index: 0
    tap: tapInstance
  }

  results = roca(args).describe("Tests", sub(t)
    ' CustomerInfoTests(t)
    ' ConfigurationTests(t)
    ' OfferingsTests(t)
    PurchaseTests(t)
    ' ApiTester(t)
  end sub).__state.results

  if results.failed > 0 then
      throw "Tests failed"
  end if
end function

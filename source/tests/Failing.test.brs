function FailingTests(t)
    t.describe("Intentional Failure Tests", sub(t)
        t.it("Fails intentionally to verify CI failure handling", sub(t)
            t.assert.isTrue(false, "Intentional failure to verify CircleCI fails on test failures")
        end sub)
    end sub)
end function

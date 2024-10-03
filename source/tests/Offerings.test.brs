function configurePurchases(inputArgs = {} as object)
    billing = {
        fixtureProducts: inputArgs.products,
        getProductsById: function()
            productsByID = {}
            for each product in m.fixtureProducts
                productsByID[product.code] = product
            end for
            return { data: productsByID }
        end function
    }
    p = _InternalPurchases({ billing: billing, log: TestLogger(), })
    p.configuration.configure({ apiKey: Constants().TEST_API_KEY })
    inputArgs.t.addContext({ purchases: p })
end function

function OfferingsTests(t)
    t.describe("Offerings Tests", sub(t)
        t.it("Can call getOfferings", sub(t)
            configurePurchases({ t: t, products: catalogFixture() })
            result = t.purchases.getOfferings()
            t.assert.isValid(result, "Offerings result error")
            t.assert.isInvalid(result.error, "Unexpected error")
            offerings = result.data
            t.assert.isValid(offerings, "Offerings data error")
            t.assert.isValid(offerings.current, "Current offerings error")
            t.assert.isValid(offerings.current.availablePackages, "Available packages error")
            t.assert.equal(offerings.current.availablePackages.count(), 2, "Available packages count error")

            package = offerings.current.availablePackages[0]

            t.assert.isValid(package, "Available package error")
            t.assert.isValid(package.identifier, "Identifier error")
            t.assert.isValid(package.packageType, "Package type error")
            t.assert.isValid(package.presentedOfferingContext, "Presented offering context error")
            t.assert.isValid(package.presentedOfferingContext.offeringIdentifier, "Presented offering identifier error")
            t.assert.equal(package.presentedOfferingContext.offeringIdentifier, offerings.current.identifier, "Presented offering identifier error")

            product = package.storeProduct
            t.assert.isValid(product, "Product error")
            t.assert.isValid(product.code, "Code error")
            t.assert.isValid(product.cost, "Cost error")
            t.assert.isValid(product.description, "Description error")
            t.assert.isValid(product.freeTrialQuantity, "Free trial quantity error")
            t.assert.isValid(product.freeTrialType, "Free trial type error")
            t.assert.isValid(product.HDPosterUrl, "HD poster URL error")
            t.assert.isValid(product.id, "ID error")
            t.assert.isValid(product.inStock, "In stock error")
            t.assert.isValid(product.name, "Name error")
            t.assert.isValid(product.offerEndDate, "Offer end date error")
            t.assert.isValid(product.offerStartDate, "Offer start date error")
            t.assert.isValid(product.productImagePortrait, "Product image portrait error")
            t.assert.isValid(product.productImageUrl, "Product image URL error")
            t.assert.isValid(product.productType, "Product type error")
            t.assert.isValid(product.qty, "Quantity error")
            t.assert.isValid(product.SDPosterUrl, "SD poster URL error")
            t.assert.isValid(product.trialCost, "Trial cost error")
            t.assert.isValid(product.trialQuantity, "Trial quantity error")
            t.assert.isValid(product.trialType, "Trial type error")

            t.assert.isValid(offerings.all, "All offerings error")
            t.assert.equal(offerings.all.count(), 1, "All offerings count error")

            t.assert.isFalse(t.purchases.log.hasLoggedMessage(t.purchases.strings.FAILED_TO_FETCH_PRODUCTS), "Unexpected error logged")

            t.pass()
        end sub)

        t.it("Logs an error when catalog returns invalid products", sub(t)
            configurePurchases({ t: t, products: wronglyConfiguredCatalogFixture() })
            result = t.purchases.getOfferings()
            t.assert.isTrue(t.purchases.log.hasLoggedMessage(t.purchases.strings.FAILED_TO_FETCH_PRODUCTS), "Expected error not logged")
            t.pass()
        end sub)

        t.it("Placements", sub(t)
            configurePurchases({ t: t, products: catalogFixture() })
            result = t.purchases.getOfferings()
            offerings = result.data
            t.assert.isValid(result.data, "Offerings result error")
            t.assert.isValid(offerings.currentOfferingForPlacement("my_placement"), "Current offering for placement error")
            t.assert.isInvalid(offerings.currentOfferingForPlacement("invalid_placement"), "Unexpected current offering for placement")

            ' Inject a fallback offering id, and a placement whose offering id does not exist
            offerings.placements.fallback_offering_id = "marks-premium"
            offerings.placements.offering_ids_by_placement["valid_placement"] = "invalid_offering"
            ' The valid placement should still return a valid offering
            t.assert.isValid(offerings.currentOfferingForPlacement("my_placement"), "Current offering for placement error")
            ' The inexistent placement should return invalid
            t.assert.isInvalid(offerings.currentOfferingForPlacement("invalid_placement"), "Unexpected current offering for placement")
            ' The placement with the invalid offering id should return the fallback offering
            fallback_offering = offerings.currentOfferingForPlacement("valid_placement")
            t.assert.isValid(fallback_offering, "Unexpected current offering for placement")
            t.assert.equal(fallback_offering.identifier, "marks-premium", "Unexpected current offering for placement")
            t.pass()
        end sub)
    end sub)
end function
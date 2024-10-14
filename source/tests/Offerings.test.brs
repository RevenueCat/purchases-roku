function OfferingsTests(t)
    t.describe("Offerings Tests", sub(t)
        t.beforeEach(sub(t)
            configurePurchases({ t: t })
        end sub)

        t.it("Can call getOfferings", sub(t)
            result = t.purchases.getOfferings()
            t.assert.isValid(result, "Offerings result error")
            t.assert.isInvalid(result.error, "Unexpected error")
            offerings = result.data
            t.assert.isValid(offerings, "Offerings data error")
            t.assert.isValid(offerings.current(), "Current offerings error")
            t.assert.isValid(offerings.current().availablePackages, "Available packages error")
            t.assert.equal(offerings.current().availablePackages.count(), 2, "Available packages count error")

            package = offerings.current().availablePackages[0]

            t.assert.isValid(package, "Available package error")
            t.assert.isValid(package.identifier, "Identifier error")
            t.assert.isValid(package.packageType, "Package type error")
            t.assert.isValid(package.presentedOfferingContext, "Presented offering context error")
            t.assert.isValid(package.presentedOfferingContext.offeringIdentifier, "Presented offering identifier error")
            t.assert.equal(package.presentedOfferingContext.offeringIdentifier, offerings.current().identifier, "Presented offering identifier error")

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
        end sub)

        t.it("Logs an error when catalog returns invalid products", sub(t)
            configurePurchases({ t: t, products: wronglyConfiguredCatalogFixture() })
            result = t.purchases.getOfferings()
            t.assert.isTrue(t.purchases.log.hasLoggedMessage(t.purchases.strings.FAILED_TO_FETCH_PRODUCTS), "Expected error not logged")
        end sub)

        t.it("Returns an invalid offering if the placement does not exist", sub(t)
            offerings = t.purchases.getOfferings().data
            t.assert.isInvalid(offerings.currentOfferingForPlacement("invalid_placement"), "Expected an invalid offering for placement")
        end sub)

        t.it("Returns the fallback offering when the placement exists but its offering id doesnt", sub(t)
            offerings = t.purchases.getOfferings().data
            ' Inject a fallback offering id, and a placement whose offering id does not exist
            offerings._placements.fallback_offering_id = "marks-premium"
            offerings._placements.offering_ids_by_placement["valid_placement"] = "invalid_offering"
            ' The valid placement should still return a valid offering
            t.assert.isValid(offerings.currentOfferingForPlacement("my_placement"), "Expected a valid offering for placement")
            ' The inexistent placement should still return invalid
            t.assert.isInvalid(offerings.currentOfferingForPlacement("invalid_placement"), "Expected an invalid offering for placement")
            ' The placement with the invalid offering id should return the fallback offering
            fallback_offering = offerings.currentOfferingForPlacement("valid_placement")
            t.assert.isValid(fallback_offering, "Expected an invalid offering for placement")
            t.assert.equal(fallback_offering.identifier, "marks-premium", "Expected a valid offering for placement")
        end sub)

        t.it("Sends targeting rules when purchased via offerings.currentOfferingForPlacement", sub(t)
            offerings = t.purchases.getOfferings().data

            placement_offering = offerings.currentOfferingForPlacement("my_placement")
            presentedOfferingContext = placement_offering.annual.presentedOfferingContext
            t.assert.isValid(presentedOfferingContext, "presentedOfferingContext error")
            t.assert.isValid(presentedOfferingContext.targetingRule, "targetingRule error")
            t.assert.isValid(presentedOfferingContext.placementIdentifier, "placementIdentifier error")

            t.purchases.purchase({ package: placement_offering.annual })
            presentedOfferingContext = t.purchases.api.postReceiptInputArgs.presentedOfferingContext
            t.assert.isValid(presentedOfferingContext, "presentedOfferingContext error")
            t.assert.isValid(presentedOfferingContext.targetingRule, "targetingRule error")
            t.assert.isValid(presentedOfferingContext.placementIdentifier, "placementIdentifier error")
        end sub)

        t.it("Sends targeting rules when purchased via offerings.current", sub(t)
            offerings = t.purchases.getOfferings().data

            current_offering = offerings.current()
            presentedOfferingContext = current_offering.annual.presentedOfferingContext
            t.assert.isValid(presentedOfferingContext, "presentedOfferingContext error")
            t.assert.isValid(presentedOfferingContext.targetingRule, "targetingRule error")
            t.assert.isInvalid(presentedOfferingContext.placementIdentifier, "placementIdentifier error")

            t.purchases.purchase({ package: current_offering.annual })
            presentedOfferingContext = t.purchases.api.postReceiptInputArgs.presentedOfferingContext
            t.assert.isValid(presentedOfferingContext, "presentedOfferingContext error")
            t.assert.isValid(presentedOfferingContext.targetingRule, "targetingRule error")
            t.assert.isInvalid(presentedOfferingContext.placementIdentifier, "placementIdentifier error")
        end sub)

        t.it("Does not send targeting rules when purchased via offerings.all", sub(t)
            offerings = t.purchases.getOfferings().data

            offering = offerings.all["marks-premium"]
            presentedOfferingContext = offering.annual.presentedOfferingContext
            t.assert.isValid(presentedOfferingContext, "presentedOfferingContext error")
            t.assert.isInvalid(presentedOfferingContext.targetingRule, "targetingRule error")
            t.assert.isInvalid(presentedOfferingContext.placementIdentifier, "placementIdentifier error")

            t.purchases.purchase({ package: offering.annual })
            presentedOfferingContext = t.purchases.api.postReceiptInputArgs.presentedOfferingContext
            t.assert.isValid(presentedOfferingContext, "presentedOfferingContext error")
            t.assert.isInvalid(presentedOfferingContext.targetingRule, "targetingRule error")
            t.assert.isInvalid(presentedOfferingContext.placementIdentifier, "placementIdentifier error")
        end sub)

        t.it("Sends correct targeting data when fetched via offerings.currentOfferingForPlacement, and then purchased via offerings.all", sub(t)
            offerings = t.purchases.getOfferings().data

            placement_offering = offerings.currentOfferingForPlacement("my_placement")
            presentedOfferingContext = placement_offering.annual.presentedOfferingContext
            t.assert.isValid(presentedOfferingContext, "presentedOfferingContext error")
            t.assert.isValid(presentedOfferingContext.targetingRule, "targetingRule error")
            t.assert.isValid(presentedOfferingContext.placementIdentifier, "placementIdentifier error")

            offering = offerings.all["marks-premium"]
            presentedOfferingContext = offering.annual.presentedOfferingContext
            t.assert.isValid(presentedOfferingContext, "presentedOfferingContext error")
            t.assert.isInvalid(presentedOfferingContext.targetingRule, "targetingRule error")
            t.assert.isInvalid(presentedOfferingContext.placementIdentifier, "placementIdentifier error")

            t.purchases.purchase({ package: offering.annual })
            presentedOfferingContext = t.purchases.api.postReceiptInputArgs.presentedOfferingContext
            t.assert.isValid(presentedOfferingContext, "presentedOfferingContext error")
            t.assert.isInvalid(presentedOfferingContext.targetingRule, "targetingRule error")
            t.assert.isInvalid(presentedOfferingContext.placementIdentifier, "placementIdentifier error")
        end sub)
    end sub)
end function
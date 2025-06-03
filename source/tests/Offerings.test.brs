function OfferingsTests(t)
    t.describe("Offerings Tests", sub(t)
        t.beforeEach(sub(t)
            configurePurchases({ t: t })
        end sub)

        t.it("Can call getOfferings", sub(t)
            Purchases().getOfferings(sub(offerings, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                m.t.assert.isValid(offerings, "Offerings data error")
                m.t.assert.isValid(offerings.current, "Current offerings error")
                m.t.assert.isValid(offerings.current.availablePackages, "Available packages error")
                m.t.assert.equal(offerings.current.availablePackages.count(), 2, "Available packages count err")

                m.getOfferingsCallUserId = internalTestPurchases().api.getOfferingsInputArgs.userId
                m.t.assert.isTrue(type(m.getOfferingsCallUserId) = "roString" or type(userId) = "String", "Unexpected user id type")
                Purchases().appUserId(sub(userId, error)
                    m.t.assert.isInvalid(error, "Unexpected error")
                    m.t.assert.equal(userId, m.getOfferingsCallUserId, "Unexpected user id")
                end sub)

                package = offerings.current.availablePackages[0]

                m.t.assert.isValid(package, "Available package error")
                m.t.assert.isValid(package.identifier, "Identifier error")
                m.t.assert.isValid(package.packageType, "Package type error")
                m.t.assert.isValid(package.presentedOfferingContext, "Presented offering context error")
                m.t.assert.isValid(package.presentedOfferingContext.offeringIdentifier, "Presented offering identifier error")
                m.t.assert.equal(package.presentedOfferingContext.offeringIdentifier, offerings.current.identifier, "Presented offering identifier error")

                product = package.storeProduct
                m.t.assert.isValid(product, "Product error")
                m.t.assert.isValid(product.code, "Code error")
                m.t.assert.isValid(product.cost, "Cost error")
                m.t.assert.isValid(product.description, "Description error")
                m.t.assert.isValid(product.freeTrialQuantity, "Free trial quantity error")
                m.t.assert.isValid(product.freeTrialType, "Free trial type error")
                m.t.assert.isValid(product.HDPosterUrl, "HD poster URL error")
                m.t.assert.isValid(product.id, "ID error")
                m.t.assert.isValid(product.inStock, "In stock error")
                m.t.assert.isValid(product.name, "Name error")
                m.t.assert.isValid(product.offerEndDate, "Offer end date error")
                m.t.assert.isValid(product.offerStartDate, "Offer start date error")
                m.t.assert.isValid(product.productImagePortrait, "Product image portrait error")
                m.t.assert.isValid(product.productImageUrl, "Product image URL error")
                m.t.assert.isValid(product.productType, "Product type error")
                m.t.assert.isValid(product.qty, "Quantity error")
                m.t.assert.isValid(product.SDPosterUrl, "SD poster URL error")
                m.t.assert.isValid(product.trialCost, "Trial cost error")
                m.t.assert.isValid(product.trialQuantity, "Trial quantity error")
                m.t.assert.isValid(product.trialType, "Trial type error")

                m.t.assert.isValid(offerings.all, "All offerings error")
                m.t.assert.equal(offerings.all.count(), 1, "All offerings count error")

                m.t.assert.isFalse(_PurchasesLogger().hasLoggedMessage(internalTestPurchases().strings.FAILED_TO_FETCH_PRODUCTS), "Unexpected error logged")
            end sub)
        end sub)

        t.it("Logs an error when catalog returns invalid products", sub(t)
            configurePurchases({ t: t, products: wronglyConfiguredCatalogFixture() })
            Purchases().getOfferings(sub(offerings, error)
                m.t.assert.isTrue(_PurchasesLogger().hasLoggedMessage(internalTestPurchases().strings.FAILED_TO_FETCH_PRODUCTS), "Expected error not logged")
            end sub)
        end sub)

        t.it("Returns an invalid offering if the placement does not exist", sub(t)
            Purchases().getOfferings(sub(offerings, error)
                Purchases().currentOfferingForPlacement({ offerings: offerings, placementId: "invalid_placement" }, sub(result, error)
                    m.t.assert.isInvalid(error, "Unexpected error")
                    m.t.assert.isInvalid(result, "Expected an invalid offering for placement")
                end sub)
            end sub)
        end sub)

        t.it("Returns an invalid offering if there are no placements", sub(t)
            Purchases().getOfferings(sub(offerings, error)
                ' Renomve the placements
                offerings._placements.offering_ids_by_placement = invalid
                Purchases().currentOfferingForPlacement({ offerings: offerings, placementId: "my_placement" }, sub(result, error)
                    m.t.assert.isInvalid(error, "Unexpected error")
                    m.t.assert.isInvalid(result, "Expected an invalid offering for placement")
                end sub)
            end sub)
        end sub)

        t.it("Returns the fallback offering when the placement exists but its offering id doesnt", sub(t)
            Purchases().getOfferings(sub(offerings, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                m.t.assert.isValid(offerings, "Offerings data error")

                    ' Inject a fallback offering id, and a placement whose offering id does not exist
                offerings._placements.fallback_offering_id = "marks-premium"
                offerings._placements.offering_ids_by_placement["valid_placement"] = "invalid_offering"
                ' The valid placement should still return a valid offering
                Purchases().currentOfferingForPlacement({ offerings: offerings, placementId: "my_placement" }, sub(result, error)
                    m.t.assert.isInvalid(error, "Unexpected error")
                    m.t.assert.isValid(result, "Expected a valid offering for placement")
                end sub)
                ' The inexistent placement should still return invalid
                ' The placement with the invalid offering id should return the fallback offering
                Purchases().currentOfferingForPlacement({ offerings: offerings, placementId: "valid_placement" }, sub(result, error)
                    m.t.assert.isInvalid(error, "Unexpected error")
                    m.t.assert.isValid(result, "Expected an invalid offering for placement")
                    m.t.assert.equal(result.identifier, "marks-premium", "Expected a valid offering for placement")
                end sub)
            end sub)
        end sub)

        t.it("Sends targeting rules when purchased via currentOfferingForPlacement", sub(t)
            Purchases().getOfferings(sub(offerings, error)
                Purchases().currentOfferingForPlacement({ offerings: offerings, placementId: "my_placement" }, sub(placement_offering, error)
                    m.t.assert.isInvalid(error, "Unexpected error")
                    m.t.assert.isValid(placement_offering, "Placement offering error")
                    presentedOfferingContext = placement_offering.annual.presentedOfferingContext
                    m.t.assert.isValid(presentedOfferingContext, "Presented offering context error")
                    m.t.assert.isValid(presentedOfferingContext.targetingRule, "Targeting rule error")
                    m.t.assert.isValid(presentedOfferingContext.placementIdentifier, "Placement identifier error")

                    Purchases().purchase({ package: placement_offering.annual }, sub(data, error)
                        m.t.assert.isInvalid(error, "Unexpected error")
                        m.t.assert.isValid(data, "Purchase data error")
                        presentedOfferingContext = internalTestPurchases().api.postReceiptInputArgs.presentedOfferingContext
                        m.t.assert.isValid(presentedOfferingContext, "Presented offering context error")
                        m.t.assert.isValid(presentedOfferingContext.targetingRule, "Targeting rule error")
                        m.t.assert.isValid(presentedOfferingContext.placementIdentifier, "Placement identifier error")
                    end sub)
                end sub)
            end sub)
        end sub)

        t.it("Sends targeting rules when purchased via offerings.current", sub(t)
            Purchases().getOfferings(sub(offerings, error)
                current_offering = offerings.current
                presentedOfferingContext = current_offering.annual.presentedOfferingContext
                m.t.assert.isValid(presentedOfferingContext, "presentedOfferingContext error")
                m.t.assert.isValid(presentedOfferingContext.targetingRule, "targetingRule error")
                m.t.assert.isInvalid(presentedOfferingContext.placementIdentifier, "placementIdentifier error")

                Purchases().purchase({ package: current_offering.annual }, sub(data, error)
                    m.t.assert.isInvalid(error, "Unexpected error")
                    m.t.assert.isValid(data, "Purchase data error")
                    presentedOfferingContext = internalTestPurchases().api.postReceiptInputArgs.presentedOfferingContext
                    m.t.assert.isValid(presentedOfferingContext, "Presented offering context error")
                    m.t.assert.isValid(presentedOfferingContext.targetingRule, "Targeting rule error")
                    m.t.assert.isInvalid(presentedOfferingContext.placementIdentifier, "Placement identifier error")
                end sub)
            end sub)
        end sub)

        t.it("Does not send targeting rules when purchased via offerings.all", sub(t)
            Purchases().getOfferings(sub(offerings, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                m.t.assert.isValid(offerings, "Offerings data error")

                offering = offerings.all["marks-premium"]
                presentedOfferingContext = offering.annual.presentedOfferingContext
                m.t.assert.isValid(presentedOfferingContext, "Presented offering context error")
                m.t.assert.isInvalid(presentedOfferingContext.targetingRule, "Targeting rule error")
                m.t.assert.isInvalid(presentedOfferingContext.placementIdentifier, "Placement identifier error")

                Purchases().purchase({ package: offering.annual }, sub(data, error)
                    m.t.assert.isInvalid(error, "Unexpected error")
                    m.t.assert.isValid(data, "Purchase data error")
                    presentedOfferingContext = internalTestPurchases().api.postReceiptInputArgs.presentedOfferingContext
                    m.t.assert.isValid(presentedOfferingContext, "Presented offering context error")
                    m.t.assert.isInvalid(presentedOfferingContext.targetingRule, "Targeting rule error")
                    m.t.assert.isInvalid(presentedOfferingContext.placementIdentifier, "Placement identifier error")
                end sub)
            end sub)
        end sub)

        t.it("Sends correct targeting data when fetched via currentOfferingForPlacement, and then purchased via offerings.all", sub(t)
            Purchases().getOfferings(sub(offerings, error)
                m.t.assert.isInvalid(error, "Unexpected error")
                m.t.assert.isValid(offerings, "Offerings data error")

                offering = offerings.all["marks-premium"]
                presentedOfferingContext = offering.annual.presentedOfferingContext
                m.t.assert.isValid(presentedOfferingContext, "Presented offering context error")
                m.t.assert.isInvalid(presentedOfferingContext.targetingRule, "Targeting rule error")
                m.t.assert.isInvalid(presentedOfferingContext.placementIdentifier, "Placement identifier error")

                Purchases().purchase({ package: offering.annual }, sub(data, error)
                    m.t.assert.isInvalid(error, "Unexpected error")
                    m.t.assert.isValid(data, "Purchase data error")
                    presentedOfferingContext = internalTestPurchases().api.postReceiptInputArgs.presentedOfferingContext
                    m.t.assert.isValid(presentedOfferingContext, "Presented offering context error")
                    m.t.assert.isInvalid(presentedOfferingContext.targetingRule, "Targeting rule error")
                    m.t.assert.isInvalid(presentedOfferingContext.placementIdentifier, "Placement identifier error")
                end sub)
            end sub)
        end sub)
    end sub)
end function
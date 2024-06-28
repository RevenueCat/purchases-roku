function OfferingsTests(t)
    t.describe("Offerings Tests", sub(t)
        t.beforeEach(sub(t)
            billing = {
                getProductsByID: function()
                    products = catalogFixture()
                    productsByID = {}
                    for each product in products
                        productsByID[product.code] = product
                    end for
                    return { data: productsByID }
                end function
            }
            p = _InternalPurchases({ billing: billing })
            p.configure({ apiKey: Constants().TEST_API_KEY })
            t.addContext({ purchases: p })
        end sub)

        t.it("Can call getOfferings", sub(t)
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

            t.pass()
        end sub)
    end sub)
end function
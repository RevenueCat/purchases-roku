
function purchasedTransactionFixture() as object
    return [
        {
            amount: "$0.00"
            code: "yearly_subscription_product"
            description: "Yearly Subscription"
            externalCode: ""
            freeTrialQuantity: 0
            freeTrialType: "None"
            name: "Yearly Subscription"
            originalAmount: "0"
            productType: "YearlySub"
            promotionApplied: false
            purchaseId: "444b4a0b-2f3d-11ef-bf96-0a58a9feac4f"
            qty: 1
            replacedOffers: []
            replacedSubscriptionId: ""
            rokuCustomerId: "2b269f06-3e8d-587e-a579-3471303dddf1"
            total: "$0.00"
            trialCost: "$0.99"
            trialQuantity: 1
            trialType: "Years"
        },
        {
            amount: "$0.00"
            code: "monthly_product"
            description: "Monthly Subscription"
            externalCode: ""
            freeTrialQuantity: 1
            freeTrialType: "Days"
            name: "Monthly Subscription"
            originalAmount: "0"
            productType: "MonthlySub"
            promotionApplied: false
            purchaseId: "9778559d-106d-11ef-9900-0a58a9feac35"
            qty: 1
            replacedOffers: []
            replacedSubscriptionId: ""
            rokuCustomerId: "2b269f06-3e8d-587e-a579-3471303dddf1"
            total: "$0.00"
            trialCost: "$0.00"
            trialQuantity: 0
            trialType: "None"
        }
    ]
end function

function purchaseHistoryFixture() as object
    return [
        {
            code: "monthly_product"
            cost: "$0.99"
            description: "Monthly Subscription"
            expirationDate: "2024-05-13T14:40:43"
            freeTrialQuantity: 1
            freeTrialType: "Days"
            HDPosterUrl: ""
            inDunning: "false"
            name: "Monthly Subscription"
            productImagePortrait: ""
            productImageUrl: ""
            productType: "MonthlySub"
            purchaseChannel: "DEVICE"
            purchaseContext: "IAP"
            purchaseDate: "2024-05-12T14:40:43"
            purchaseId: "9778559d-106d-11ef-9900-0a58a9feac35"
            qty: 1
            renewalDate: "2024-05-13T14:40:43"
            SDPosterUrl: ""
            status: "Valid"
            trialCost: "$0.00"
            trialQuantity: 0
            trialType: ""
        },
        {
            code: "one_time_consumable_product"
            cost: "$0.99"
            description: "One Time Consumable"
            expirationDate: ""
            freeTrialQuantity: 0
            freeTrialType: "None"
            HDPosterUrl: ""
            inDunning: "false"
            name: "One Time Consumable"
            productImagePortrait: ""
            productImageUrl: ""
            productType: "Consumable"
            purchaseChannel: "DEVICE"
            purchaseContext: "IAP"
            purchaseDate: "2024-05-04T03:33:21"
            purchaseId: "0c5d0853-09c7-11ef-b983-0a58a9feac5c"
            qty: 1
            renewalDate: ""
            SDPosterUrl: ""
            status: "Valid"
            trialCost: "$0.00"
            trialQuantity: 0
            trialType: ""
        }
        {
            code: "one_time_consumable_product"
            cost: "$0.99"
            description: "One Time Consumable"
            expirationDate: ""
            freeTrialQuantity: 0
            freeTrialType: "None"
            HDPosterUrl: ""
            inDunning: "false"
            name: "One Time Consumable"
            productImagePortrait: ""
            productImageUrl: ""
            productType: "Consumable"
            purchaseChannel: "DEVICE"
            purchaseContext: "IAP"
            purchaseDate: "2024-03-18T21:02:09"
            purchaseId: "c7ccb62d-e56a-11ee-b084-0a58a9feac3f"
            qty: 1
            renewalDate: ""
            SDPosterUrl: ""
            status: "Valid"
            trialCost: "$0.00"
            trialQuantity: 0
            trialType: ""
        },
        {
            code: "one_time_product"
            cost: "$0.99"
            description: "One Time"
            expirationDate: ""
            freeTrialQuantity: 0
            freeTrialType: "None"
            HDPosterUrl: ""
            inDunning: "false"
            name: "One Time"
            productImagePortrait: ""
            productImageUrl: ""
            productType: "NonConsumable"
            purchaseChannel: "DEVICE"
            purchaseContext: "IAP"
            purchaseDate: "2024-03-18T20:35:18"
            purchaseId: "0675f5ac-e567-11ee-a862-0a58a9feac0c"
            qty: 1
            renewalDate: ""
            SDPosterUrl: ""
            status: "Valid"
            trialCost: "$0.00"
            trialQuantity: 0
            trialType: ""
        },
        {
            code: "one_time_product"
            cost: "$0.99"
            description: "One Time"
            expirationDate: ""
            freeTrialQuantity: 0
            freeTrialType: "None"
            HDPosterUrl: ""
            inDunning: "false"
            name: "One Time"
            productImagePortrait: ""
            productImageUrl: ""
            productType: "NonConsumable"
            purchaseChannel: "DEVICE"
            purchaseContext: "IAP"
            purchaseDate: "2024-04-10T23:17:18"
            purchaseId: "785bafbc-f790-11ee-a5fb-0a58a9feac2c"
            qty: 1
            renewalDate: ""
            SDPosterUrl: ""
            status: "Valid"
            trialCost: "$0.00"
            trialQuantity: 0
            trialType: ""
        },
        {
            code: "one_time_consumable_product"
            cost: "$0.99"
            description: "One Time Consumable"
            expirationDate: ""
            freeTrialQuantity: 0
            freeTrialType: "None"
            HDPosterUrl: ""
            inDunning: "false"
            name: "One Time Consumable"
            productImagePortrait: ""
            productImageUrl: ""
            productType: "Consumable"
            purchaseChannel: "DEVICE"
            purchaseContext: "IAP"
            purchaseDate: "2024-05-04T03:32:39"
            purchaseId: "f118496d-09c6-11ef-a93b-0a58a9feac11"
            qty: 1
            renewalDate: ""
            SDPosterUrl: ""
            status: "Valid"
            trialCost: "$0.00"
            trialQuantity: 0
            trialType: ""
        },
        {
            code: "one_time_consumable_product"
            cost: "$0.99"
            description: "One Time Consumable"
            expirationDate: ""
            freeTrialQuantity: 0
            freeTrialType: "None"
            HDPosterUrl: ""
            inDunning: "false"
            name: "One Time Consumable"
            productImagePortrait: ""
            productImageUrl: ""
            productType: "Consumable"
            purchaseChannel: "DEVICE"
            purchaseContext: "IAP"
            purchaseDate: "2024-05-04T03:34:53"
            purchaseId: "43855d49-09c7-11ef-be8e-0a58a9feac54"
            qty: 1
            renewalDate: ""
            SDPosterUrl: ""
            status: "Valid"
            trialCost: "$0.00"
            trialQuantity: 0
            trialType: ""
        }
    ]
end function

function catalogFixture() as object
    return [
        {
            code: "one_time_product"
            cost: "$0.99"
            description: "One Time"
            freeTrialQuantity: 0
            freeTrialType: "None"
            HDPosterUrl: ""
            id: "77b7c0f2-e566-11ee-9cfe-0a58a9feac25"
            inStock: "true"
            name: "One Time"
            offerEndDate: ""
            offerStartDate: ""
            productImagePortrait: ""
            productImageUrl: ""
            productType: "NonConsumable"
            qty: 0
            SDPosterUrl: ""
            trialCost: "$0.00"
            trialQuantity: 0
            trialType: "None"
        },
        {
            code: "yearly_subscription_product"
            cost: "$1.99"
            description: "Yearly Subscription"
            freeTrialQuantity: 0
            freeTrialType: "None"
            HDPosterUrl: ""
            id: "ae80904c-e566-11ee-a5f2-0a58a9feac11"
            inStock: "true"
            name: "Yearly Subscription"
            offerEndDate: ""
            offerStartDate: ""
            productImagePortrait: ""
            productImageUrl: ""
            productType: "YearlySub"
            qty: 0
            SDPosterUrl: ""
            trialCost: "$0.99"
            trialQuantity: 12
            trialType: "Months"
        },
        {
            code: "one_time_consumable_product"
            cost: "$0.99"
            description: "One Time Consumable"
            freeTrialQuantity: 0
            freeTrialType: "None"
            HDPosterUrl: ""
            id: "8774d62d-e566-11ee-96f8-0a58a9feac29"
            inStock: "true"
            name: "One Time Consumable"
            offerEndDate: ""
            offerStartDate: ""
            productImagePortrait: ""
            productImageUrl: ""
            productType: "Consumable"
            qty: 1
            SDPosterUrl: ""
            trialCost: "$0.00"
            trialQuantity: 0
            trialType: "None"
        },
        {
            code: "monthly_product"
            cost: "$0.99"
            description: "Monthly Subscription"
            freeTrialQuantity: 1
            freeTrialType: "Days"
            HDPosterUrl: ""
            id: "9a20a72f-e566-11ee-808c-0a58a9feac3a"
            inStock: "true"
            name: "Monthly Subscription"
            offerEndDate: ""
            offerStartDate: ""
            productImagePortrait: ""
            productImageUrl: ""
            productType: "MonthlySub"
            qty: 0
            SDPosterUrl: ""
            trialCost: "$0.00"
            trialQuantity: 0
            trialType: "None"
        }
    ]
end function

function wronglyConfiguredCatalogFixture() as object
    return [{ code: "PROD1" }, { code: "PROD2" }, { code: "FAILPROD" }]
end function

function subscriberFixture(inputArgs = {}) as object
    return {
        "request_date": "2024-05-12T15:53:53Z",
        "request_date_ms": 1715529233759,
        "subscriber": {
            "entitlements": {
                "premium": {
                    "expires_date": "2023-12-28T18:00:00Z",
                    "grace_period_expires_date": invalid,
                    "product_identifier": "mark_premium",
                    "purchase_date": "2023-12-21T18:00:00Z"
                },
                "lifetime": {
                    "grace_period_expires_date": invalid,
                    "product_identifier": "com.revenuecat.product.tip",
                    "purchase_date": "2023-12-21T18:00:00Z"
                },
            },
            "first_seen": "2023-04-04T23:11:37Z",
            "last_seen": "2024-01-10T16:25:15Z",
            "management_url": invalid,
            "non_subscriptions": {
                "com.revenuecat.product.tip": [
                    {
                        "purchase_date": "2024-02-11T00:03:28Z",
                        "original_purchase_date": "2022-03-10T00:04:28Z",
                        "id": "17459f5ffd",
                        "store_transaction_id": "340001090153260",
                        "store": "app_store",
                        "is_sandbox": false
                    },
                    {
                        "purchase_date": "2022-02-11T00:03:28Z",
                        "original_purchase_date": "2022-03-10T00:04:28Z",
                        "id": "17459f5ff7",
                        "store_transaction_id": "340001090153249",
                        "store": "app_store",
                        "is_sandbox": false
                    },
                ]
            },
            "original_app_user_id": "asdf",
            "original_application_version": "1.0",
            "original_purchase_date": "2013-08-01T07:00:00Z",
            "other_purchases": {},
            "subscriptions": {
                "mark_premium": {
                    "auto_resume_date": invalid,
                    "billing_issues_detected_at": invalid,
                    "expires_date": "2023-12-28T18:00:00Z",
                    "grace_period_expires_date": invalid,
                    "is_sandbox": true,
                    "original_purchase_date": "2023-12-21T18:00:00Z",
                    "ownership_type": "PURCHASED",
                    "period_type": "normal",
                    "purchase_date": "2023-12-21T18:00:00Z",
                    "refunded_at": invalid,
                    "store": "app_store",
                    "store_transaction_id": "0",
                    "unsubscribe_detected_at": invalid
                },
                "upgrade_downgrade": {
                    "auto_resume_date": invalid,
                    "billing_issues_detected_at": invalid,
                    "expires_date": "2023-06-19T09:26:00Z",
                    "grace_period_expires_date": invalid,
                    "is_sandbox": true,
                    "original_purchase_date": "2023-06-19T09:24:54Z",
                    "period_type": "normal",
                    "ownership_type": "PURCHASED",
                    "product_plan_identifier": "month",
                    "purchase_date": "2023-06-19T09:24:54Z",
                    "refunded_at": invalid,
                    "store": "play_store",
                    "store_transaction_id": "GPA.3388-5470-5505-78280",
                    "unsubscribe_detected_at": "2023-06-19T09:26:04Z"
                }
            }
        }
    }
end function

function offeringsFixture(inputArgs = {}) as object
    return {
        "current_offering_id": "marks-premium",
        "offerings": [
          {
            "description": "default",
            "identifier": "marks-premium",
            "metadata": {
              "foo": "bar"
            },
            "packages": [
              {
                "identifier": "$rc_monthly",
                "platform_product_identifier": "monthly_product"
              },
              {
                "identifier": "$rc_annual",
                "platform_product_identifier": "yearly_subscription_product"
              }
            ]
          }
        ],
        "placements": {
          "fallback_offering_id": invalid,
          "offering_ids_by_placement": {
            "my_placement": "marks-premium"
          }
        },
        "targeting": {
          "revision": 10,
          "rule_id": "AK_1qeJfjN"
        }
      }
end function
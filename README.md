Welcome to the RevenueCat Roku SDK.

RevenueCat's Roku support is in its early stages. All feedback and issue reports are welcomed.

Check out our latest documentation on [how to configure products in Roku](https://www.revenuecat.com/docs/getting-started/entitlements/roku-products) and [how to use the Roku SDK](https://www.revenuecat.com/docs/getting-started/installation/roku).

# How to setup your Roku developer account

Follow the [First Steps](https://developer.roku.com/en-gb/docs/developer-program/getting-started/first-steps.md) guide to create a Roku developer account, login to your Roku device and enable developer mode on your Roku device.

# How to setup a channel

Once you have your developer account created, head to the [dashboard](https://developer.roku.com/dev/dashboard)

1. First, [create a new Beta Channel](https://developer.roku.com/en-gb/docs/developer-program/publishing/channel-publishing-guide.md#create-a-channel).
2. Make sure the  Beta Channel is [enabled for billing testing](https://developer.roku.com/en-gb/docs/developer-program/roku-pay/testing/billing-testing.md).
3. Under "Monetization" -> "Test users", [add a test user](https://developer.roku.com/en-gb/docs/developer-program/roku-pay/quickstart/test-users.md) with the email associated to your Roku device. .
4. Under "Monetization" -> "Product", follow the process to submit the tax documents, and after you're approved, [create the products](https://developer.roku.com/en-gb/docs/developer-program/roku-pay/quickstart/in-channel-products.md#adding-a-new-product).

IMPORTANT: Only the "root account user" can test billing on device. If you get added as a collaborator to someone else's developer account, billing testing will not work. You'll need to create your own developer account.

# How to configure a Roku app in RevenueCat

1. Make sure your project has been enabled to create Roku apps. If you're not sure, talk to your RevenueCat contact.
2. Open the RevenueCat dashboard, select your project, and click on "Add app".
3. Select "Roku Store", enter your app's name and the Roku Pay API key you can find in https://developer.roku.com/rpay-web-services
4. Once the app is created, click on the "Roku Server to Server notifications settings", copy the "Roku Push Notification URL" which starts with `https://api.revenuecat.com/v1/incoming-webhooks/roku-pay-jwt-notification` and paste it in the Push notifications URL section on the same page where you found the Roku Pay API key.
5. Click on "Public API Key" and copy over the value which should start with "roku_XXXXXX". You will need it to configure the SDK later.

# How to install the SDK

1. Clone the repository:

```bash
git clone https://github.com/RevenueCat/purchases-roku`
```

2. Copy the `components/purchases` folder into your app's `components` folder.
3. Copy the `source/Purchases.brs` file into your app's `source` folder.
4. Import the SDK in the .xml file of the component where you want to use it:

```xml
<!-- Importing the RevenueCat SDK -->
<script type="text/brightscript" uri="pkg:/source/Purchases.brs" />
```

# How to use the SDK

**Important:** The SDK should be used only from SceneGraph components. Calling it from the main thread or from a Task component is not supported.

## Configuring the SDK

Initialize the SDK with your api key. You typically do this inside the `init()` method of your main scene.

```brightscript
  sub init()
    Purchases().configure({
      "apiKey": "roku_XXXXX",
      "userId": "my_user_id" ' optional, will use an anonymous user id if not provided
    })
  end sub
```

## Callbacks and error handling

In methods of the SDK which perform async operations, you can get the result by passing a sub routine or a callback name.

- The first parameter will contain the result.
- The second parameter will contain an error if there was one, or `invalid` if there wasnt.

**Example:**

```brightscript
sub init()
  Purchases().logIn(my_user_id, sub(subscriber, error)
    if error <> invalid
      print "there was en error"
    else
      print subscriber
    end if
  end sub)

  ' To use a function as callback, pass its name as second parameter
  Purchases().logIn(my_user_id, "onSubscriberReceived")
end sub

sub onSubscriberReceived(e as object)
    data = e.GetData()
    if data.error <> invalid
      print "there was en error"
    else
      print data.result
    end if
end sub
```

## Models

### Subscriber

The subscriber object is returned from different APIs. Here's an example of what it looks like:

```brightscript
{
  activeSubscriptions: ["my_product_id"]
  allExpirationDatesByProduct: {
    "my_product_id": <Component: roDateTime>
  }
  allPurchaseDatesByProduct: {
    "my_product_id": <Component: roDateTime>
  }
  allPurchasedProductIds: ["my_product_id"]
  entitlements: {
    all: {
      billingIssueDetectedAt: invalid
      expirationDate: <Component: roDateTime>
      identifier: "premium"
      isActive: false
      isSandbox: true
      latestPurchaseDate: <Component: roDateTime>
      originalPurchaseDate: <Component: roDateTime>
      ownershipType: "PURCHASED"
      periodType: "normal"
      productIdentifier: "my_product_identifier"
      productPlanIdentifier: invalid
      store: "app_store"
      unsubscribeDetectedAt: invalid
      willRenew: false
    }
    active: {}
  }
  firstSeen: <Component: roDateTime>
  lastSeen: <Component: roDateTime>
  latestExpirationDate: <Component: roDateTime>
  managementUrl: invalid
  nonSubscriptionTransactions: [
    {
        isSandbox: false
        originalPurchaseDate: <Component: roDateTime>
        purchaseDate: <Component: roDateTime>
        store: "roku"
        storeTransactionIdentifier: "XXXXXXX"
        transactionIdentifier: "XXXXXXX"
        productIdentifier: "my_product_id"
    }
  ]
  originalAppUserId: "$RCAnonymousID:XXXXXXXXXXXXXXXX"
  originalApplicationVersion: "1.0"
  originalPurchaseDate: <Component: roDateTime>
  requestDate: <Component: roDateTime>
}
```

### Error

The error model constains two fields: `code` and `message`

```
{
  code: 1234,
  message: "There as an error",
}
```

## Making a purchase

As a parameter to the `purchase()` method, you can pass an associative array containing one of the following values:

- `code`: A string containing the product id.
- `product`: From the `getOfferings` result: e.g. `offerings.current.annual.storeProduct`
- `package`: From the `getOfferings` result: e.g. `offerings.current.annual`

Additionally,you can pass the following optional parameters:

- `action`: To perform a product change. Valid values: `Upgrade` or `Downgrade`

```brightscript
Purchases().purchase({ code: "product_id" }, sub(result, error)
  ' error will be present if the transaction could not be finished
  if error <> invalid
    if result <> invalid and result.userCancelled = true
      print "The user cancelled the purchase"
    end if
    print "The purchase could not be completed"
  else
    ' The raw transaction generated by the purchase
    result.transaction

    ' {
    '     amount: "$0.00"
    '     code: "yearly_subscription_product"
    '     description: "Yearly Subscription"
    '     externalCode: ""
    '     freeTrialQuantity: 0
    '     freeTrialType: "None"
    '     name: "Yearly Subscription"
    '     originalAmount: "0"
    '     productType: "YearlySub"
    '     promotionApplied: false
    '     purchaseId: "00000000-0000-0000-0000-000000000000"
    '     qty: 1
    '     replacedOffers: []
    '     replacedSubscriptionId: ""
    '     rokuCustomerId: "00000000-0000-0000-0000-000000000000"
    '     total: "$0.00"
    '     trialCost: "$0.99"
    '     trialQuantity: 1
    '     trialType: "Years"
    ' }

    ' The subscriber object
    result.subscriber
  end
end sub)
```

## Getting offerigns

```brightscript
Purchases().getOfferings(sub(offerings, error)
  if error <> invalid
    print "There was an error fetching offerings
  else
    ' The offerings object

    ' {
    '   current: {
    '     identifier: "my_id",
    '     metadata: { }, ' Metadata set in the Offering configuration
    '     description: "Offering description",
    '     annual: {}, ' The configured Annual package, if available
    '     monthly: {}, ' The configured Monthly package, if available
    '     ' A list of all available packages
    '     availablePackages: [
    '       {
    '         identifier: "package_identifier",
    '         packageType: "custom",
    '         ' The raw Roku store product
    '         storeProduct: {
    '           code: "yearly_subscription_product"
    '           cost: "$1.99"
    '           description: "Yearly Subscription"
    '           freeTrialQuantity: 0
    '           freeTrialType: "None"
    '           HDPosterUrl: ""
    '           id: "00000000-0000-0000-0000-000000000000"
    '           inStock: "true"
    '           name: "Yearly Subscription"
    '           offerEndDate: ""
    '           offerStartDate: ""
    '           productImagePortrait: ""
    '           productImageUrl: ""
    '           productType: "YearlySub"
    '           qty: 0
    '           SDPosterUrl: ""
    '           trialCost: "$0.99"
    '           trialQuantity: 12
    '           trialType: "Months"
    '         }
    '       }
    '     ],
    '   },
    '   all: {
    '     ' An associative array of all the offerings, keyed by their identifier
    '   }
    ' }
  end if
end sub)
```

You can also retrieve the current offering for a placement identifier. Use this to access offerings defined by targeting placements configured in the RevenueCat dashboard:

```brightscript
Purchases().getOfferings(sub(offerings, error)
  if error <> invalid
    print "There was an error fetching offerings
  else
    my_offering = Purchases().currentOfferingForPlacement({offerings: offerings, placementId: "my_placement" })
  end if
end sub)
```

## Subscriber logIn and logOut

```brightscript
' subscriber: The new user subscriber info
' error: Will be present if there was an error during the process
Purchases().logIn("my_user_id", sub(subscriber, error)
end sub)

' Calling logOut generated a new anonymous user
' subscriber: The new anonymous user subscriber info
' error: Will be present if there was an error during the process
Purchases().logOut(sub(subscriber, error)
end sub)
```

## Getting the current App User ID, and checking if the current user is anonymous

' Both callback and synchronous methods are available.

```brightscript
' isAnonymous: boolean indicating whether the current user is anonymous
Purchases().isAnonymous(sub(isAnonymous, error)
end sub)
isAnonymous = Purchases().isAnonymous()

' appUserId: string representing the current user ID, can be anonymous
Purchases().appUserId(sub(appUserId, error)
end sub)
appUserId = Purchases().appUserId()
```

## Getting customer info

```brightscript
' subscriber: The current subscriber info
' error: Will be present if there was an error during the process
Purchases().getCustomerInfo(sub(subscriber, error)
end sub)
```

## Set subscriber attributes

```brightscript
' success: Will be true if the attributes were successfully synchronized
' error: Will be present if there was an error during the process
Purchases().setAttributes({ "my attribute": "my value" }, sub(success, error)
end sub)
```

## Sync Purchases

This method will post all purchases associated with the current Roku account to RevenueCat and become associated with the current User ID.
It should only be used if you're migrating from using your own Roku Pay implementation and want to track previous purchases in RevenueCat

```brightscript
' subscriber: The current subscriber info
' error: Will be present if there was an error during the process
Purchases().syncPurchases(sub(subscriber, error)
end sub)
```

## Tying everything together

For most apps, the usage of the SDK would look like this:

1. Initialise the SDK
2. Log in the user
4. Check if the entitlement is active
5. Fetch offerings and show your paywall UI
6. Make a purchase

```brightscript
sub init()
  ' Initialize the SDK
  Purchases().configure({
      "apiKey": "roku_XXXXX",
      "userId": "my_user_id" ' optional, will use an anonymous user id if not provided
  })
  ' Login the user
  Purchases().logIn(m.my_user_id, sub(subscriber, error)
      if error = invalid
        ' If my entitlement is not active, fetch offerings to show the paywall
        if subscriber.entitlements.my_entitlement.isActive = false
          fetchOfferings()
        end if
      end if
  end sub)
end sub

sub fetchOfferings()
  Purchases().getOfferings(sub(offerings, error)
    if error = invalid
      ' Use offerings to build your paywall UI.
      ' Then call purchaseProduct with the one selected by the user
      purchaseProduct(offerings.current.annual)
    end if
  end sub)
end sub

' Call purchaseProduct when the user decides to initiate a purchase
sub purchaseProduct(product)
  Purchases().purchase(product, sub(result, error)
    if error = invalid
      print "Purchase successful"
      print result.transaction
      print result.subscriber
    end if
  end sub)
end sub
```

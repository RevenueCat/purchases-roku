# Purchases Roku

Welcome to the RevenueCat Roku SDK.

# How to use

```brightscript
    ' Initialize the SDK with your api key
    Purchases().configure({ "api_key": "1234" })

    ' Call sync purchase with each ContentNode returned from getAllPurchases
    ' https://developer.roku.com/en-gb/docs/references/scenegraph/control-nodes/channelstore.md#getallpurchases
    for each productCode in purchaseData
      Purchases().syncPurchase(purchaseData[productCode])
    end for
```

# How to setup your Roku developer account

Follow the [First Steps](https://developer.roku.com/en-gb/docs/developer-program/getting-started/first-steps.md) guide to create a Roku developer account, login to your Roku device and enable developer mode.

# How to setup a channel

Once you have your developer account created, head to the [dashboard](https://developer.roku.com/dev/dashboard)

1- Create a new Beta Channel
2- Make sure the  Beta Channel is [enabled for billing testing](https://developer.roku.com/en-gb/docs/developer-program/roku-pay/testing/billing-testing.md).
3- Under "Monetization" -> "Test users", add your user email address.
4- Under "Monetization" -> "Product", follow the process to submit the tax documents, and after you're approved, create the test products.

IMPORTANT: Only the "root account user" can test billing on device. If you get added as a collaborator to someone else's developer account, billing testing will not work. You'll need to create your own developer account.

# How to run the sample app

1- Install the [BrightScript Language VSCode extension](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript)
2- Duplicate the `.env.sample` file and rename it to `.env`
3- Set the IP address and dev password of your Roku device. You can see all automatically detected Roku devices in the "BRS" tab in VS Code. Make sure your computer and the Roku device are connected to the same network.
4- Open the "Run and debug" and click the "play" button to install and run the app in your Roku device.

# Troubleshooting

If you see products called "Product 1", "Product 2", it's possible you have not logged in to your Roku device with a "root account user", your channel is not selected as "billing test", or the products are not conrrectly configured.
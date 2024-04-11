function Purchases() as object
    if GetGlobalAA().rc_purchasesSingleton = invalid then
        print("Creating Purchases singleton")
        task = createObject("roSGNode", "PurchasesTask")
        GetGlobalAA().rc_purchasesSingleton = {
            configure: _Purchases_configure,
            syncPurchase: _Purchases_syncPurchase,
            _task: task,
        }
    end if
    return GetGlobalAA().rc_purchasesSingleton
end function

function _Purchases_getSingleton() as object
    return GetGlobalAA().rc_purchasesSingleton
end function

sub _Purchases_configure(config as Object)
    print "Configuring Purchases: "; config
    _Purchases_getSingleton().config = config
end sub

sub _Purchases_syncPurchase(purchase as object)
    _Purchases_getSingleton()._task["api"] = {
        "method": "syncPurchase",
        data: {
            "purchase": purchase
        }
    }
end sub
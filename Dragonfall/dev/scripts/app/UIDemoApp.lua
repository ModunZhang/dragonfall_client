
require("config")
require("framework.init")
require("framework.shortcodes")
require("framework.cc.init")

local Store
if device.platform == 'ios' then
    Store = import(".Store")
elseif device.platform == 'android' then
    Store = import(".Store-Android")
end

local UIDemoApp = class("UIDemoApp", cc.mvc.AppBase)

if device.platform == "ios" then
elseif device.platform == "android" then
    --todo
end


function UIDemoApp:ctor()
    UIDemoApp.super.ctor(self)
    cc.FileUtils:getInstance():addSearchPath("res/animations")
    self.scenes_ = {
        "TestUILabelFont",
        "TestBaseScene",
        "TestTexture",
        "TestCocostuido",
        -- "TestUIPageViewScene",
        -- "TestUIListViewScene",
        -- "TestUIScrollViewScene",
        -- "TestUIImageScene",
        -- "TestUIButtonScene",
        -- "TestUISliderScene",
    }
    if device.platform == 'android' then
        table.insert(self.scenes_,"TestETCNode")
    end
end

function UIDemoApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    self:enterNextScene()
end

function UIDemoApp:enterScene(sceneName, ...)
    self.currentSceneName_ = sceneName
    UIDemoApp.super.enterScene(self, sceneName, ...)
end

function UIDemoApp:enterNextScene()
    local index = 1
    while index <= #self.scenes_ do
        if self.scenes_[index] == self.currentSceneName_ then
            break
        end
        index = index + 1
    end
    index = index + 1
    if index > #self.scenes_ then index = 1 end
    self:enterScene(self.scenes_[index])
end

function UIDemoApp:createTitle(scene, title)
    cc.ui.UILabel.new({text = "-- " .. title .. " --", size = 24, color = display.COLOR_BLACK})
        :align(display.CENTER, display.cx, display.top - 20)
        :addTo(scene)
end

function UIDemoApp:createGrid(scene)
    display.newColorLayer(cc.c4b(255, 255, 255, 255)):addTo(scene)

    for y = display.bottom, display.top, 40 do
        display.newLine(
            {{display.left, y}, {display.right, y}},
            {borderColor = cc.c4f(0.9, 0.9, 0.9, 1.0)})
        :addTo(scene)
    end

    for x = display.left, display.right, 40 do
        display.newLine(
            {{x, display.top}, {x, display.bottom}},
            {borderColor = cc.c4f(0.9, 0.9, 0.9, 1.0)})
        :addTo(scene)
    end

    display.newLine(
        {{display.left, display.cy + 1}, {display.right, display.cy + 1}},
        {borderColor = cc.c4f(1.0, 0.75, 0.75, 1.0)})
    :addTo(scene)

    display.newLine(
        {{display.cx, display.top}, {display.cx, display.bottom}},
        {borderColor = cc.c4f(1.0, 0.75, 0.75, 1.0)})
    :addTo(scene)
end

function UIDemoApp:createNextButton(scene)
    cc.ui.UIPushButton.new("NextButton.png")
        :onButtonPressed(function(event)
            event.target:setScale(1.2)
        end)
        :onButtonRelease(function(event)
            event.target:setScale(1.0)
        end)
        :onButtonClicked(function(event)
            self:enterNextScene()
        end)
        :align(display.RIGHT_BOTTOM, display.right - 20, display.bottom + 20)
        :addTo(scene)
end

function HDrawRect(rect, parent, color)
    local left, bottom, width, height = rect.x, rect.y, rect.width, rect.height
    local points = {
        {left, bottom},
        {left + width, bottom},
        {left + width, bottom + height},
        {left, bottom + height},
        {left, bottom},
    }
    local box = display.newPolygon(points, {borderColor = color})
    parent:addChild(box)
end

function UIDemoApp:getFontFilePath()
    return "Droid Sans Fallback.ttf"
end


-- Store
------------------------------------------------------------------------------------------------------------------
function UIDemoApp:getStore()
    if device.platform == 'ios' then
        if not cc.storeProvider then
            Store.init(handler(self, self.transactionObserver))
        end
        return Store
    elseif device.platform == 'android' then
        if not cc.storeProvider then
            Store.init(handler(self, self.verifyGooglePlayPurchase),handler(self, self.transitionFailedInGooglePlay))
        end
        return Store
    end
end

-- android
--------------------
function UIDemoApp:verifyGooglePlayPurchase(orderId,purchaseData,signature)
    print("verifyGooglePlayPurchase---->",orderId,purchaseData,signature)
    local transaction = Store.getTransactionDataWithPurchaseData(purchaseData)
    local info = DataUtils:getIapInfo(transaction.productIdentifier)
    device.hideActivityIndicator()
    if true then --TODO: verify v3 in server 
        Store.finishTransaction(transaction)
        device.showAlert("提示","购买成功",{"确定"})
    end

end
function UIDemoApp:transitionFailedInGooglePlay()
    print("transitionFailedInGooglePlay---->")
    device.hideActivityIndicator()
end
-- iOS
--------------------
function UIDemoApp:transactionObserver(event)
    print("transactionObserver------>")
    local transaction = event.transaction
    local transaction_state = transaction.state
    if transaction_state == 'restored' then
        device.showAlert("提示","已为你恢复以前的购买",{"确定"})
        Store.finishTransaction(transaction)
        device.hideActivityIndicator()
    elseif transaction_state == 'purchased' then
         device.showAlert("提示","购买成功",{"确定"})
         Store.finishTransaction(transaction)
    elseif transaction_state == 'purchasing' then
        --不作任何处理
        device.hideActivityIndicator()
    else
        Store.finishTransaction(transaction)
        device.hideActivityIndicator()
    end
end


function UIDemoApp:getCommonButton(text)
    return  cc.ui.UIPushButton.new({ normal = "Button01.png",
    pressed = "Button01Pressed.png",
    disabled = "Button01Disabled.png",}, {scale9 = true})
        :setButtonSize(240, 60)
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = text,
            size = 18
        }))
end

function UIDemoApp:onEnterBackground()
    print("---- Game onEnterBackground ----")
end

function UIDemoApp:onEnterForeground()
    print("---- Game onEnterForeground ----")
end

return UIDemoApp

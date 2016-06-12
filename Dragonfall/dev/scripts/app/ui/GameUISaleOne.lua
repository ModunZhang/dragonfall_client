--
-- Author: Kenny Dai
-- Date: 2016-05-17 14:57:47
--
local UIPageView = import(".UIPageView")
local UIListView = import(".UIListView")
local Localize_item = import("..utils.Localize_item")
local Localize = import("..utils.Localize")
local WidgetPushButton = import("..widget.WidgetPushButton")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local UILib = import(".UILib")
local UIAutoClose = import('.UIAutoClose')
local GameUISaleOne = class('GameUISaleOne', UIAutoClose)
local window = import("..utils.window")
function GameUISaleOne:ctor()
    GameUISaleOne.super.ctor(self)
end

function GameUISaleOne:onEnter()
    GameUISaleOne.super.onEnter(self)
    local body = display.newSprite("background_640x824.png"):align(display.TOP_CENTER, window.cx, window.top - 70)
    self.body = body
    self:addTouchAbleChild(body)

    self:CreateSalesBox()
    self:CreateInfo()
    self:RefreshInfo()
    self.pv:gotoPage(math.random(4))

    local close_btn = WidgetPushButton.new({normal = "x_btn_up_48x48.png",pressed = "x_btn_down_48x48.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:LeftButtonClicked()
            end
        end):align(display.RIGHT_CENTER, 620,606):addTo(body)

    scheduleAt(self, function()
        if self.pv then
            local cur_index = self.pv:getCurPageIdx()
            for i,item in ipairs(self.pv.items_) do
                local content_node = item.content_node
                local pro_data,leftTime = DataUtils:GetProductAndLeftTimeByIndex(i)
                if pro_data.name ~= content_node.pro_data.name then
                    self:CreateSalesBox()
                    self.pv:gotoPage(cur_index)
                    self:RefreshInfo()
                else
                    content_node.leftTime:setString(GameUtils:formatTimeStyle1(leftTime))
                end
            end
        end
    end)
end

function GameUISaleOne:onExit()
    
    GameUISaleOne.super.onExit(self)
end
function GameUISaleOne:CreateSalesBox()
    if self.pv then
        self.pv:removeFromParent()
        self.pv = nil
    end
    local body = self.body
    local b_size = body:getContentSize()
    local pv = UIPageView.new {
        viewRect = cc.rect(36 , 606 , 556 , 218),
        row = 1,
        padding = {left = 0, right = 0, top = 10, bottom = 0},
        nBounce = true,
        continuous_touch = true
    }
    pv:onTouch(function (event)
        if event.name == "pageChange" then
            self:RefreshInfo()
        end
    end):addTo(body)
    local lessTime = math.huge
    for i=1,4 do
        local item = pv:newItem()
        local pro_data,leftTime = DataUtils:GetProductAndLeftTimeByIndex(i)
        if lessTime > leftTime then
            lessTime = leftTime
        end
        local content_node = self:GetSalesItem(pro_data,leftTime):pos(278,109)
        item.content_node = content_node
        item:addChild(content_node)
        pv:addItem(item)
    end
    pv:reload()
    self.pv = pv
end
function GameUISaleOne:GetSalesItem(pro_data,leftTime)
    local content_node = display.newSprite(UILib.promotion_items[pro_data.name]):pos(278,109)
    local x,y
    if pro_data.name == "promotion_product_1_1" or
        pro_data.name == "promotion_product_4_1" then
        x,y = 110 , 90
    elseif pro_data.name == "promotion_product_2_1" or
        pro_data.name == "promotion_product_1_2" or
        pro_data.name == "promotion_product_3_2" or
        pro_data.name == "promotion_product_4_2" then
        x,y = 140 , 100
    elseif pro_data.name == "promotion_product_2_2" or
        pro_data.name == "promotion_product_3_1" then
        x,y = 100 , 90
    end
    self:CreateNumberImageNode__(""..(pro_data.promotionPercent * 100).."%"):align(display.CENTER, x,y):addTo(content_node)
    content_node.leftTime = UIKit:ttfLabel({
        text = GameUtils:formatTimeStyle1(leftTime),
        size = 26,
        color = 0x60ff00
    }):align(display.CENTER, x, y - 52):addTo(content_node)
    content_node.pro_data = pro_data
    return content_node
end
function GameUISaleOne:CreateNumberImageNode__(string)
    local number_node = display.newNode()
    number_node.string = string
    function number_node:SetNumString(params)
        local text = tolua.type(params) == "string" and params or self.params.text or ""
        assert(tolua.type(text) == "string")
        self:removeAllChildren()
        local x = 0
        local node_width = 0
        for i=1,string.len(text) do
            local replace_key
            local num_string = string.sub(text,i,i)
            if num_string == "." then
                replace_key = "point"
            elseif num_string == "%" then
                replace_key = "percent"
            else
                replace_key = num_string
            end
            local num_sprite =display.newSprite(string.format("number_%s.png",replace_key)):addTo(self)
            x = x + (i == 1 and num_sprite:getContentSize().width/2 or num_sprite:getContentSize().width)
            num_sprite:pos(x + ((replace_key == "point") and 6 or 0),15)
            if i == string.len(text) then
                node_width = x + num_sprite:getContentSize().width/2
            end
        end
        self:setContentSize(cc.size(node_width,30))
    end
    number_node:SetNumString(string)
    return number_node
end
function GameUISaleOne:CreateInfo()
    local body = self.body
    local b_size = body:getContentSize()

    local currentPageNode = display.newNode()
    currentPageNode:setContentSize(cc.size(84,18))
    currentPageNode:align(display.CENTER, b_size.width/2, 616):addTo(body)
    local parent = self
    function currentPageNode:InitPageNode(current_page)
        self:removeAllChildren()
        for i=1,4 do
            display.newSprite(current_page == i and "icon_page_1.png" or "icon_page_2.png"):align(display.LEFT_CENTER, (i - 1) * 20, 11):addTo(self)
        end
    end
    self.currentPageNode = currentPageNode

    self.box_name = UIKit:ttfLabel({
        text = "",
        size = 30,
        color = 0xfed36c
    }):align(display.CENTER, b_size.width/2, 574):addTo(body)
    local gem_icon = display.newSprite("gem_icon_62x61.png"):align(display.CENTER, 248, 490):addTo(body)
    self.gem_price = UIKit:ttfLabel({
        text = "",
        size = 36,
        color = 0xffd200
    }):align(display.CENTER, b_size.width/2 + 20, 494):addTo(body)
    local list = UIListView.new({
        -- bgColor = UIKit:hex2c4b(0x7a10ff00),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(135,174,366,272),
    }):addTo(body)
    self.reward_list = list

    local buy_btn = WidgetPushButton.new({normal = 'tmp_button_battle_up_234x82.png',pressed = 'tmp_button_battle_down_234x82.png'},{scale9 = true})
        :addTo(body)
        :pos(b_size.width/2,120)
        :onButtonClicked(function()
            self:OnBuyButtonClicked()
        end)
        :setButtonSize(226,72)
    display.newSprite("icon_arrow_18x18.png"):addTo(buy_btn)
    display.newSprite("icon_x_70x20.png"):addTo(buy_btn,2):pos(-45,0)
    self.original_cost = UIKit:ttfLabel({
        text = "$ 4.99",
        size = 22,
        color = 0xadacac,
        shadow = true
    }):align(display.RIGHT_CENTER, -20,0):addTo(buy_btn)
    self.current_price = UIKit:ttfLabel({
        text = "$ 1.99",
        size = 22,
        color = 0xffedae,
        shadow = true
    }):align(display.LEFT_CENTER, 12,0):addTo(buy_btn)
end
function GameUISaleOne:RefreshInfo()
    local curIndex = self.pv:getCurPageIdx()
    self.currentPageNode:InitPageNode(curIndex)
    local pro_data,leftTime = DataUtils:GetProductAndLeftTimeByIndex(curIndex)
    self.box_name:setString(Localize.promotion_items[pro_data.name])
    self.gem_price:setString(string.formatnumberthousands(pro_data.gem))

    self.original_cost:setString("$"..string.format("%.2f",pro_data.price * pro_data.promotionPercent))
    self.current_price:setString("$"..pro_data.price)

    local list = self.reward_list
    list:removeAllItems()
    local rewards = string.split(pro_data.rewards, ",")
    table.insert(rewards, 1,pro_data.allianceRewards)
    for i,v in ipairs(rewards) do
        local re_data = string.split(v, ":")
        local item = list:newItem()
        local item_width,item_height = 366, 70
        item:setItemSize(item_width,item_height)
        local content = display.newNode()
        content:setContentSize(cc.size(item_width,item_height))
        local reward_bg = display.newSprite("box_118x118.png"):align(display.LEFT_CENTER, 0, item_height/2):addTo(content):scale(50/118)
        local sp = display.newSprite(UIKit:GetItemImage(re_data[1],re_data[2]),59,59):addTo(reward_bg)
        local size = sp:getContentSize()
        sp:scale(90/math.max(size.width,size.height))
        UIKit:ttfLabel({
            text = i==1 and string.format(_("赠送给联盟成员的%s"),Localize_item.item_name[re_data[2]]) or Localize_item.item_name[re_data[2]] or Localize.soldier_name[re_data[2]],
            size = 20,
            color = 0xfed36c,
        }):addTo(content):align(display.LEFT_CENTER, 60,item_height/2)
        UIKit:ttfLabel({
            text = re_data[3] ,
            size = 20,
            color = 0xfed36c,
        }):addTo(content):align(display.RIGHT_CENTER, 360,item_height/2)
        item:addContent(content)
        list:addItem(item)
    end
    list:reload()
end
function GameUISaleOne:OnBuyButtonClicked()
    local curIndex = self.pv:getCurPageIdx()
    local pro_data,leftTime = DataUtils:GetProductAndLeftTimeByIndex(curIndex)
    local productId = pro_data.productId
    device.showActivityIndicator()
    if device.platform == 'android' and not ext.paypal.isPayPalSupport() and  not app:getStore().canMakePurchases() then
        UIKit:showMessageDialog(_("错误"),_("Google Play商店暂时不能购买,请检查手机Google Play商店的相关设置"))
        return
    end
    if device.platform == 'android' and ext.paypal.isPayPalSupport() then
        ext.paypal.buy(UIKit:getIapPackageName(productId),productId,tonumber(string.format("%.2f",pro_data.price)))
    else
        app:getStore().purchaseWithProductId(productId,1)
    end
end
return GameUISaleOne






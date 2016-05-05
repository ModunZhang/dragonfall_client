--
-- Author: Kenny Dai
-- Date: 2015-04-08 11:13:41
--
local WidgetPushButton = import(".WidgetPushButton")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local WidgetAutoOrder = class("WidgetAutoOrder", function ()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    return node
end)
-- 缩进类型
WidgetAutoOrder.ORIENTATION = {
    LEFT_TO_RIGHT = 1,
    RIGHT_TO_LEFT = 2,
    TOP_TO_BOTTOM = 3,
    BOTTOM_TO_TOP = 4,
}
function WidgetAutoOrder:ctor(order_type,default_gap,not_need_order)
    self.order_type = order_type
    self.not_need_order = not_need_order
    self.default_gap = default_gap or 0
    self.element_table = {}
end

function WidgetAutoOrder:AddElement(element)
    assert(element.CheckVisible)
    assert(element.GetElementSize)
    self:Insert(element)
    element:addTo(self):pos(0,0):hide()
end
-- 刷新
function WidgetAutoOrder:RefreshOrder()
    local gap = 0
    for i,v in ipairs(self.element_table) do
        if not self.not_need_order then
            v:setVisible(v:CheckVisible())
            if self.order_type == WidgetAutoOrder.ORIENTATION.BOTTOM_TO_TOP then
                v:setPositionY(gap)
                gap = gap + v:GetElementSize().height/2 + self.default_gap
            elseif self.order_type == WidgetAutoOrder.ORIENTATION.TOP_TO_BOTTOM then
                v:setPositionY(gap)
                gap = gap - v:GetElementSize().height/2 - self.default_gap
            elseif self.order_type == WidgetAutoOrder.ORIENTATION.LEFT_TO_RIGHT then
                v:setPositionX(gap)
                gap = gap + v:GetElementSize().width/2 + self.default_gap
            elseif self.order_type == WidgetAutoOrder.ORIENTATION.RIGHT_TO_LEFT then
                v:setPositionX(gap)
                gap = gap - v:GetElementSize().width/2 - self.default_gap
            end
            if v.GetXY then
                v:setPosition(v.GetXY().x, v.GetXY().y)
            end
            if v.refrshCallback then
                v:refrshCallback()
            end
            -- 只有从上到下的形式支持下拉收缩
            if self.order_type == WidgetAutoOrder.ORIENTATION.TOP_TO_BOTTOM and self.isEnableDrop then
                self.final_y = v:getPositionY() - self.default_gap
                if i == 1 then
                    self.first_y = v:getPositionY() - self.default_gap
                end
            end
        else
            if v:CheckVisible() then
                if self.order_type == WidgetAutoOrder.ORIENTATION.BOTTOM_TO_TOP then
                    v:setPositionY(gap)
                    gap = gap + v:GetElementSize().height/2 + self.default_gap
                elseif self.order_type == WidgetAutoOrder.ORIENTATION.TOP_TO_BOTTOM then
                    v:setPositionY(gap)
                    gap = gap - v:GetElementSize().height/2 - self.default_gap
                elseif self.order_type == WidgetAutoOrder.ORIENTATION.LEFT_TO_RIGHT then
                    v:setPositionX(gap)
                    gap = gap + v:GetElementSize().width/2 + self.default_gap
                elseif self.order_type == WidgetAutoOrder.ORIENTATION.RIGHT_TO_LEFT then
                    v:setPositionX(gap)
                    gap = gap - v:GetElementSize().width/2 - self.default_gap
                end
                if v.GetXY then
                    v:setPosition(v.GetXY().x, v.GetXY().y)
                end
                v:show()
                if v.refrshCallback then
                    v:refrshCallback()
                end
                -- 只有从上到下的形式支持下拉收缩
                if self.order_type == WidgetAutoOrder.ORIENTATION.TOP_TO_BOTTOM and self.isEnableDrop then
                    self.final_y = v:getPositionY() - self.default_gap - 20
                    if i == 1 then
                        self.first_y = v:getPositionY() - self.default_gap - 20
                    end
                end
            else
                v:hide()
            end
        end
    end
    if self.isEnableDrop then
        self:AutoShrink()
    end
end
--下拉按钮
function WidgetAutoOrder:CreateDropDownButton()
    local dropBtn = WidgetPushButton.new({normal = "drop_btn_up_88x32.png",
        pressed = "drop_btn_down_88x32.png",
    }):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            self:OnDropBtnClick()
        end
    end):scale(0.6)

    local up_icon = display.newSprite("icon_up_26x20.png"):addTo(dropBtn):pos(0,0)
    dropBtn.isOnDrop = true
    function dropBtn:SkewIcon(isFlipY)
        up_icon:flipY(isFlipY)
        return self
    end
    function dropBtn:IsOnDrop()
        return self.isOnDrop
    end
    function dropBtn:ChangeIsOnDrop()
        self.isOnDrop = not self.isOnDrop
    end
    dropBtn:setTouchSwallowEnabled(true)
    return dropBtn
end
function WidgetAutoOrder:EnableDropBtn()
    if self.order_type == WidgetAutoOrder.ORIENTATION.TOP_TO_BOTTOM then
        self.isEnableDrop = true
        self.dropBtn = self:CreateDropDownButton():addTo(self):hide()
    end
end
-- 自动收缩
function WidgetAutoOrder:AutoShrink()
    if self.order_type == WidgetAutoOrder.ORIENTATION.TOP_TO_BOTTOM and self.isEnableDrop then
        self.dropBtn:SkewIcon(false)
        self.dropBtn:setPositionY(self.final_y):show()
        self.dropBtn.isOnDrop = true
        if self.handle__ then
            scheduler.unscheduleGlobal(self.handle__)
            self.handle__ = nil
        end

        self.handle__ = scheduler.performWithDelayGlobal(function()
            for i,v in ipairs(self.element_table) do
                v:setVisible(i == 1)
            end
            self.dropBtn:ChangeIsOnDrop()
            self.dropBtn:setPositionY(self.first_y)
            self.dropBtn:SkewIcon(true)
            self.handle__ = nil
        end, 10)
    end
end
function WidgetAutoOrder:OnDropBtnClick()
    self.dropBtn:ChangeIsOnDrop()
    if self.dropBtn:IsOnDrop() then
        self:RefreshOrder()
    else
        for i,v in ipairs(self.element_table) do
            v:setVisible(i == 1)
        end
        self.dropBtn:setPositionY(self.first_y)
        self.dropBtn:SkewIcon(true)
        if self.handle__ then
            scheduler.unscheduleGlobal(self.handle__)
            self.handle__ = nil
        end
    end
end
-- 私有方法
function WidgetAutoOrder:Insert(element)
    table.insert(self.element_table, element)
end
function WidgetAutoOrder:onExit()
    if self.handle__ then
        scheduler.unscheduleGlobal(self.handle__)
        self.handle__ = nil
    end
end
return WidgetAutoOrder











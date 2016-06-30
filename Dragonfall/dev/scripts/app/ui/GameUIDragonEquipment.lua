--
-- Author: Danny He
-- Date: 2014-09-22 19:44:50
--
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local GameUIDragonEquipment = UIKit:createUIClass("GameUIDragonEquipment","UIAutoClose")
local StarBar = import(".StarBar")
local UIListView = import(".UIListView")
local WidgetDragonEquipIntensify = import("..widget.WidgetDragonEquipIntensify")
local WidgetInfoWithTitle = import("..widget.WidgetInfoWithTitle")
local BODY_HEIGHT = 516
local BODY_WIDTH = 608
local LISTVIEW_WIDTH = 548
local cocos_promise = import("..utils.cocos_promise")
local Localize = import("..utils.Localize")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetRoundTabButtons = import("..widget.WidgetRoundTabButtons")
local WidgetMakeEquip = import("..widget.WidgetMakeEquip")

function GameUIDragonEquipment:ctor(building,dragon,equipment,part)
    GameUIDragonEquipment.super.ctor(self)
    self.dragon = dragon
    self.equipment = equipment
    self.part = part
    self.building = building
    -- self.dragon_manager = building:GetDragonManager()
    User:AddListenOnType(self, "dragons")
    User:AddListenOnType(self, "dragonEquipments")
end

function GameUIDragonEquipment:OnMoveOutStage()
    
    GameUIDragonEquipment.super.OnMoveOutStage(self)
end
function GameUIDragonEquipment:onExit()
    User:RemoveListenerOnType(self, "dragons")
    User:RemoveListenerOnType(self, "dragonEquipments")
end

function GameUIDragonEquipment:OnUserDataChanged_dragons()
    local config = UtilsForDragon:GetConfigByName(self.equipment.name)
    local dragon = User.dragons[config.usedFor]
    self.equipment = dragon.equipments[self.part]
    self:RefreshIntensifyUI()
end
function GameUIDragonEquipment:OnUserDataChanged_dragonEquipments()
    self:RefreshIntensifyUI()
end

function GameUIDragonEquipment:onEnter()
    GameUIDragonEquipment.super.onEnter(self)
    local backgroundImage = WidgetUIBackGround.new({height = BODY_HEIGHT})
    self.ui_node_main = display.newNode():addTo(backgroundImage)
    self:addTouchAbleChild(backgroundImage)
    self.background = backgroundImage:pos((display.width-backgroundImage:getContentSize().width)/2,display.height - backgroundImage:getContentSize().height - 150)
    local titleBar = display.newSprite("title_blue_600x56.png")
        :align(display.BOTTOM_LEFT, 2,backgroundImage:getContentSize().height - 15)
        :addTo(backgroundImage)
    self.mainTitleLabel =  UIKit:ttfLabel({
        text = Localize.body[UtilsForDragon:GetPartByEquipment(self.equipment)],
        size = 24,
        color= 0xffedae,
    })
        :addTo(titleBar)
        :align(display.CENTER, 300, 26)
    self.titleBar = titleBar
    UIKit:closeButton()
        :addTo(titleBar)
        :align(display.BOTTOM_RIGHT,titleBar:getContentSize().width, 0)
        :onButtonClicked(function ()
            self:LeftButtonClicked()
        end)
    self:TabButtonEvent_intensify()
end
function GameUIDragonEquipment:TabButtonEvent_intensify()
    if not self.ui_node_intensify then
        local node = display.newNode():addTo(self.ui_node_main)
        local mainEquipment = self:GetEquipmentItem()
            :addTo(node):align(display.LEFT_TOP,25,self.titleBar:getPositionY() - 10)
        self.intensify_mainEquipment = mainEquipment
        local name_bar = display.newScale9Sprite("title_blue_430x30.png",0,0, cc.size(448,30), cc.rect(10,10,410,10))
            :addTo(node):align(display.LEFT_TOP,mainEquipment:getPositionX() + mainEquipment:getContentSize().width + 20,mainEquipment:getPositionY() - 2)
        local equip = UtilsForDragon:GetCanEquipedByDragonPart(self.dragon, self.part)
        UIKit:ttfLabel({
            text = Localize.equip[equip.name],
            size = 22,
            align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
            color = 0xffedae,
        }):addTo(name_bar):align(display.LEFT_CENTER, 14,15)

        local intensify_button = WidgetPushButton.new({normal = "blue_btn_up_148x58.png",pressed = "blue_btn_down_148x58.png",disabled = "grey_btn_148x58.png"})
            :addTo(node)
            :align(display.RIGHT_BOTTOM,name_bar:getPositionX() + 428,mainEquipment:getPositionY() - mainEquipment:getContentSize().height - 10)
            :setButtonLabel("normal", UIKit:commonButtonLable({
                text = _("强化"),
                size = 22,
            }))
            :onButtonClicked(function()
                -- self:IntensifyButtonClicked()
                UIKit:newGameUI("GameUIIntensifyEquipment",self.building,self.dragon,self.equipment,self.part):AddToCurrentScene(false)
                self:LeftButtonClicked()
            end)
        self.intensify_button = intensify_button

        local reset_button = WidgetPushButton.new({normal = "blue_btn_up_148x58.png",pressed = "blue_btn_down_148x58.png",disabled = "grey_btn_148x58.png"})
            :addTo(node)
            :align(display.RIGHT_BOTTOM,name_bar:getPositionX() + 208,mainEquipment:getPositionY() - mainEquipment:getContentSize().height - 10)
            :setButtonLabel("normal", UIKit:commonButtonLable({
                text = _("重置"),
                size = 22,
            }))
            :onButtonClicked(function()
                -- self:IntensifyButtonClicked()
                UIKit:newGameUI("GameUIResetEquipment",self.building,self.dragon,self.equipment,self.part):AddToCurrentScene(false)
                self:LeftButtonClicked()
            end)
        self.reset_button = reset_button

        -- local desc_label = UIKit:ttfLabel({
        --     text = self:GetEquipmentDesc(),
        --     size = 22,
        --     color= 0x403c2f
        -- }):addTo(node):align(display.LEFT_BOTTOM,name_bar:getPositionX() + 16,mainEquipment:getPositionY() - mainEquipment:getContentSize().height + 20)
        -- self.intensify_desc_label = desc_label
        -- local list,list_node = UIKit:commonListView_1({
        --     viewRect = cc.rect(0, 0, LISTVIEW_WIDTH, 120),
        --     direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        -- })
        -- list_node:addTo(node):align(display.CENTER_TOP, BODY_WIDTH/2, intensify_button:getPositionY() - 10)
        -- self.intensify_list = list
        local list = WidgetInfoWithTitle.new({
            title = _("属性"),
            h = 328,
        }):addTo(node):align(display.CENTER_TOP, BODY_WIDTH/2, intensify_button:getPositionY() - 74)
        self.intensify_list = list
        -- local intensify_tip_label = UIKit:ttfLabel({
        --     text = _("选择多余的装备进行强化"),
        --     size = 20,
        --     color= 0x403c2f
        -- }):align(display.TOP_CENTER, BODY_WIDTH/2, list:getPositionY() - list:getContentSize().height - 22):addTo(node)
        -- local progressBg = display.newSprite("progress_bar_540x40_1.png")
        --     :addTo(node)
        --     :align(display.CENTER_TOP, BODY_WIDTH/2,intensify_tip_label:getPositionY() - intensify_tip_label:getContentSize().height - 18)

        -- local greenProgress = UIKit:commonProgressTimer("progress_bar_540x40_4.png")
        --     :addTo(progressBg)
        --     :align(display.LEFT_CENTER,0,20)
        -- greenProgress:setPercentage(100)
        -- local yellowProgress = UIKit:commonProgressTimer("progress_bar_540x40_2.png")
        --     :addTo(progressBg)
        --     :align(display.LEFT_CENTER,0,20)
        -- yellowProgress:setPercentage(30)
        -- self.greenProgress = greenProgress
        -- self.yellowProgress = yellowProgress
        -- local exp_label = UIKit:ttfLabel({
        --     text = "120/120 + 300",
        --     size = 20,
        --     color= 0xfff3c7,
        --     shadow= true,
        -- }):align(display.LEFT_CENTER,10, 20):addTo(progressBg)

        -- self.exp_label = exp_label
        -- self.intensify_eq_list = UIListView.new {
        --     viewRect = cc.rect(progressBg:getPositionX() - 270, 90, 540, 272),
        --     direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        --     alignment = cc.ui.UIListView.ALIGNMENT_LEFT,
        -- }:addTo(node)
        self.ui_node_intensify = node
    end
    self:RefreshIntensifyUI()
    return self.ui_node_intensify
end


--type 为活力 力量 buffer 1 2 3
-- function GameUIDragonEquipment:GetListItem(index,title,value)
--     local bg = display.newScale9Sprite(string.format("back_ground_548x40_%d.png", index % 2 == 0 and 1 or 2)):size(LISTVIEW_WIDTH,40)
--     UIKit:ttfLabel({
--         text = title,
--         size = 20,
--         color = 0x615b44,
--         align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
--     }):addTo(bg):align(display.LEFT_CENTER,14,20)
--     UIKit:ttfLabel({
--         text = value,
--         size = 20,
--         align = cc.ui.UILabel.TEXT_ALIGN_RIGHT,
--         color = 0x403c2f,
--     }):addTo(bg):align(display.RIGHT_CENTER, LISTVIEW_WIDTH - 30, 20)
--     return bg
-- end

function GameUIDragonEquipment:WidgetDragonEquipIntensifyEvent(widgetDragonEquipIntensify)
    local equipment = self:GetEquipment()
    --如果装备星级达到最高星级 无条件回滚
    if equipment.star >= self.dragon.star then return true end
    local exp = 0
    table.foreach(self.allEquipemnts,function(index,v)
        exp = exp + v:GetTotalExp()
    end)
    local oldExp = exp - widgetDragonEquipIntensify:GetExpPerEq()
    local nextConfig = UtilsForDragon:GetEquipStarConfig(equipment, self.part, 1)
    local enhanceExp = nextConfig.enhanceExp
    local oldPercent = (oldExp + (equipment.exp or 0))/enhanceExp * 100
    if oldPercent >= 100 then
        return true
    else
        local percent = (exp + (equipment.exp or 0))/enhanceExp * 100
        local str = equipment.exp .. "/" .. enhanceExp
        if exp > 0 then
            str = str .. " +" .. exp
        end
        self.exp_label:setString(str)
        self.greenProgress:setPercentage(percent)
    end
end
function GameUIDragonEquipment:RefreshEquipmentItem()
    self.intensify_mainEquipment:removeFromParent()
    local mainEquipment = self:GetEquipmentItem()
    mainEquipment:addTo(self.ui_node_intensify):align(display.LEFT_TOP,15,self.titleBar:getPositionY() - 10)
    self.intensify_mainEquipment = mainEquipment
end

function GameUIDragonEquipment:RefreshIntensifyUI(isAnimationyellowProcess)
    if type(isAnimationyellowProcess) ~= 'boolean' then isAnimationyellowProcess = false end
    self:RefreshEquipmentItem()
    self:RefreshIntensifyListView()
end
function GameUIDragonEquipment:GetEquipment()
    return self.equipment
end

-- 调用龙巢详情界面的函数获取道具图标
function GameUIDragonEquipment:GetEquipmentItem()
    local equipment_obj = {self:GetEquipment(), self.part}
    local item = UIKit:GetUIInstance("GameUIDragonEyrieDetail"):GetEquipmentItem(equipment_obj,self.dragon.star,false)
    item:scale(120/item:getContentSize().width)
    return item
end


function GameUIDragonEquipment:GetEquipmentEffect(needBuff)
    if type(needBuff) ~= 'boolean' then
        needBuff = true
    end

    local r = {}
    local equipment = self:GetEquipment()
    local config = UtilsForDragon:GetEquipAttributes(equipment, self.part)
    table.insert(r,{_("生命值"),config.vitality})
    table.insert(r,{_("攻击力"),config.strength})
    table.insert(r,{_("带兵量"),config.leadership})
    if needBuff then
        for __,v in ipairs(UtilsForDragon:GetDragonEquipBuff(equipment)) do
            table.insert(r,{Localize.dragon_buff_effection[v[1]],string.format("%d%%",v[2]*100)})
        end
    end
    return r
end

function GameUIDragonEquipment:RefreshIntensifyListView()
    local info_message = self:GetEquipmentEffect(true)
    self.intensify_list:CreateInfoItems(info_message)
end

function GameUIDragonEquipment:Find()
    return cocos_promise.defer(function()
        return self.adornOrResetButton
    end)
end

return GameUIDragonEquipment


--
-- Author: Kenny Dai
-- Date: 2016-04-25 15:48:11
local UIListView = import("..ui.UIListView")
local WidgetPushButton = import(".WidgetPushButton")
local Localize = import("..utils.Localize")
local timer = app.timer

local WIDGET_WIDTH = 450
local WIDGET_HEIGHT = 220
local icon_map = {
    ["technology"] = "tech_42x38.png" ,
    ["material"] = "material_42x36.png" ,
    ["soldier"] = "soldier_42x36.png" ,
    ["build"] = "build_42x36.png" ,
}
local WidgetEventsList = class("WidgetEventsList", function()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    node:setContentSize(cc.size(WIDGET_WIDTH,WIDGET_HEIGHT))
    return node
end)

function WidgetEventsList:ctor()
    self.isDrop = false -- 初始化列表打开状态为false
    self.city = City
end
function WidgetEventsList:onEnter()
    self:CreateListView()
    self.dropBtn = self:CreateDropDownButton()
    self:CreatePreNode()
    self:RefreshByStatus()
    scheduleAt(self, function()
        self:RefreshEventsInfo()
    end)
    User:AddListenOnType(self, "soldierEvents")
    User:AddListenOnType(self, "soldierStarEvents")
    User:AddListenOnType(self, "militaryTechEvents")
    User:AddListenOnType(self, "productionTechEvents")
    User:AddListenOnType(self, "materialEvents")
    User:AddListenOnType(self, "dragonEquipmentEvents")
    User:AddListenOnType(self, "houseEvents")
    User:AddListenOnType(self, "buildingEvents")
end
function WidgetEventsList:onExit()
    User:RemoveListenerOnType(self, "soldierEvents")
    User:RemoveListenerOnType(self, "soldierStarEvents")
    User:RemoveListenerOnType(self, "militaryTechEvents")
    User:RemoveListenerOnType(self, "productionTechEvents")
    User:RemoveListenerOnType(self, "materialEvents")
    User:RemoveListenerOnType(self, "dragonEquipmentEvents")
    User:RemoveListenerOnType(self, "houseEvents")
    User:RemoveListenerOnType(self, "buildingEvents")
end
function WidgetEventsList:RefreshEventsInfo()
    if self:GetDropStatus() then
        for i,eventItem in ipairs(self.listEventsItem) do
            self:SetEventItemProgressInfo(eventItem)
            self:SetProgressItemBtnLabel(UtilsForEvent:CouldFreeSpeedUp(eventItem.event.eventType) and self:IsAbleToFreeSpeedup(eventItem.event),eventItem)
        end
    else
        for i,eventItem in ipairs(self.preEventsItem) do
            self:SetEventItemProgressInfo(eventItem)
            self:SetProgressItemBtnLabel(UtilsForEvent:CouldFreeSpeedUp(eventItem.event.eventType) and self:IsAbleToFreeSpeedup(eventItem.event),eventItem)
        end
    end
end
function WidgetEventsList:SetEventItemProgressInfo(eventItem)
    local str, percent, time
    local eventType = eventItem.event.eventType
    if eventType == "soldierEvents" then
        str, percent, time = self:SoldierDescribe(eventItem.event)
    elseif eventType == "soldierStarEvents" or
        eventType == "militaryTechEvents" or
        eventType == "productionTechEvents"
    then
        str, percent, time = self:TechDescribe(eventItem.event)
    elseif eventType == "dragonEquipmentEvents" then
        str, percent, time = self:EquipmentDescribe(eventItem.event)
    elseif eventType == "materialEvents" then
        str, percent, time = self:MaterialDescribe(eventItem.event)
    elseif eventType == "houseEvents" or
        eventType == "buildingEvents" then
        str, percent, time = self:BuildingDescribe(eventItem.event)
    end
    eventItem:SetProgressInfo(str, percent, time)
end
-- 获取列表打开状态
function WidgetEventsList:GetDropStatus()
    return self.isDrop
end
-- 改变列表状态
function WidgetEventsList:ChangeDropStatus()
    self.isDrop = not self.isDrop
end
-- 创建列表
function WidgetEventsList:CreateListView()
    if self.listview then
        self.listview:removeFromParent()
        self.listview = nil
    end
    local all_events = self:GetAllUpgradeEvents()
    local listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a10ff00),
        viewRect = cc.rect(0,0, WIDGET_WIDTH, #all_events == 2 and 135 or 180),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        scrollbarImgV = "line_4x40.png"
    }:addTo(self):pos(0, #all_events == 2 and 79 or 34)
    self.listview = listview
    self.listview = listview
    listview:removeAllItems()
    self.listEventsItem = {}
    for i,v in ipairs(all_events) do
        local item = listview:newItem()
        item:setItemSize(440, 45)
        local content  = self:CreateEventItem(v,false,i)
        item:addContent(content)
        item:zorder(#all_events - i + 3)
        listview:addItem(item)
        table.insert(self.listEventsItem, content)
    end
    local item = listview:newItem()
    item:setItemSize(440, 45)
    item:addContent(self:CreateOpenBuildingItem(false))
    listview:addItem(item)
    listview:reload()
    -- 定位上次操作的事件
    local currentEvent = self:GetCurrentEvent()
    if currentEvent then
        local preEventIdx -- 上次操作的事件的idx
        for i,item in ipairs(listview:getItems()) do
            local content = item:getContent()
            if content.event and content.event.id == currentEvent.event.id then
                preEventIdx = i
                break
            end
        end
        preEventIdx = preEventIdx or currentEvent.idx
        if preEventIdx then
            listview:showItemWithPos(preEventIdx)
        end
        self:ResetCurrentEvent()
    end
    listview:hide()
    return listview
end
function WidgetEventsList:GetEventItemIdx(item)
    if self.listview then
        for i,l_item in ipairs(self.listview:getItems()) do
            if l_item:getContent().event and l_item:getContent().event.id == item.event.id then
                return i
            end
        end
    end
end
-- 收起状态下的优先显示的事件
function WidgetEventsList:CreatePreNode()
    if self.preNode then
        self.preNode:removeFromParent()
        self.preNode = nil
    end
    local preNode = display.newNode()
    self.preEventsItem = {}
    preNode:setContentSize(cc.size(WIDGET_WIDTH,90))
    preNode:addTo(self):pos(5,WIDGET_HEIGHT - 94)
    local pre_events = self:GetDefaultEvents()
    for i,v in ipairs(pre_events) do
        local item = self:CreateEventItem(v,true,i):align(display.LEFT_BOTTOM, 0, i == 1 and 45 or 0):addTo(preNode)
        item:zorder(#pre_events + 3 - i)
        table.insert(self.preEventsItem, item)
    end
    if #pre_events < 2 then
        self:CreateOpenBuildingItem(true):align(display.LEFT_BOTTOM, 0, #pre_events == 0 and 45 or 0):addTo(preNode)
    end
    preNode:hide()
    self.preNode = preNode
    return preNode
end
-- 获取优先显示事件
function WidgetEventsList:GetDefaultEvents()
    local all_events = self:GetAllUpgradeEvents()
    local pre_events = {}
    if all_events[1] then
        table.insert(pre_events, all_events[1])
    end
    if all_events[2] then
        table.insert(pre_events, all_events[2])
    end
    return pre_events
end
-- 获取所有事件
function WidgetEventsList:GetAllUpgradeEvents()
    local all_type = {
        "soldierEvents",
        "soldierStarEvents",
        "militaryTechEvents",
        "productionTechEvents",
        "materialEvents",
        "dragonEquipmentEvents",
        "houseEvents",
        "buildingEvents",
    }
    local all_events = {}
    for i,event_type in ipairs(all_type) do
        for i,v in ipairs(User[event_type]) do
            local leftTime = UtilsForEvent:GetEventInfo(v)
            if leftTime > 0 then
                local event = clone(v)
                event.eventType = event_type
                table.insert(all_events, event)
            end
        end
    end
    table.sort( all_events, function ( event_a,event_b )
        local leftTime_a = UtilsForEvent:GetEventInfo(event_a)
        local leftTime_b = UtilsForEvent:GetEventInfo(event_b)
        return leftTime_a < leftTime_b
    end )
    return all_events
end
function WidgetEventsList:CreateEventItem(event,isTouchEnabled)
    local item = self:CreateProgressItem(isTouchEnabled)
    item:SetEvent(event)
    self:SetEventItemProgressInfo(item)
    if event.eventType == "soldierEvents" then
        item:SetTypeIcon("soldier")
    elseif event.eventType == "soldierStarEvents" or
        event.eventType == "militaryTechEvents" or
        event.eventType == "productionTechEvents"
    then
        item:SetTypeIcon("technology")
    elseif event.eventType == "materialEvents" or
        event.eventType == "dragonEquipmentEvents" then
        item:SetTypeIcon("material")
    elseif event.eventType == "houseEvents" or
        event.eventType == "buildingEvents" then
        item:SetTypeIcon("build")
    end
    item:OnClicked(function ()
        self:OnEventButtonClicked(item)
    end)
    self:SetProgressItemBtnLabel(UtilsForEvent:CouldFreeSpeedUp(event.eventType) and self:IsAbleToFreeSpeedup(event),item)
    return item
end
function WidgetEventsList:OnEventButtonClicked(item)
    local event = item.event
    local time = UtilsForEvent:GetEventInfo(event)
    if UtilsForEvent:CouldFreeSpeedUp(event.eventType) and DataUtils:getFreeSpeedUpLimitTime() > time then
        if time > 2 then
            NetManager:getFreeSpeedUpPromise(event.eventType, event.id)
        end
    else
        if not Alliance_Manager:GetMyAlliance():IsDefault() and self:IsAbleToRequestHelp(event.eventType) and not User:IsRequestHelped(event.id) then
            NetManager:getRequestAllianceToSpeedUpPromise(event.eventType,event.id)
        else
            -- 没加入联盟或者已加入联盟并且申请过帮助时执行使用道具加速
            if event.eventType == "soldierEvents" then
                UIKit:newGameUI("GameUIBarracksSpeedUp"):AddToCurrentScene(true)
            elseif event.eventType == "militaryTechEvents" or event.eventType == "soldierStarEvents" then
                UIKit:newGameUI("GameUIMilitaryTechSpeedUp", event):AddToCurrentScene(true)
            elseif event.eventType == "productionTechEvents" then
                UIKit:newGameUI("GameUITechnologySpeedUp"):AddToCurrentScene(true)
            elseif event.eventType == "materialEvents" then
                UIKit:newGameUI("GameUIToolShopSpeedUp", self.city:GetFirstBuildingByType("toolShop")):AddToCurrentScene(true)
            elseif event.eventType == "dragonEquipmentEvents" then
                UIKit:newGameUI("GameUIBlackSmithSpeedUp", self.city:GetFirstBuildingByType("blackSmith")):AddToCurrentScene(true)
            elseif event.eventType == "houseEvents" or event.eventType == "buildingEvents" then
                UIKit:newGameUI("GameUIBuildingSpeedUp", event):AddToCurrentScene(true)
            end
        end
    end
    self:HandleCurrentEvent(item)
end
-- 保留当前操作的事件的信息用作list刷新后的定位
function WidgetEventsList:HandleCurrentEvent(item)
    self.currentEventInfo = {}
    self.currentEventInfo.idx = self:GetEventItemIdx(item)
    self.currentEventInfo.event = item.event
end
function WidgetEventsList:ResetCurrentEvent()
    self.currentEventInfo = nil
end
function WidgetEventsList:GetCurrentEvent()
    return self.currentEventInfo
end
function WidgetEventsList:SetProgressItemBtnLabel(canFreeSpeedUp, event_item)
    if event_item.event.finishTime/1000 < timer:GetServerTime() then return end
    local User = self.city:GetUser()
    local old_status = event_item.status
    local btn_label
    local btn_images
    if canFreeSpeedUp then
        btn_label = _("免费加速")
        btn_images = {normal = "purple_btn_up_108x38.png",
            pressed = "purple_btn_down_108x38.png",
        }
        event_item.status = "freeSpeedup"
    else
        -- 未加入联盟或者已经申请过联盟加速
        if Alliance_Manager:GetMyAlliance():IsDefault()
            or User:IsRequestHelped(event_item.event.id) or not self:IsAbleToRequestHelp(event_item.event.eventType) then
            btn_label = _("加速")
            btn_images = {normal = "green_btn_up_108x38.png",
                pressed = "green_btn_down_108x38.png",
            }
            event_item.status = "speedup"
        else
            btn_label = _("帮助")
            btn_images = {normal = "yellow_btn_up_108x38.png",
                pressed = "yellow_btn_down_108x38.png",
            }
            event_item.status = "help"
        end
    end
    if old_status~= event_item.status then
        event_item:SetButtonLabel(btn_label)
        event_item:SetButtonImages(btn_images)
        if event_item.status == "freeSpeedup" 
        and not self.finger
        and UtilsForFte:ShouldFingerOnFree(User) then
            self.finger = UIKit:FingerAni():addTo(event_item):pos(420,-15):scale(0.8)
        end
    end
end
function WidgetEventsList:IsAbleToFreeSpeedup(event)
    local time = UtilsForEvent:GetEventInfo(event)
    return DataUtils:getFreeSpeedUpLimitTime() > time
end
function WidgetEventsList:IsAbleToRequestHelp(eventType)
    return eventType ~= "soldierEvents" and eventType ~= "materialEvents" and eventType ~= "dragonEquipmentEvents"
end
function WidgetEventsList:CreateOpenBuildingItem(isTouchEnabled)
    local building_item = self:CreateProgressItem(isTouchEnabled)
    building_item.desc_building:show()
    building_item.desc:hide()
    building_item.time:hide()
    building_item:SetButtonLabel(_("打开"))
    building_item:SetTypeIcon("build")
    building_item:OnClicked(function ()
        UIKit:newGameUI('GameUIHasBeenBuild', City):AddToCurrentScene(true)
    end)
    building_item:SetButtonImages({normal = "blue_btn_up_108x38.png",
        pressed = "blue_btn_down_108x38.png",
    })
    return building_item
end
-- 创建事件item
function WidgetEventsList:CreateProgressItem(isTouchEnabled)
    local node = display.newNode()
    node:setTouchEnabled(isTouchEnabled)
    node:setContentSize(cc.size(440,42))
    local half_height = node:getContentSize().height / 2
    local node_1 = display.newScale9Sprite("background_event_42x42.png"):size(398,42):addTo(node):align(display.LEFT_CENTER,42,half_height)
    local type_bg = display.newSprite("background_event_head_42x42.png"):pos(21, half_height):addTo(node)
    node.type_icon = display.newSprite("tech_42x38.png"):pos(21, 21):addTo(type_bg):scale(0.8)

    node.progress = display.newProgressTimer("tab_progress_bar_282x36.png",
        display.PROGRESS_TIMER_BAR):addTo(node_1)
        :align(display.LEFT_CENTER, 2, half_height)
    node.progress:setBarChangeRate(cc.p(1,0))
    node.progress:setMidpoint(cc.p(0,0))
    -- node.progress:setPercentage(100)
    node.desc = UIKit:ttfLabel({
        text = "Building",
        size = 14,
        color = 0xd1ca95,
        shadow = true,
    }):addTo(node_1):align(display.LEFT_CENTER, 10, half_height + 8)
    node.desc_building = UIKit:ttfLabel({
        text = _("查看已经拥有的建筑"),
        size = 16,
        color = 0xd1ca95,
        shadow = true,
    }):addTo(node_1):align(display.LEFT_CENTER, 10, half_height):hide()

    node.time = UIKit:ttfLabel({
        text = "Time",
        size = 14,
        color = 0xd1ca95,
        shadow = true,
    }):addTo(node_1):align(display.LEFT_CENTER, 10, half_height - 8)

    display.newSprite("line_1x42.png"):pos(398 - 111, half_height):addTo(node_1)

    node.speed_btn = WidgetPushButton.new({normal = "green_btn_up_108x38.png",
        pressed = "green_btn_down_108x38.png",
    }
    ,{}
    ,{
        disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
    }):addTo(node_1):align(display.RIGHT_CENTER, 398 - 2, half_height)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("加速"),
            size = 18,
            color = 0xfff3c7,
            shadow = true}))
    function node:SetTypeIcon(type)
        self.type_icon:setTexture(icon_map[type])
        self.type_icon:scale(0.8)
        return self
    end
    function node:SetProgressInfo(str, percent, time)
        self.desc:setString(str)
        self.time:setString(time or "")
        self.progress:setPercentage(percent)
        return self
    end
    function node:OnClicked(func)
        self.speed_btn:onButtonClicked(func)
        return self
    end
    function node:SetEvent(event)
        self.event = event
        return self
    end
    function node:SetButtonImages(images)
        self.speed_btn:setButtonImage(cc.ui.UIPushButton.NORMAL, images["normal"], true)
        self.speed_btn:setButtonImage(cc.ui.UIPushButton.PRESSED, images["pressed"], true)
        self.speed_btn:setButtonImage(cc.ui.UIPushButton.DISABLED, images["disabled"], true)
        return self
    end
    function node:SetButtonLabel(str)
        self.speed_btn:setButtonLabel(UIKit:ttfLabel({
            text = str,
            size = 18,
            color = 0xfff3c7,
            shadow = true}))
        return self
    end
    function node:GetSpeedUpButton()
        return self.speed_btn
    end
    return node
end
--下拉按钮
function WidgetEventsList:CreateDropDownButton()
    local dropBtn = WidgetPushButton.new({normal = "drop_btn_up_88x32.png",
        pressed = "drop_btn_down_88x32.png",
    }):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            self:OnDropBtnClick()
        end
    end):align(display.CENTER, 48, 16)
        :addTo(self,999)

    local up_icon = display.newSprite("icon_up_26x20.png"):addTo(dropBtn):pos(-18,0)
    up_icon:flipY(true)
    local active_event_label = UIKit:ttfLabel({
        text = "3",
        size = 16,
        color = 0xffedae,
        shadow = true,
    }):addTo(dropBtn):align(display.LEFT_CENTER, 10, 0)
    function dropBtn:SkewIcon(isFlipY)
        up_icon:flipY(isFlipY)
        return self
    end
    function dropBtn:SetActiveEventNumber(count)
        active_event_label:setString(count)
        return self
    end
    dropBtn:setTouchSwallowEnabled(true)
    return dropBtn
end
function WidgetEventsList:OnDropBtnClick()
    self:ChangeDropStatus()
    self:RefreshByStatus()
end
function WidgetEventsList:RefreshByStatus()
    if self.finger then
        self.finger:removeFromParent()
        self.finger = nil
    end
    local all_events = self:GetAllUpgradeEvents()
    local dropStatus = self:GetDropStatus()
    -- 当处于列表状态，事件数量减少到小于2个时，切换回非列表状态
    if dropStatus and #all_events < 2 then
        self:ChangeDropStatus()
    end
    dropStatus = self:GetDropStatus()
    if dropStatus then
        self.dropBtn:SkewIcon(false)
        self.dropBtn:setPositionY(#all_events == 2 and 61 or 16)
        self:CreateListView():show()
        self.preNode:hide()
    else
        self:CreatePreNode()
        self.preNode:show()
        self.dropBtn:SkewIcon(true)
        self.dropBtn:setPositionY(#self.preNode:getChildren() == 1 and WIDGET_HEIGHT - 70 or WIDGET_HEIGHT - 115)
        self.listview:hide()
    end
    self.dropBtn:setVisible(#all_events > 1)
    self.dropBtn:SetActiveEventNumber(#all_events)
end
function WidgetEventsList:BuildingDescribe(event)
    local User = self.city:GetUser()
    local str
    if event.location then
        local building = UtilsForBuilding:GetBuildingByEvent(User, event)
        if building.level == 0 then
            str = string.format(_("%s (解锁)"), Localize.building_name[building.type])
        else
            str = string.format(_("%s (升级到 等级%d)"), Localize.building_name[building.type], building.level + 1)
        end
    else
        local house = UtilsForBuilding:GetBuildingByEvent(User, event)
        if house.level == 0 then
            str = string.format(_("%s (建造)"), Localize.building_name[house.type])
        else
            str = string.format(_("%s (升级到 等级%d)"), Localize.building_name[house.type], house.level + 1)
        end
    end
    local time, percent = UtilsForEvent:GetEventInfo(event)
    return str, percent , GameUtils:formatTimeStyle1(time)
end
function WidgetEventsList:SoldierDescribe(event)
    local time, percent = UtilsForEvent:GetEventInfo(event)
    return string.format( _("招募%s x%d"),
        Localize.soldier_name[event.name], event.count),
    percent,
    GameUtils:formatTimeStyle1(time)
end
function WidgetEventsList:EquipmentDescribe(event)
    local time, percent = UtilsForEvent:GetEventInfo(event)
    return string.format( _("正在制作 %s"), Localize.equip[event.name]), percent , GameUtils:formatTimeStyle1(time)
end
function WidgetEventsList:MaterialDescribe(event)
    local time, percent = UtilsForEvent:GetEventInfo(event)
    local count = 0
    for _,v in pairs(event.materials) do
        count = count + v.count
    end
    return string.format( _("制造材料 x%d"), count), percent , GameUtils:formatTimeStyle1(time)
end
function WidgetEventsList:TechDescribe(event)
    local User = self.city:GetUser()
    local str
    if User:IsProductionTechEvent(event) then
        local next_level = User.productionTechs[event.name].level + 1
        str = _("研发") .. string.format(" %s Lv %d", Localize.productiontechnology_name[event.name], next_level)
    elseif User:IsSoldierStarEvent(event) then
        str = UtilsForEvent:GetMilitaryTechEventLocalize(event.name, UtilsForSoldier:SoldierStarByName(User, event.name))
    elseif User:IsMilitaryTechEvent(event) then
        str = UtilsForEvent:GetMilitaryTechEventLocalize(event.name, User:GetMilitaryTechLevel(event.name))
    else
        return "", 0, "00:00:00"
    end
    local time, percent = UtilsForEvent:GetEventInfo(event)
    return str, percent , GameUtils:formatTimeStyle1(time)
end
function WidgetEventsList:OnUserDataChanged_houseEvents(userData, deltaData)
    self:RefreshByStatus()
end
function WidgetEventsList:OnUserDataChanged_buildingEvents(userData, deltaData)
    self:RefreshByStatus()
end
function WidgetEventsList:OnUserDataChanged_dragonEquipmentEvents(userData, deltaData)
    self:RefreshByStatus()
end
function WidgetEventsList:OnUserDataChanged_materialEvents(userData, deltaData)
    self:RefreshByStatus()
end
function WidgetEventsList:OnUserDataChanged_soldierEvents(userData, deltaData)
    self:RefreshByStatus()
end
function WidgetEventsList:OnUserDataChanged_militaryTechEvents(userData, deltaData)
    self:RefreshByStatus()
end
function WidgetEventsList:OnUserDataChanged_soldierStarEvents(userData, deltaData)
    self:RefreshByStatus()
end
function WidgetEventsList:OnUserDataChanged_productionTechEvents(userData, deltaData)
    self:RefreshByStatus()
end
return WidgetEventsList


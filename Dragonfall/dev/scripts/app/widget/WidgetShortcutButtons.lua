--
-- Author: Kenny Dai
-- Date: 2015-10-21 22:32:40
--
local window = import("..utils.window")
local WidgetAutoOrder = import(".WidgetAutoOrder")
local WidgetAutoOrderBuffButton = import(".WidgetAutoOrderBuffButton")
local WidgetAutoOrderGachaButton = import(".WidgetAutoOrderGachaButton")
local WidgetAutoOrderAwardButton = import(".WidgetAutoOrderAwardButton")
local WidgetNumberTips = import(".WidgetNumberTips")

local WidgetLight = import(".WidgetLight")
local UILib = import("..ui.UILib")


local SCALE = 0.8

local WidgetShortcutButtons =  class('WidgetShortcutButtons',function ()
    local layer = display.newLayer()
    layer:setContentSize(cc.size(display.width, display.height))
    layer:setNodeEventEnabled(true)
    layer:setTouchSwallowEnabled(false)
    return layer
end)

function WidgetShortcutButtons:ctor(city)
    self.city = city
    local order = WidgetAutoOrder.new(WidgetAutoOrder.ORIENTATION.BOTTOM_TO_TOP,50,false)
        :addTo(self):pos(display.left + 50, display.bottom + 266)
    order:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
        if display.getRunningScene():GetHomePage().__cname == "GameUIHome" and display.getRunningScene():GetHomePage().quest_bar_bg then
            local node = display.getRunningScene():GetHomePage().quest_bar_bg
            local attackWorldPoint = node:convertToWorldSpace(cc.p(0,90))
            local attackNodePoint = order:getParent():convertToNodeSpace(attackWorldPoint)
            order:setPositionY(attackNodePoint.y)
        end
    end)
    order:scheduleUpdate()
    --在线活动
    local activity_button = WidgetAutoOrderAwardButton.new():scale(SCALE)
    activity_button:onButtonClicked(function(event)
        if event.target:getChildByTag(111) then
            event.target:removeChildByTag(111)
        end
    end)
    order:AddElement(activity_button)
    self.activity_button = activity_button
    local gacha_button = WidgetAutoOrderGachaButton.new():scale(SCALE)
    order:AddElement(gacha_button)
    --行军事件按钮
    local alliance_belvedere_button = cc.ui.UIPushButton.new({normal = 'fight_62x70.png'})
    alliance_belvedere_button.alliance_belvedere_events_count = WidgetNumberTips.new():addTo(alliance_belvedere_button):pos(20,-20)
    alliance_belvedere_button:onButtonClicked(function()
        UIKit:newGameUI("GameUIWatchTower", City, "march"):AddToCurrentScene(true)
    end):scale(SCALE)
    function alliance_belvedere_button:CheckVisible()
        local to_my_events,out_march_events = Alliance_Manager:GetAboutMyMarchEvents()
        local count = #to_my_events + #out_march_events
        if count == 0 then
            return false
        end
        alliance_belvedere_button.alliance_belvedere_events_count:SetNumber(count)
        return true
    end
    function alliance_belvedere_button:GetElementSize()
        return alliance_belvedere_button:getCascadeBoundingBox().size
    end
    order:AddElement(alliance_belvedere_button)


    --进入三级地图按钮
    local world_map_btn_bg = display.newSprite("background_86x86.png")
    local world_map_btn = UIKit:ButtonAddScaleAction(cc.ui.UIPushButton.new({normal = 'icon_world_88x88.png'})
        :onButtonClicked(function()
            if display.getRunningScene().__cname == "AllianceDetailScene" then
                local x,y = display.getRunningScene():GetSceneLayer():GetMiddlePosition()
                local mapIndex = DataUtils:GetAlliancePosition(x, y)
                UIKit:newGameUI("GameUIWorldMap", nil, nil, mapIndex):AddToCurrentScene()
            end
        end)
    ):align(display.CENTER,world_map_btn_bg:getContentSize().width/2 , world_map_btn_bg:getContentSize().height/2)
        :addTo(world_map_btn_bg)
    self.world_map_btn = world_map_btn

    function world_map_btn_bg:CheckVisible()
        return not Alliance_Manager:GetMyAlliance():IsDefault() and (display.getRunningScene().__cname == "WorldScene" or display.getRunningScene().__cname == "AllianceDetailScene")
    end
    function world_map_btn_bg:GetElementSize()
        return world_map_btn_bg:getContentSize()
    end
    function world_map_btn_bg:GetXY()
        return {x = 0 ,y = 30}
    end
    self.world_map_btn_bg = world_map_btn_bg
    order:AddElement(world_map_btn_bg)


    order:RefreshOrder()

    self.left_order_group = order

    local right_top_order = WidgetAutoOrder.new(WidgetAutoOrder.ORIENTATION.TOP_TO_BOTTOM,50,true):addTo(self):pos(display.right - 50, display.top-260)
    right_top_order:EnableDropBtn()
    -- 活动按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "tips_66x64.png", pressed = "tips_66x64.png"},
        {scale9 = false}
    ):scale(SCALE)
    WidgetLight.new():addTo(button, -1001):scale(0.6)
    button:onButtonClicked(function(event)
        local needTips = false
        if event.target:getChildByTag(111) then
            event.target:removeChildByTag(111)
            needTips = true
        end
        if event.name == "CLICKED_EVENT" then
            UIKit:newGameUI("GameUIActivityNew",self.city,needTips):AddToCurrentScene(true)
        end
    end)
    function button:CheckVisible()
        return true
    end
    function button:GetElementSize()
        return {width = 66,height = 64}
    end
    right_top_order:AddElement(button)
    button.tips_button_count = WidgetNumberTips.new():addTo(button):pos(20,-20)
    self.tips_button = button
    self:CheckAllianceRewardCount()
    -- BUFF按钮
    local buff_button = WidgetAutoOrderBuffButton.new():scale(SCALE)
    right_top_order:AddElement(buff_button)
    -- 龙驻防按钮
    local dragon_defence_btn = cc.ui.UIPushButton.new({normal = 'back_ground_defence_58x74.png'})
        :onButtonClicked(function()
            UIKit:newGameUI("GameUIDragonEyrieMain", self.city, self.city:GetFirstBuildingByType("dragonEyrie"), "dragon",false,nil,true):AddToCurrentScene(true)
        end):scale(SCALE)
    local dragon_img = display.newSprite(UILib.dragon_head.blueDragon)
        :align(display.CENTER, -3,4)
        :addTo(dragon_defence_btn)
        :scale(0.35)
        :hide()
    local warning_icon = display.newSprite("icon_warning_22x42.png")
        :align(display.CENTER, -2,0)
        :addTo(dragon_defence_btn)
        :hide()
    dragon_defence_btn:runAction(
        cc.RepeatForever:create(
            transition.sequence{
                cc.ScaleTo:create(0.8, 0.8),
                cc.ScaleTo:create(0.8, 0.7),
            }
        )
    )
    local this = self
    function dragon_defence_btn:CheckVisible()
        local defenceDragon = UtilsForDragon:GetDefenceDragon(this.city:GetUser())
        if defenceDragon then
            dragon_img:setTexture(UILib.dragon_head[defenceDragon.type])
            dragon_img:show()
            warning_icon:hide()
            dragon_defence_btn:stopAllActions()
        else
            dragon_img:hide()
            warning_icon:show()
            dragon_defence_btn:runAction(
                cc.RepeatForever:create(
                    transition.sequence{
                        cc.ScaleTo:create(0.8, 0.8),
                        cc.ScaleTo:create(0.8, 0.7),
                    }
                )
            )
        end
        return true
    end
    function dragon_defence_btn:GetElementSize()
        return {width = dragon_defence_btn:getCascadeBoundingBox().size.width,height = dragon_defence_btn:getCascadeBoundingBox().size.height+30}
    end

    right_top_order:AddElement(dragon_defence_btn)


    -- 圣地时间按钮
    local shrine_event_button = cc.ui.UIPushButton.new({normal = 'tmp_btn_shrine_74x90.png'})
    shrine_event_button:onButtonClicked(function(event)
        local needTips
        if event.target:getChildByTag(111) then
            needTips = true
            event.target:removeChildByTag(111)
            app:GetGameDefautlt():SetPassTriggerTips("shrineEvents")
        end
        local info = Alliance_Manager:GetMyAlliance():GetAllianceBuildingInfoByName("shrine")
        UIKit:newGameUI("GameUIAllianceShrine",
                        self.city,
                        "fight_event",
                        info,
                        needTips):AddToCurrentScene(true)
    end):scale(SCALE)
    function shrine_event_button:CheckVisible()
        return not Alliance_Manager:GetMyAlliance():IsDefault() and Alliance_Manager:GetMyAlliance().shrineEvents and #Alliance_Manager:GetMyAlliance().shrineEvents > 0
    end
    function shrine_event_button:GetElementSize()
        return shrine_event_button:getCascadeBoundingBox().size
    end
    right_top_order:AddElement(shrine_event_button)
    self.shrine_event_button = shrine_event_button

    -- 协助加速按钮
    self.help_button = cc.ui.UIPushButton.new(
        {normal = "help_64x72.png", pressed = "help_64x72.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            if not Alliance_Manager:GetMyAlliance():IsDefault() then
                UIKit:newGameUI("GameUIHelp"):AddToCurrentScene(true)
            else
                UIKit:showMessageDialog(_("提示"),_("加入联盟才能激活帮助功能"))
            end
        end
    end):scale(SCALE)

    self.request_count = WidgetNumberTips.new():addTo(self.help_button):pos(20,-20)
    self.request_count:SetNumber(Alliance_Manager:GetMyAlliance():GetOtherRequestEventsNum())
    local help_button = self.help_button
    function help_button:CheckVisible()
        local alliance = Alliance_Manager:GetMyAlliance()
        return not alliance:IsDefault() and #alliance:GetCouldShowHelpEvents()>0
    end
    function help_button:GetElementSize()
        return help_button:getCascadeBoundingBox().size
    end
    right_top_order:AddElement(help_button)

    right_top_order:RefreshOrder()
    self.right_top_order = right_top_order

end

function WidgetShortcutButtons:onEnter()
    User:AddListenOnType(self, "countInfo")
    User:AddListenOnType(self, "houseEvents")
    User:AddListenOnType(self, "buildings")
    User:AddListenOnType(self, "buildingEvents")
    User:AddListenOnType(self, "soldierStarEvents")
    User:AddListenOnType(self, "militaryTechEvents")
    User:AddListenOnType(self, "productionTechEvents")
    -- User:AddListenOnType(self, "iapGifts")
    User:AddListenOnType(self, "vipEvents")
    User:AddListenOnType(self, "dragons")
    User:AddListenOnType(self, "activities")
    User:AddListenOnType(self, "allianceActivities")

    if NewsManager then
        NewsManager:AddListenOnType(self,NewsManager.LISTEN_TYPE.UNREAD_NEWS_CHANGED)
    end

    local my_allaince = Alliance_Manager:GetMyAlliance()
    my_allaince:AddListenOnType(self, "operation")
    my_allaince:AddListenOnType(self, "basicInfo")
    my_allaince:AddListenOnType(self, "helpEvents")
    my_allaince:AddListenOnType(self, "marchEvents")
    my_allaince:AddListenOnType(self, "shrineEvents")
    my_allaince:AddListenOnType(self, "activities")
    Alliance_Manager:AddHandle(self)
end
function WidgetShortcutButtons:onExit()
    User:RemoveListenerOnType(self, "countInfo")
    User:RemoveListenerOnType(self, "houseEvents")
    User:RemoveListenerOnType(self, "buildings")
    User:RemoveListenerOnType(self, "buildingEvents")
    User:RemoveListenerOnType(self, "soldierStarEvents")
    User:RemoveListenerOnType(self, "militaryTechEvents")
    User:RemoveListenerOnType(self, "productionTechEvents")
    -- User:RemoveListenerOnType(self, "iapGifts")
    User:RemoveListenerOnType(self, "vipEvents")
    User:RemoveListenerOnType(self, "dragons")
    User:RemoveListenerOnType(self, "activities")
    User:RemoveListenerOnType(self, "allianceActivities")
    if NewsManager then
        NewsManager:RemoveListenerOnType(self,NewsManager.LISTEN_TYPE.UNREAD_NEWS_CHANGED)
    end

    local my_allaince = Alliance_Manager:GetMyAlliance()
    my_allaince:RemoveListenerOnType(self, "operation")
    my_allaince:RemoveListenerOnType(self, "basicInfo")
    my_allaince:RemoveListenerOnType(self, "helpEvents")
    my_allaince:RemoveListenerOnType(self, "marchEvents")
    my_allaince:RemoveListenerOnType(self, "shrineEvents")
    my_allaince:RemoveListenerOnType(self, "activities")
    Alliance_Manager:RemoveHandle(self)
end
function WidgetShortcutButtons:onCleanup()
    GameGlobalUI:clearMessageQueue()
    if UIKit:getRegistry().isObjectExists(self.__cname) then
        UIKit:getRegistry().removeObject(self.__cname)
    end
    UIKit:CheckCloseUI(self.__cname)
end
function WidgetShortcutButtons:OnUserDataChanged_countInfo()
    self.left_order_group:RefreshOrder()
    self.right_top_order:RefreshOrder()
    self:CheckAllianceRewardCount()
end
function WidgetShortcutButtons:OnAllianceDataChanged_operation(alliance,operation_type)
    if operation_type == "quit" then
        self.right_top_order:RefreshOrder()
        self.left_order_group:RefreshOrder()
    end
end
function WidgetShortcutButtons:RefreshHelpButtonVisible()
    if self.help_button then
        self.right_top_order:RefreshOrder()
    end
end

function WidgetShortcutButtons:OnUserDataChanged_buildings(userData, deltaData)
    if deltaData("buildings.location_1") then
        self:CheckAllianceRewardCount()
    end
end
function WidgetShortcutButtons:OnUserDataChanged_houseEvents()
    self:RefreshHelpButtonVisible()
end
function WidgetShortcutButtons:OnUserDataChanged_buildingEvents()
    self:RefreshHelpButtonVisible()
end
function WidgetShortcutButtons:OnUserDataChanged_productionTechEvents()
    self:RefreshHelpButtonVisible()
end
function WidgetShortcutButtons:OnUserDataChanged_militaryTechEvents()
    self:RefreshHelpButtonVisible()
end
function WidgetShortcutButtons:OnUserDataChanged_soldierStarEvents()
    self:RefreshHelpButtonVisible()
end
function WidgetShortcutButtons:OnAllianceDataChanged_basicInfo(alliance, deltaData)
    self:RefreshHelpButtonVisible()
end
-- function WidgetShortcutButtons:OnUserDataChanged_iapGifts()
--     self:CheckAllianceRewardCount()
-- end
function WidgetShortcutButtons:OnAllianceDataChanged_helpEvents()
    self:RefreshHelpButtonVisible()
    self.request_count:SetNumber(Alliance_Manager:GetMyAlliance():GetOtherRequestEventsNum())
end
function WidgetShortcutButtons:OnAllianceDataChanged_marchEvents(alliance, deltaData)
    self.left_order_group:RefreshOrder()
end
function WidgetShortcutButtons:OnAllianceDataChanged_shrineEvents(alliance, deltaData)
    self.right_top_order:RefreshOrder()
end
function WidgetShortcutButtons:OnUserDataChanged_dragons()
    self.right_top_order:RefreshOrder()
end
function WidgetShortcutButtons:OnUserDataChanged_vipEvents()
-- self.left_order_group:RefreshOrder()
end
function WidgetShortcutButtons:OnUserDataChanged_activities()
    self:CheckAllianceRewardCount()
end
function WidgetShortcutButtons:OnUserDataChanged_allianceActivities()
    self:CheckAllianceRewardCount()
end
function WidgetShortcutButtons:OnAllianceDataChanged_activities(alliance, deltaData)
    self:CheckAllianceRewardCount()
end
function WidgetShortcutButtons:OnMapDataChanged()
    self.right_top_order:RefreshOrder()
end
function WidgetShortcutButtons:OnEnterMapIndex()
end
function WidgetShortcutButtons:OnMapAllianceChanged()
end
function WidgetShortcutButtons:NewsUnreadChanged()
    self:CheckAllianceRewardCount()
end
function WidgetShortcutButtons:CheckAllianceRewardCount()
    if not NewsManager then return end
    if not self.tips_button then return end
    local newsCount = NewsManager:GetUnreadCount()
    local activityCount = ActivityManager:GetHaveRewardActivitiesCount()

    local award_num = 0
    if User:HaveEveryDayLoginReward() then
        award_num = award_num + 1
    end
    if User:HaveContinutyReward() then
        award_num = award_num + 1
    end
    if User:HavePlayerLevelUpReward() then
        award_num = award_num + 1
    end
    self.tips_button.tips_button_count:SetNumber(newsCount + award_num + activityCount)
end
-- function WidgetShortcutButtons:HasAnyRewards()
--     return User:HaveEveryDayLoginReward()
--         or User:HaveContinutyReward()
--         or User:HavePlayerLevelUpReward()
--         or User:HaveOnlineReward()
-- end
local WidgetFteArrow = import("..widget.WidgetFteArrow")
function WidgetShortcutButtons:TipsOnReward(isonline)
    if isonline then
        if not self.activity_button:getChildByTag(111) then
            WidgetFteArrow.new(_("当前有奖励可以领取"))
            :addTo(self.activity_button, 100, 111)
            :TurnLeft():align(display.LEFT_CENTER, 50, 0)
        end
    else
        if not self.tips_button:getChildByTag(111) then
            WidgetFteArrow.new(_("当前有奖励可以领取"))
            :addTo(self.tips_button, 100, 111)
            :TurnRight():align(display.RIGHT_CENTER, -50, 0)
        end
    end
end
function WidgetShortcutButtons:TipsOnShrine()
    if not self.shrine_event_button:getChildByTag(111) then
        UIKit:FingerAni():addTo(self.shrine_event_button,10,111):pos(35,-40)
    end
end
function WidgetShortcutButtons:HasAnyTips()
    return self.tips_button:getChildByTag(111)
    or self.activity_button:getChildByTag(111)
    or self.shrine_event_button:getChildByTag(111)
end
return WidgetShortcutButtons













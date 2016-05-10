local cocos_promise = import("..utils.cocos_promise")
local promise = import("..utils.promise")
local window = import("..utils.window")
local WidgetChat = import("..widget.WidgetChat")
local WidgetHomeBottom = import("..widget.WidgetHomeBottom")
local WidgetEventTabButtons = import("..widget.WidgetEventTabButtons")
local UILib = import(".UILib")
local WidgetChangeMap = import("..widget.WidgetChangeMap")
local GameUIActivityRewardNew = import(".GameUIActivityRewardNew")
local WidgetEventsList = import("..widget.WidgetEventsList")
local GameUIHome = UIKit:createUIClass('GameUIHome')
local light_gem = import("..particles.light_gem")


GameUIHome.ResPositionMap = {}

function GameUIHome:OnUserDataChanged_buildings()
    self:OnUserDataChanged_growUpTasks()
end
function GameUIHome:OnUserDataChanged_houseEvents()
    self:OnUserDataChanged_growUpTasks()
end
function GameUIHome:OnUserDataChanged_buildingEvents()
    self:OnUserDataChanged_growUpTasks()
end
function GameUIHome:OnUserDataChanged_productionTechEvents()
    self:OnUserDataChanged_growUpTasks()
end
function GameUIHome:OnUserDataChanged_growUpTasks()
    local City,User = self.city, self.city:GetUser()

    local currentTask = City:GetRecommendTask()
    local finishedTasks = UtilsForTask:GetFinishedUnRewardTasksBySeq(User)
    if not UtilsForTask:HasCurrentTask() then
        if #finishedTasks > 0 then
            self.task = finishedTasks[1]
        else
            UtilsForTask:SetCurrentTask(currentTask)
            self.task = currentTask
        end
    else
        if UtilsForTask:IsCurrentTask(currentTask) then
            self.task = currentTask
        else
            if #finishedTasks > 0 then
                local ct
                local task = UtilsForTask:GetCurrentTask()
                for i,v in ipairs(finishedTasks) do
                    if v:TaskType() == task:TaskType() and v.id == task.id then
                        ct = v
                        break
                    end
                end
                self.task = ct or finishedTasks[1]
                UtilsForTask:SetCurrentTask(nil)
            else
                UtilsForTask:SetCurrentTask(currentTask)
                self.task = currentTask
            end
        end
    end

    if self.task then
        self.quest_bar_bg:show()
        self.quest_label:setString(self.task:Title())
        self:RefreshTaskStatus(self.task.finished)
    else
        self.quest_bar_bg:hide()
        self.quest_label:setString(_("当前没有推荐任务!"))
    end

    self:CheckFinger()
end
function GameUIHome:OnUserDataChanged_vipEvents()
    self:RefreshVIP()
end

function GameUIHome:DisplayOn()
    self.visible_count = self.visible_count + 1
    self:FadeToSelf(self.visible_count > 0)
end
function GameUIHome:DisplayOff()
    self.visible_count = self.visible_count - 1
    self:FadeToSelf(self.visible_count > 0)
end
function GameUIHome:FadeToSelf(isFullDisplay)
    self:stopAllActions()
    if isFullDisplay then
        self:show()
        transition.fadeIn(self, {
            time = 0.2,
        })
    else
        transition.fadeOut(self, {
            time = 0.2,
            onComplete = function()
                self:hide()
            end,
        })
    end
end
local red_color = 0xff3c00
local normal_color = 0xf3f0b6
function GameUIHome:ctor(city)
    GameUIHome.super.ctor(self,{type = UIKit.UITYPE.BACKGROUND})
    self.city = city
end
function GameUIHome:onEnter()
    self.visible_count = 1
    local city = self.city

    self.order_shortcut = UIKit:newWidgetUI("WidgetShortcutButtons",city):addTo(self)
    -- 上背景
    self.top = self:CreateTop()
    self.bottom = self:CreateBottom()

    -- local ratio = self.bottom:getScale()
    -- self.event_tab = WidgetEventTabButtons.new(self.city, ratio)
    -- local rect1 = self.chat:getCascadeBoundingBox()
    -- local x, y = rect1.x, rect1.y + rect1.height - 2
    -- self.event_tab:addTo(self,0):pos(x, y)

    self:AddOrRemoveListener(true)
    self:RefreshData()
    self:RefreshVIP()
    self:OnUserDataChanged_growUpTasks()
    self:ShowVipActiveTips()
    scheduleAt(self, function()
        local User = self.city:GetUser()
        self.wood_label:SetNumString(GameUtils:formatNumber(User:GetResValueByType("wood")))
        self.food_label:SetNumString(GameUtils:formatNumber(User:GetResValueByType("food")))
        self.iron_label:SetNumString(GameUtils:formatNumber(User:GetResValueByType("iron")))
        self.stone_label:SetNumString(GameUtils:formatNumber(User:GetResValueByType("stone")))
        -- self.citizen_label:SetNumString(GameUtils:formatNumber(User:GetResValueByType("citizen")))
        self.coin_label:SetNumString(GameUtils:formatNumber(User:GetResValueByType("coin")))
        self.gem_label:SetNumString(string.formatnumberthousands(User:GetResValueByType("gem")))
        self.wood_label:SetNumColor(User:IsResOverLimit("wood") and red_color or normal_color)
        self.food_label:SetNumColor(User:IsResOverLimit("food") and red_color or normal_color)
        self.iron_label:SetNumColor(User:IsResOverLimit("iron") and red_color or normal_color)
        self.stone_label:SetNumColor(User:IsResOverLimit("stone") and red_color or normal_color)
    end)
end
function GameUIHome:onExit()
    self:AddOrRemoveListener(false)
end
function GameUIHome:AddOrRemoveListener(isAdd)
    local city = self.city
    local user = self.city:GetUser()
    if isAdd then
        user:AddListenOnType(self, "basicInfo")
        user:AddListenOnType(self, "buildings")
        user:AddListenOnType(self, "growUpTasks")
        user:AddListenOnType(self, "vipEvents")
        user:AddListenOnType(self, "houseEvents")
        user:AddListenOnType(self, "buildingEvents")
        user:AddListenOnType(self, "productionTechEvents")
    else
        user:RemoveListenerOnType(self, "basicInfo")
        user:RemoveListenerOnType(self, "buildings")
        user:RemoveListenerOnType(self, "growUpTasks")
        user:RemoveListenerOnType(self, "vipEvents")
        user:RemoveListenerOnType(self, "houseEvents")
        user:RemoveListenerOnType(self, "buildingEvents")
        user:RemoveListenerOnType(self, "productionTechEvents")
    end
end
function GameUIHome:GetShortcutNode()
    return self.order_shortcut
end
function GameUIHome:ShowVipActiveTips()
    if app:GetGameDefautlt():CloudOpenVipTips() then
        UIKit:newGameUI("GameUIVIPPop"):AddToCurrentScene()
    end
end
function GameUIHome:OnUserDataChanged_basicInfo(userData, deltaData)
    self:RefreshData()
    if deltaData("basicInfo.vipExp") then
        self:RefreshVIP()
    end
    if deltaData("basicInfo.icon") then
        self.player_icon:setTexture(UILib.player_icon[userData.basicInfo.icon])
    end
    if deltaData("basicInfo.levelExp") then
        self:RefreshExp()
    end
end

function GameUIHome:RefreshData()
    local user = self.city:GetUser()
    -- self.name_label:setString(user.basicInfo.name)
    self.power_label:SetNumString(string.formatnumberthousands(user.basicInfo.power))
    self.level_label:SetNumString(user:GetLevel())
end


function GameUIHome:CreateTop()
    local User = self.city:GetUser()
    local top_bg = display.newSprite("top_bg_768x117.png"):addTo(self,2)
        :align(display.TOP_CENTER, display.cx, display.top ):setCascadeOpacityEnabled(true)
    if display.width>640 then
        top_bg:scale(display.width/768)
    end
    -- 玩家按钮
    local button = cc.ui.UIPushButton.new(
        ):onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI('GameUIVipNew', self.city,"info"):AddToCurrentScene(true)
            end
        end):addTo(top_bg):align(display.LEFT_CENTER,64, top_bg:getContentSize().height/2)
    button:setContentSize(cc.size(90,100))

    -- 战斗力按钮
    local power_button = cc.ui.UIPushButton.new(
        {normal = "power_btn_up_258x48.png", pressed = "power_btn_down_258x48.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            UIKit:newGameUI("GameUIPower"):AddToCurrentScene()
        end
    end):addTo(top_bg):align(display.TOP_CENTER, top_bg:getContentSize().width/2 + 24, top_bg:getContentSize().height - 6)
    -- 玩家战斗值文字
    UIKit:ttfLabel({
        text = _("战斗力"),
        size = 14,
        color = 0x9a946b,
    }):addTo(power_button):align(display.CENTER, 0, -14)

    -- 玩家战斗值数字
    self.power_label = UIKit:CreateNumberImageNode({
        text = "",
        size = 20,
        color = 0xf3f0b6,
    }):addTo(power_button):align(display.CENTER, 0, -36)

    self.shadow_power_label = UIKit:CreateNumberImageNode({
        text = "",
        size = 20,
        color = 0xf3f0b6,
    }):addTo(power_button):align(display.CENTER, 0, -36):hide()

    -- 资源按钮
    local button = cc.ui.UIPushButton.new(
        ):onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI("GameUIResourceOverview",self.city):AddToCurrentScene(true)
            end
        end):addTo(top_bg):align(display.LEFT_CENTER, 160, 40)
    button:setContentSize(cc.size(540,32))

    -- 资源图片和文字
    self.res_icon_map = {}
    local first_col = 18
    local label_padding = 15
    local padding_width = 105
    for i, v in ipairs({
        {"res_wood_82x73.png", "wood_label", "wood"},
        {"res_stone_88x82.png", "stone_label", "stone"},
        {"res_food_91x74.png", "food_label", "food"},
        {"res_iron_91x63.png", "iron_label", "iron"},
        {"res_coin_81x68.png", "coin_label", "coin"},
    }) do
        local row = i > 3 and 1 or 0
        local col = (i - 1) % 3
        local x, y = first_col + (i - 1) * padding_width, 16
        self.res_icon_map[v[3]] = display.newSprite(v[1]):addTo(button):pos(x, y):scale(0.3)
        local wp = self.res_icon_map[v[3]]:convertToWorldSpace(cc.p(0,0))
        self.ResPositionMap[v[3]] = wp
        self[v[2]] = UIKit:CreateNumberImageNode({text = "",
            size = 18,
            color = 0xf3f0b6,
        }):addTo(button):align(display.LEFT_CENTER,x + label_padding, y)
    end

    -- 玩家信息背景
    self.player_icon = UIKit:GetPlayerIconOnly(User.basicInfo.icon)
        :addTo(top_bg):align(display.LEFT_CENTER,69, top_bg:getContentSize().height/2 + 10):scale(0.65)
    local black_bg = display.newColorLayer(UIKit:hex2c4b(0xff000000))
    black_bg:setContentSize(cc.size(58,8))
    black_bg:addTo(top_bg):pos(95, 21)
    self.exp = display.newProgressTimer("player_exp_bar_62x12.png",
        display.PROGRESS_TIMER_BAR):addTo(top_bg):align(display.LEFT_CENTER,94, 24)
    self.exp:setBarChangeRate(cc.p(1,0))
    self.exp:setMidpoint(cc.p(0,0))
    self:RefreshExp()

    local level_bg = display.newSprite("level_bg_85x20.png"):addTo(top_bg):align(display.LEFT_CENTER,69, 27):setCascadeOpacityEnabled(true)
    self.level_label = UIKit:CreateNumberImageNode({text = "",
        size = 14,
        color = 0xf3f0b6,
    }):addTo(level_bg):align(display.CENTER, 12, 9)
    -- vip
    local vip_btn = cc.ui.UIPushButton.new(
        {normal = "vip_btn_136x48.png"},
        {scale9 = false}
    ):align(display.TOP_LEFT, 150, top_bg:getContentSize().height - 6):addTo(top_bg)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI('GameUIVipNew', self.city,"VIP"):AddToCurrentScene(true)
            end
        end)
    local vip_btn_img = UtilsForVip:IsVipActived(User) and "vip_bg_110x124.png" or "vip_bg_disable_110x124.png"
    local vip_icon = display.newSprite("crown_gold_46x40.png",28,-24,{class=cc.FilteredSpriteWithOne}):addTo(vip_btn)
    self.vip_level = UIKit:ttfLabel({
        text =  "VIP "..User:GetVipLevel(),
        size = 20,
        shadow = true,
        color = 0xffb400
    }):addTo(vip_btn):align(display.CENTER, vip_icon:getPositionX() + 55, vip_icon:getPositionY())
    if UtilsForVip:IsVipActived(User) then
        vip_btn:setButtonImage(cc.ui.UIPushButton.NORMAL, "vip_btn_136x48.png", true)
        vip_btn:setButtonImage(cc.ui.UIPushButton.PRESSED, "vip_btn_136x48.png", true)
    else
        vip_btn:setButtonImage(cc.ui.UIPushButton.NORMAL, "vip_btn_grey_136x48.png", true)
        vip_btn:setButtonImage(cc.ui.UIPushButton.PRESSED, "vip_btn_grey_136x48.png", true)
    end
    self.vip_btn = vip_btn

    -- 金龙币按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "gem_btn_up_149x47.png", pressed = "gem_btn_down_149x47.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        UIKit:newGameUI("GameUIStore"):AddToCurrentScene(true)
    end):addTo(top_bg):pos(top_bg:getContentSize().width - 143, top_bg:getContentSize().height - 30)
    local gem_icon = display.newSprite("store_gem_260x116.png"):addTo(button):pos(50, 0):scale(0.49)
    light_gem():addTo(gem_icon, 1022):pos(260/2, 116/2)

    self.gem_label = UIKit:CreateNumberImageNode({
        size = 20,
        color = 0xffd200,
    }):addTo(button):align(display.CENTER, -14, -1)
    WidgetEventsList.new():addTo(self):align(display.LEFT_TOP, window.left + (display.width>640 and 14 or 0), display.top - 100)
    return top_bg
end
function GameUIHome:GotoUnlockBuilding(location)
    self:GotoOpenBuildingUI(self.city:GetBuildingByLocationId(location))
end
function GameUIHome:GotoOpenBuildUI(task)
    for i,v in ipairs(self.city:GetDecoratorsByType(task:Config().name)) do
        local location = self.city:GetLocationIdByBuilding(v)
        local houses = self.city:GetDecoratorsByLocationId(location)
        for i = 3, 1, -1 do
            if not houses[i] then
                self:GotoOpenBuildingUI(self.city:GetRuinByLocationIdAndHouseLocationId(location, i), task.name)
                return
            end
        end
    end
    local maxneighbours = {}
    local ruins = self.city:GetRuinsNotBeenOccupied()
    for i,v in ipairs(ruins) do
        local neighbours = self.city:GetNeighbourRuinWithSpecificRuin(v)
        if #neighbours == 2 then
            self:GotoOpenBuildingUI(neighbours[1], task:Config().name)
            return
        end
    end
    self:GotoOpenBuildingUI(ruins[1], task:Config().name)
end
function GameUIHome:GotoOpenBuildingUI(building, build_name)
    if not building then return end
    local current_scene = display.getRunningScene()
    local building_sprite = current_scene:GetSceneLayer():FindBuildingSpriteByBuilding(building, self.city)
    local x,y = building:GetMidLogicPosition()
    current_scene:GotoLogicPoint(x,y,40):next(function()
        current_scene:AddIndicateForBuilding(building_sprite, build_name)
    end)
end
function GameUIHome:GotoExplore()
    local current_scene = display.getRunningScene()
    local building_sprite = current_scene:GetSceneLayer():GetAirship()
    current_scene:GotoLogicPoint(-2,10,40):next(function()
        current_scene:AddIndicateForBuilding(building_sprite)
    end)
end

function GameUIHome:CreateBottom()
    local bottom_bg = WidgetHomeBottom.new(self.city):addTo(self, 1)
        :align(display.BOTTOM_CENTER, display.cx, display.bottom)

    self.chat = WidgetChat.new():addTo(bottom_bg)
        :align(display.CENTER, bottom_bg:getContentSize().width/2, bottom_bg:getContentSize().height)
    -- 任务条
    local quest_bar_bg = cc.ui.UIPushButton.new(
        {normal = "quest_btn_unfinished_566x46.png",pressed = "quest_btn_unfinished_566x46.png"},
        {scale9 = false}
    ):addTo(bottom_bg):pos(420, bottom_bg:getContentSize().height + 56):onButtonClicked(function(event)
        self:HideFinger()
        local task = self.task
        if task then
            if task.finished then
                NetManager:getGrowUpTaskRewardsPromise(task:TaskType(), task.id):done(function()
                    if self.ShowResourceAni then
                        local x,y = self.quest_status_icon:getPosition()
                        local wp = self.quest_status_icon:getParent():convertToWorldSpace(cc.p(x,y))
                        for i,v in ipairs(task:GetRewards()) do
                            if v.type == "resources" then
                                self:ShowResourceAni(v.name,wp)
                            end
                        end
                        if not self.is_hooray_on then
                            self.is_hooray_on = true
                            app:GetAudioManager():PlayeEffectSoundWithKey("COMPLETE")
                            if self.quest_bar_bg then
                                self.quest_bar_bg:performWithDelay(function()
                                    self.is_hooray_on = false
                                end, 1.5)
                            end
                        end
                    end
                end)
            else
                if task:TaskType() == "cityBuild" then
                    if task:IsBuild() then
                        self:GotoOpenBuildUI(task)
                    elseif task:IsUnlock() then
                        local buildings = UtilsForBuilding:GetBuildingsBy(self.city:GetUser(), task:Config().name)
                        self:GotoUnlockBuilding(buildings[1].location)
                    elseif task:IsUpgrade() then
                        self:GotoOpenBuildingUI(self.city:PreconditionByBuildingType(task:Config().name))
                    end
                elseif task:TaskType() == "productionTech" then
                    UIKit:newGameUI("GameUIQuickTechnology", self.city, task:Config().name):AddToCurrentScene(true)
                elseif task:TaskType() == "soldierCount" then
                    local barracks = self.city:GetFirstBuildingByType("barracks")
                    UIKit:newGameUI('GameUIBarracks', self.city, barracks, "recruit", task:Config().name):AddToCurrentScene(true)
                elseif task:TaskType() == "pveCount" then
                    self:GotoExplore()
                end
            end
        end
    end)
    self.quest_bar_bg = quest_bar_bg

    local light = display.newSprite("quest_light_70x34.png"):addTo(quest_bar_bg):pos(-302, 2)
    light:runAction(
        cc.RepeatForever:create(
            transition.sequence{
                cc.MoveTo:create(0.8, cc.p(200, 2)),
                cc.CallFunc:create(function() light:setPositionX(-302) end),
                cc.DelayTime:create(2)
            }
        )
    )
    display.newSprite("icon_quest_bg_50x50.png"):addTo(quest_bar_bg):pos(-302, 2)
    self.quest_status_icon = display.newSprite("icon_warning_22x42.png"):addTo(quest_bar_bg):pos(-302, 2)
    self.quest_label = UIKit:ttfLabel({
        size = 20,
        color = 0xfffeb3,
        shadow = true
    }):addTo(quest_bar_bg):align(display.LEFT_CENTER, -260, 4)
    -- self.quest_label:runAction(UIKit:ScaleAni())



    self.change_map = WidgetChangeMap.new(WidgetChangeMap.MAP_TYPE.OUR_CITY):addTo(self, 1)

    return bottom_bg
end
function GameUIHome:CheckFinger(isFirst)
    if self.task and 
        UtilsForFte:ShouldFingerOnTask(self.city:GetUser()) and
        self.city:GetUser().countInfo.isFTEFinished then
        if self.task.finished then
            self:ShowClickReward()
        else
            self:ShowFinger(isFirst)
        end
        return
    end
    self:HideFinger()
    self:HideClickReward()
    if not UtilsForTask:NeedTips(self.city:GetUser()) 
   and not Alliance_Manager:HasBeenJoinedAlliance() then
        display.getRunningScene():FteAlliance() 
    end
end
local WidgetFteArrow = import("..widget.WidgetFteArrow")
function GameUIHome:ShowClickReward()
    if not self.quest_bar_bg:getChildByTag(222) then
        WidgetFteArrow.new(_("点击领取奖励")):TurnDown()
        :addTo(self.quest_bar_bg,10,222):pos(100,60)
    end
    self.quest_bar_bg:getChildByTag(222):show()
    self:HideFinger()
end
function GameUIHome:HideClickReward()
    if self.quest_bar_bg:getChildByTag(222) then
        self.quest_bar_bg:getChildByTag(222):hide()
    end
end
local WidgetMaskFilter = import("..widget.WidgetMaskFilter")
function GameUIHome:ShowFinger(isFirst)
    if not self.quest_bar_bg:getChildByTag(111) then
        UIKit:FingerAni():addTo(self.quest_bar_bg,10,111):pos(180, -30)
    end
    self.quest_bar_bg:getChildByTag(111):show()
    self:HideClickReward()

    if isFirst then
        local rect = self.quest_bar_bg:getChildByTag(111):getCascadeBoundingBox()
        rect.x = rect.x - rect.width/3
        rect.width = rect.width * 1.5
        rect.height = rect.height * 1.3
        local mask = WidgetMaskFilter.new()
        :addTo(self,2000,123456789):pos(display.cx, display.cy)
        mask:FocusOnRect(rect)
        mask:setTouchEnabled(true)
        mask:setTouchSwallowEnabled(false)
        mask:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            if event.name == "began" then
                self:removeChildByTag(123456789)
            end
            return true
        end)
        -- self:GetFteLayer():Enable():SetTouchRect(rect)
        -- local finger = self.quest_bar_bg:getChildByTag(111):getChildByTag(1)
        -- finger:stopAllActions()
        -- self.quest_bar_bg:getChildByTag(111)
        -- :pos(200,400):runAction(transition.sequence{
        --     cc.MoveTo:create(1.5, cc.p(180, -30)),
        --     cc.CallFunc:create(function()
        --         finger:runAction(UIKit:GetFingerAni())
        --     end)
        -- })
    end
end
function GameUIHome:HideFinger()
    if self.quest_bar_bg:getChildByTag(111) then
        self.quest_bar_bg:getChildByTag(111):hide()
    end
end
function GameUIHome:RefreshTaskStatus(finished)
    if finished then -- 任务已经完成
        self.quest_bar_bg:setButtonImage(cc.ui.UIPushButton.NORMAL, "quest_btn_finished_566x46.png", true)
        self.quest_bar_bg:setButtonImage(cc.ui.UIPushButton.PRESSED, "quest_btn_finished_566x46.png", true)
        self.quest_status_icon:setTexture("icon_query_34x44.png")
    else
        self.quest_bar_bg:setButtonImage(cc.ui.UIPushButton.NORMAL, "quest_btn_unfinished_566x46.png", true)
        self.quest_bar_bg:setButtonImage(cc.ui.UIPushButton.PRESSED, "quest_btn_unfinished_566x46.png", true)
        self.quest_status_icon:setTexture("icon_warning_22x42.png")
    end
end
function GameUIHome:ChangeChatChannel(channel_index)
    self.chat:ChangeChannel(channel_index)
end

function GameUIHome:RefreshExp()
    local User = self.city:GetUser()
    local current_level = User:GetPlayerLevelByExp(User.basicInfo.levelExp)
    self.exp:setPercentage( (User.basicInfo.levelExp - User:GetCurrentLevelExp(current_level))/(User:GetCurrentLevelMaxExp(current_level) - User:GetCurrentLevelExp(current_level)) * 100)
end
function GameUIHome:RefreshVIP()
    local User = self.city:GetUser()
    local vip_btn = self.vip_btn
    self.vip_level:setString("VIP "..User:GetVipLevel())
    if UtilsForVip:IsVipActived(User) then
        vip_btn:setButtonImage(cc.ui.UIPushButton.NORMAL, "vip_btn_136x48.png", true)
        vip_btn:setButtonImage(cc.ui.UIPushButton.PRESSED, "vip_btn_136x48.png", true)
    else
        vip_btn:setButtonImage(cc.ui.UIPushButton.NORMAL, "vip_btn_grey_136x48.png", true)
        vip_btn:setButtonImage(cc.ui.UIPushButton.PRESSED, "vip_btn_grey_136x48.png", true)
    end
end
local POWER_ANI_TAG = 1001
function GameUIHome:ShowPowerAni(wp, old_power)
    local pnt = self.top
    self.power_label:hide()
    self.shadow_power_label:show():SetNumString(string.formatnumberthousands(old_power))

    pnt:removeChildByTag(POWER_ANI_TAG)
    local tp = pnt:convertToNodeSpace(self.power_label:convertToWorldSpace(cc.p(0,0)))
    local lp = pnt:convertToNodeSpace(wp)
    local time, delay_time = 1, 0.25
    local emitter = cc.ParticleFlower:createWithTotalParticles(200)
        :addTo(pnt, 100, POWER_ANI_TAG):pos(lp.x, lp.y)
    emitter:setDuration(time + delay_time)
    emitter:setLife(1)
    emitter:setLifeVar(1)
    emitter:setStartColor(cc.c4f(1.0,0.84,0.48,1.0))
    emitter:setStartColorVar(cc.c4f(0.0))
    emitter:setTexture(cc.Director:getInstance():getTextureCache():addImage("stars.png"))
    emitter:runAction(transition.sequence{
        cc.MoveTo:create(time, cc.p(tp.x, tp.y)),
        cc.CallFunc:create(function()
            self:ScaleIcon(self.power_label:show(),self.power_label:getScale())
            self.shadow_power_label:hide()
        end),
        cc.DelayTime:create(delay_time),
    })
end
local RES_ICON_TAG = {
    food = 1010,
    wood = 1011,
    iron = 1012,
    coin = 1013,
    stone = 1014,
    citizen = 1015,
}
local icon_map = {
    food = "res_food_91x74.png",
    wood = "res_wood_82x73.png",
    iron = "res_iron_91x63.png",
    coin = "res_coin_81x68.png",
    stone = "res_stone_88x82.png",
-- citizen = "res_citizen_88x82.png",
}
function GameUIHome:ShowResourceAni(resource, wp)
    if not icon_map[resource] then
        return
    end
    local pnt = self.top
    pnt:removeChildByTag(RES_ICON_TAG[resource])

    local s1 = self.res_icon_map[resource]:getContentSize()
    local lp = pnt:convertToNodeSpace(wp or cc.p(display.cx, display.cy))
    local tp = pnt:convertToNodeSpace(self.res_icon_map[resource]:convertToWorldSpace(cc.p(s1.width/2,s1.height/2)))

    local x,y,tx,ty = lp.x,lp.y,tp.x,tp.y
    local icon = display.newSprite(icon_map[resource])
        :addTo(pnt):pos(x,y):scale(0.8)

    local size = icon:getContentSize()
    local emitter = cc.ParticleFlower:createWithTotalParticles(200)
        :addTo(icon):pos(size.width/2, size.height/2)

    local time = 1
    emitter:setPosVar(cc.p(10,10))
    emitter:setDuration(time)
    emitter:setCascadeOpacityEnabled(true)
    emitter:setLife(1)
    emitter:setLifeVar(1)
    emitter:setStartColor(cc.c4f(1.0))
    emitter:setStartColorVar(cc.c4f(0.0))
    emitter:setTexture(cc.Director:getInstance():getTextureCache():addImage("stars.png"))


    local bezier2 ={
        cc.p(x,y),
        cc.p((x + tx) * 0.5 + math.random(200) - 100, (y + ty) * 0.5),
        cc.p(tx, ty)
    }
    icon:runAction(
        cc.Spawn:create({
            cc.ScaleTo:create(time, 0.3),
            transition.sequence{
                cc.BezierTo:create(time, bezier2),
                cc.CallFunc:create(function()
                    icon:opacity(0)
                    self:ScaleIcon(self.res_icon_map[resource], 0.3, 0.5)
                end),
                cc.DelayTime:create(1),
                cc.RemoveSelf:create(),
            }
        })
    )
end
function GameUIHome:ScaleIcon(ccnode, s, ds)
    local s = s or 1
    local ds = ds or 0.1
    ccnode:runAction(transition.sequence{
        cc.ScaleTo:create(0.2, s * (1 + ds)),
        cc.ScaleTo:create(0.2, s),
    })
end

-- fte
-- local mockData = import("..fte.mockData")
local WidgetFteArrow = import("..widget.WidgetFteArrow")
local WidgetFteMark = import("..widget.WidgetFteMark")
-- function GameUIHome:Find()
--     local item
--     self.event_tab:IteratorAllItem(function(_, v)
--         if v.GetSpeedUpButton then
--             item = v:GetSpeedUpButton()
--             return true
--         end
--     end)
--     return item
-- end
-- function GameUIHome:FindVip()
--     return self.vip_btn
-- end
-- function GameUIHome:PromiseOfFteWaitFinish()
--     if UtilsForBuilding:GetBuildingEventsCount(self.city:GetUser()) > 0 then
--         if not self.event_tab:IsShow() then
--             self.event_tab:EventChangeOn("build", true)
--         end
--         self:GetFteLayer()
--         return self.city:GetUser():PromiseOfFinishUpgrading()
--             :next(function()self:GetFteLayer():Reset()end)
--             :next(cocos_promise.delay(1))
--             :next(function()self:GetFteLayer():removeFromParent()end)
--     end
--     return cocos_promise.defer()
-- end
-- function GameUIHome:PromiseOfFteFreeSpeedUp()
--     if UtilsForBuilding:GetBuildingEventsCount(self.city:GetUser()) > 0 then
--         self:GetFteLayer()
--         self.event_tab:PromiseOfPopUp():next(function()
--             self:GetFteLayer():SetTouchObject(self:Find())
--             self:Find():removeEventListenersByEvent("CLICKED_EVENT")
--             self:Find():onButtonClicked(function()
--                 self:Find():setButtonEnabled(false)

--                 local event = UtilsForBuilding:GetBuildingEventsBySeq(self.city:GetUser())[1]
--                 if event then
--                     local building = UtilsForBuilding:GetBuildingByEvent(self.city:GetUser(), event)
--                     if event.buildingLocation then
--                         mockData.FinishBuildHouseAt(event.buildingLocation, building.level + 1)
--                     else
--                         mockData.FinishUpgradingBuilding(building.type, building.level + 1)
--                     end
--                 end
--             end)

--             local r = self:Find():getCascadeBoundingBox()
--             WidgetFteArrow.new(_("5分钟以下免费加速")):addTo(self:GetFteLayer())
--                 :TurnDown(true):align(display.RIGHT_BOTTOM, r.x + r.width/2 + 30, r.y + 50)
--         end)

--         return self.city:GetUser():PromiseOfFinishUpgrading()
--             :next(function()
--                 self:GetFteLayer():removeFromParent()
--                 self:GetFteLayer()
--             end)
--             :next(cocos_promise.delay(1))
--             :next(function()self:GetFteLayer():removeFromParent()end)
--     end
--     return cocos_promise.defer()
-- end
-- function GameUIHome:PromiseOfFteInstantSpeedUp()
--     if UtilsForBuilding:GetBuildingEventsCount(self.city:GetUser()) > 0 then
--         self:GetFteLayer()
--         self.event_tab:PromiseOfPopUp():next(function()
--             self:GetFteLayer():SetTouchObject(self:Find())
--             self:Find():removeEventListenersByEvent("CLICKED_EVENT")
--             self:Find():onButtonClicked(function()
--                 self:Find():setButtonEnabled(false)

--                 local event = UtilsForBuilding:GetBuildingEventsBySeq(self.city:GetUser())[1]
--                 if event then
--                     local building = UtilsForBuilding:GetBuildingByEvent(self.city:GetUser(), event)
--                     if event.buildingLocation then
--                         mockData.FinishBuildHouseAt(event.buildingLocation, building.level + 1)
--                     else
--                         mockData.FinishUpgradingBuilding(building.type, building.level + 1)
--                     end
--                 end
--             end)

--             local r = self:Find():getCascadeBoundingBox()
--             WidgetFteArrow.new(_("立即完成升级"))
--                 :addTo(self:GetFteLayer()):TurnDown(true)
--                 :align(display.RIGHT_BOTTOM, r.x + r.width/2 + 30, r.y + 50)

--         end)

--         return self.city:GetUser():PromiseOfFinishUpgrading()
--             :next(function()
--                 self:GetFteLayer():removeFromParent()
--                 self:GetFteLayer()
--             end)
--             :next(cocos_promise.delay(1))
--             :next(function()self:GetFteLayer():removeFromParent()end)
--     end
--     return cocos_promise.defer()
-- end
-- function GameUIHome:PromiseOfActivePromise()
--     self:GetFteLayer():SetTouchObject(self:FindVip())
--     local r = self:FindVip():getCascadeBoundingBox()

--     WidgetFteArrow.new(_("点击VIP，免费激活VIP")):addTo(self:GetFteLayer())
--         :TurnUp():align(display.TOP_CENTER, r.x + r.width/2, r.y)

--     return UIKit:PromiseOfOpen("GameUIVipNew"):next(function(ui)
--         self:GetFteLayer():removeFromParent()
--         return ui:PromiseOfFte()
--     end)
-- end
function GameUIHome:PromiseOfFteAlliance()
    self.bottom:TipsOnAlliance()
end
function GameUIHome:PromiseOfFteAllianceMap()
    local btn = self.change_map.btn
    btn:removeChildByTag(102)

    WidgetFteArrow.new(_("进入联盟地图\n体验更多玩法")):addTo(btn, 10, 102)
        :TurnDown(false):align(display.LEFT_BOTTOM, 20, 55)

    btn:stopAllActions()
    btn:performWithDelay(function() btn:removeChildByTag(102) end, 10)
end


return GameUIHome













local Localize_pve = import("..utils.Localize_pve")
local light_gem = import("..particles.light_gem")
local ChatManager = import("..entity.ChatManager")
local UILib = import("..ui.UILib")
local window = import("..utils.window")
local WidgetChat = import("..widget.WidgetChat")
local WidgetUseItems = import("..widget.WidgetUseItems")
local WidgetChangeMap = import("..widget.WidgetChangeMap")
local WidgetHomeBottom = import("..widget.WidgetHomeBottom")
local GameUIPveHomeNew = UIKit:createUIClass('GameUIPveHomeNew')
local stages = GameDatas.PvE.stages
local timer = app.timer



function GameUIPveHomeNew:OnUserDataChanged_countInfo(userData, deltaData)
    if self.task and self.task:TaskType() == "pveCount" then
        if deltaData("countInfo.pveCount") then
            self:OnUserDataChanged_growUpTasks()
        end
    end
end
function GameUIPveHomeNew:OnUserDataChanged_growUpTasks()
    local growUpTasks = User.growUpTasks
    local completeTask = UtilsForTask:GetFirstCompleteTasks(growUpTasks)[1]
    if completeTask then
        self.isFinished = true
        self.task = completeTask
    else
        self.isFinished = false
        self.task = City:GetRecommendTask()
    end

    if self.task then
        self.quest_bar_bg:show()
        self.quest_label:setString(self.task:Title())
    else
        self.quest_bar_bg:hide()
        self.quest_label:setString(_("当前没有推荐任务!"))
    end

    self:RefreshTaskStatus(self.isFinished)
end



function GameUIPveHomeNew:DisplayOn()
    self.visible_count = self.visible_count + 1
    self:FadeToSelf(self.visible_count > 0)
end
function GameUIPveHomeNew:DisplayOff()
    self.visible_count = self.visible_count - 1
    self:FadeToSelf(self.visible_count > 0)
end
function GameUIPveHomeNew:FadeToSelf(isFullDisplay)
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


function GameUIPveHomeNew:ctor(level)
    GameUIPveHomeNew.super.ctor(self, {type = UIKit.UITYPE.BACKGROUND})
    self.level = level
end
function GameUIPveHomeNew:onEnter()
    self.visible_count = 1
    self:CreateTop()
    self.bottom = self:CreateBottom()


    User:AddListenOnType(self, "growUpTasks")
    User:AddListenOnType(self, "countInfo")
    self:OnUserDataChanged_growUpTasks()
    display.newNode():addTo(self):schedule(function()
        local star = User:GetStageStarByIndex(self.level)
        self.stars:setString(string.format("%d/%d", star, User:GetStageTotalStars()))
        self.strenth_current:setString(User:GetResValueByType("stamina"))
        self.gem_label:setString(string.formatnumberthousands(User:GetGemValue()))

        local index = 1
        local stage_name = self.level.."_"..index
        while stages[stage_name] do
            local stage = stages[stage_name]
            if star >= tonumber(stage.needStar) and not User:IsStageRewardedByName(stage_name) then
                self:TipsOnReward()
                return
            end
            index = index + 1
            stage_name = self.level.."_"..index
        end
        self:TipsOnReward(false)
    end, 1)
end
function GameUIPveHomeNew:onExit()
    User:RemoveListenerOnType(self, "growUpTasks")
    User:RemoveListenerOnType(self, "countInfo")
end
function GameUIPveHomeNew:CreateTop()
    local top_bg = display.newSprite("head_bg.png")
        :align(display.TOP_CENTER, window.cx, window.top)
        :addTo(self)
    local size = top_bg:getContentSize()
    top_bg:setTouchEnabled(true)

    local btn = cc.ui.UIPushButton.new({normal = "pve_btn_up_60x48.png",
        pressed = "pve_btn_down_60x48.png"}):addTo(top_bg)
        :pos(88, size.height/2 + 10)
        :onButtonClicked(function()
            UIKit:newGameUI("GameUIPveSelect", self.level):AddToCurrentScene(true)
        end)
    display.newSprite("coordinate_128x128.png"):addTo(btn):scale(0.4)
     
    UIKit:ttfLabel({
        text = string.format(_("第%d章"), self.level),
        size = 22,
        color = 0xffedae,
    }):addTo(top_bg):align(display.LEFT_CENTER, 130, size.height/2 + 10)

    local stars_bg = display.newSprite("online_time_bg_96x36.png"):addTo(top_bg):align(display.LEFT_CENTER,size.width - 124, -95):scale(0.8)
    local star = display.newSprite("tmp_pve_star_bg.png"):addTo(top_bg):pos(size.width - 124, -95):scale(0.6)
                 display.newSprite("tmp_pve_star.png"):addTo(star):pos(32,32)

    self.stars = UIKit:ttfLabel({
        text = string.format("%d/%d", User:GetStageStarByIndex(self.level), User:GetStageTotalStars()),
        size = 20,
        color = 0xffedae,
        shadow = true,
    }):addTo(top_bg):align(display.LEFT_CENTER, size.width - 124 + 20, -95)



    local reward_btn = cc.ui.UIPushButton.new()
        :addTo(top_bg, 1)
        :onButtonClicked(function(event)
            UIKit:newGameUI("GameUIPveReward", self.level):AddToCurrentScene(true)
        end)
    reward_btn:setContentSize(cc.size(66,66))
    reward_btn:align(display.CENTER, size.width - 55, 0)
    self.reward_icon = display.newSprite("bottom_icon_package_66x66.png"):addTo(reward_btn)


    local button = cc.ui.UIPushButton.new(
        {normal = "gem_btn_up.png", pressed = "gem_btn_down.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        UIKit:newGameUI("GameUIStore"):AddToCurrentScene(true)
    end):addTo(top_bg):pos(top_bg:getContentSize().width - 130,55)
    local gem_icon = display.newSprite("store_gem_260x116.png"):addTo(button):pos(55, 2):scale(0.5)
    light_gem():addTo(gem_icon, 1022):pos(260/2, 116/2)

    self.gem_label = UIKit:ttfLabel({
        text = string.formatnumberthousands(City:GetUser():GetGemValue()),
        size = 20,
        color = 0xffd200,
    }):addTo(button):align(display.CENTER, -18, 0)


    local pve_back = display.newSprite("back_ground_pve.png"):addTo(top_bg)
        :align(display.LEFT_TOP, 40, 16):flipX(true)
    local size = pve_back:getContentSize()
    self.pve_back = pve_back
    self.strenth_icon = display.newSprite("dragon_lv_icon.png"):addTo(pve_back):pos(size.width - 20, 25)
    local add_btn = cc.ui.UIPushButton.new(
        {normal = "add_btn_up.png",pressed = "add_btn_down.png"}
        ,{})
        :addTo(pve_back):align(display.CENTER, 25, 25)
        :onButtonClicked(function ( event )
            WidgetUseItems.new():Create({
                item_name = "stamina_1"
            }):AddToCurrentScene()
        end)
    display.newSprite("+.png"):addTo(add_btn)

    self.strenth_current = UIKit:ttfLabel({
        text = User:GetResValueByType("stamina"),
        size = 20,
        color = 0xffedae,
        shadow = true,
    }):addTo(pve_back):align(display.RIGHT_CENTER, size.width / 2, 25)

    
    UIKit:ttfLabel({
        text = string.format("/%d", User:GetResProduction("stamina").limit),
        size = 20,
        color = 0xffedae,
        shadow = true,
    }):addTo(pve_back):align(display.LEFT_CENTER, size.width / 2, 25)
end
function GameUIPveHomeNew:CreateBottom()
    local bottom_bg = WidgetHomeBottom.new(City):addTo(self)
        :align(display.BOTTOM_CENTER, display.cx, display.bottom)

    self.chat = WidgetChat.new():addTo(bottom_bg)
        :align(display.CENTER, bottom_bg:getContentSize().width/2, bottom_bg:getContentSize().height)


        -- 任务条
    local quest_bar_bg = cc.ui.UIPushButton.new(
        {normal = "quest_btn_unfinished_566x46.png",pressed = "quest_btn_unfinished_566x46.png"},
        {scale9 = false}
    ):addTo(bottom_bg):pos(420, bottom_bg:getContentSize().height + 56):onButtonClicked(function(event)
        self.quest_bar_bg:removeChildByTag(111)
        local task = self.task
        if task then
            if self.isFinished then
                NetManager:getGrowUpTaskRewardsPromise(task:TaskType(), task.id):done(function()
                    GameGlobalUI:showTips(_("获得奖励"), task:GetRewards())
                    if not self.is_hooray_on then
                        self.is_hooray_on = true
                        app:GetAudioManager():PlayeEffectSoundWithKey("COMPLETE")

                        self:performWithDelay(function()
                            self.is_hooray_on = false
                        end, 1.5)
                    end
                end)
            else
                if task:TaskType() == "pveCount" then
                    return
                end
                app:EnterMyCityScene(false,"nil",function(scene)
                    local homePage = scene:GetHomePage()
                    if not homePage then
                        return
                    end
                    if task:TaskType() == "cityBuild" then
                        if task:IsBuild() then
                            homePage:GotoOpenBuildUI(task)
                        elseif task:IsUnlock() then
                            local buildings = UtilsForBuilding:GetBuildingsBy(User, task:Config().name)
                            homePage:GotoUnlockBuilding(buildings[1].location)
                        elseif task:IsUpgrade() then
                            homePage:GotoOpenBuildingUI(City:PreconditionByBuildingType(task:Config().name))
                        end
                    elseif task:TaskType() == "productionTech" then
                        UIKit:newGameUI("GameUIQuickTechnology", City, task:Config().name):AddToCurrentScene(true)
                    elseif task:TaskType() == "soldierCount" then
                        local barracks = City:GetFirstBuildingByType("barracks")
                        UIKit:newGameUI('GameUIBarracks', City, barracks, "recruit", task:Config().name):AddToCurrentScene(true)
                    elseif task:TaskType() == "pveCount" then
                        homePage:GotoExplore()
                    end
                end)
            end
        end
    end)
    self.quest_bar_bg = quest_bar_bg

    if UtilsForBuilding:GetFreeBuildQueueCount(User) > 0 then
        display.newSprite("fte_icon_arrow.png")
        :addTo(self.quest_bar_bg,10,111):pos(566/4, 5)
        :rotation(90):scale(0.8):runAction(
            cc.RepeatForever:create(transition.sequence({
                cc.MoveBy:create(0.5, cc.p(-10,0)),
                cc.MoveBy:create(0.5, cc.p(10,0))
            }))
        )
    end

    local light = display.newSprite("quest_light_36x34.png"):addTo(quest_bar_bg):pos(-302, 2)
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


    self.change_map = WidgetChangeMap.new(WidgetChangeMap.MAP_TYPE.PVE):addTo(self)

    return bottom_bg
end
function GameUIPveHomeNew:RefreshTaskStatus(finished)
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
function GameUIPveHomeNew:ChangeChatChannel(channel_index)
    self.chat:ChangeChannel(channel_index)
end
local WidgetLight = import("..widget.WidgetLight")
function GameUIPveHomeNew:TipsOnReward(enable)
    if enable == false then 
        self.reward_icon:removeAllChildren()
        self.reward_icon:stopAllActions()
        return 
    end
    if self.reward_icon:getNumberOfRunningActions() > 0 then return end
    if not self.reward_icon:getChildByTag(1) then 
        local size = self.reward_icon:getContentSize()
        WidgetLight.new():addTo(self.reward_icon, -1, 1)
        :scale(0.6):pos(size.width/2, size.height/2)
    end
    self.reward_icon:runAction(UIKit:ShakeAction(true,2))
end


return GameUIPveHomeNew














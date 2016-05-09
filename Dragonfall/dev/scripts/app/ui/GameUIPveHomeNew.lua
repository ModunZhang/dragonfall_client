local Localize_pve = import("..utils.Localize_pve")
local light_gem = import("..particles.light_gem")
local ChatManager = import("..entity.ChatManager")
local GameUIHome = import("..ui.GameUIHome")
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
    local finishedIndex = math.huge
    local finishedTask
    for i,v in ipairs(UtilsForTask:GetFirstCompleteTasks(growUpTasks)) do
        local index = UtilsForTask:GetTaskIndex(v:TaskType(), v.id)
        if finishedIndex > index then
            finishedIndex = index
            finishedTask = v
        end
    end

    local unfinishedIndex = math.huge
    local taskUnfinished = City:GetRecommendTask()
    if taskUnfinished then
        unfinishedIndex = UtilsForTask:GetTaskIndex(taskUnfinished:TaskType(), taskUnfinished.id)
    end

    if finishedTask and finishedIndex <= unfinishedIndex then
        self.task = finishedTask
    else
        self.task = taskUnfinished
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
    self.top = self:CreateTop()
    self.bottom = self:CreateBottom()


    User:AddListenOnType(self, "growUpTasks")
    User:AddListenOnType(self, "countInfo")
    self:OnUserDataChanged_growUpTasks()
    display.newNode():addTo(self):schedule(function()
        local star = User:GetStageStarByIndex(self.level)
        self.stars:setString(string.format("%d/%d", star, math.max(math.ceil(star/15),1) * 15))
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
        :addTo(self,2)
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

    local starCount = User:GetStageStarByIndex(self.level)
    self.stars = UIKit:ttfLabel({
        text = string.format("%d/%d",starCount,math.max(math.ceil(starCount/15)) * 15),
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
    return top_bg
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
            if self.task.finished then
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
                if task:TaskType() == "pveCount" then
                    local sindex = 1
                    for i = 1, 21 do
                        if User:IsPveEnable(self.level,i) then
                            sindex = i
                        else
                            break
                        end
                    end
                    display.getRunningScene():OpenUIByName(self.level.."_"..sindex, true)
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

    -- if UtilsForBuilding:GetFreeBuildQueueCount(User) > 0 then
    --     display.newSprite("finger.png")
    --     :addTo(self.quest_bar_bg,10,111):pos(180, -30):runAction(
    --         cc.RepeatForever:create(transition.sequence({
    --             cc.Spawn:create({cc.ScaleTo:create(0.5,0.95),cc.MoveBy:create(0.5, cc.p(-5,0))}),
    --             cc.Spawn:create({cc.ScaleTo:create(0.5,1.0),cc.MoveBy:create(0.5, cc.p( 5,0))})
    --         }))
    --     )
    -- end

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


    self.change_map = WidgetChangeMap.new(WidgetChangeMap.MAP_TYPE.PVE):addTo(self)

    return bottom_bg
end
function GameUIPveHomeNew:CheckFinger()
    if  self.task 
    and UtilsForFte:ShouldFingerOnTask(User) 
    and User.countInfo.isFTEFinished then
        if self.task.finished then
            self:ShowClickReward()
        elseif self.task:TaskType() ~= "pveCount" then
            self:ShowFinger()
        end
        return
    end

    self:HideFinger()
    self:HideClickReward()
end
local WidgetFteArrow = import("..widget.WidgetFteArrow")
function GameUIPveHomeNew:ShowClickReward()
    if not self.quest_bar_bg:getChildByTag(222) then
        WidgetFteArrow.new(_("点击领取奖励")):TurnDown()
        :addTo(self.quest_bar_bg,10,222):pos(100,50)
    end
    self.quest_bar_bg:getChildByTag(222):show()
    self:HideFinger()
end
function GameUIPveHomeNew:HideClickReward()
    if self.quest_bar_bg:getChildByTag(222) then
        self.quest_bar_bg:getChildByTag(222):hide()
    end
end
function GameUIPveHomeNew:ShowFinger()
    if not self.quest_bar_bg:getChildByTag(111) then
        UIKit:FingerAni():addTo(self.quest_bar_bg,10,111):pos(180, -30)
    end
    self.quest_bar_bg:getChildByTag(111):show()
    self:HideClickReward()
end
function GameUIPveHomeNew:HideFinger()
    if self.quest_bar_bg:getChildByTag(111) then
        self.quest_bar_bg:getChildByTag(111):hide()
    end
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



local RES_ICON_TAG = {
    food = 1010,
    wood = 1011,
    iron = 1012,
    coin = 1013,
    stone = 1014,
    -- citizen = 1015,
}
local icon_map = {
    food = "res_food_91x74.png",
    wood = "res_wood_82x73.png",
    iron = "res_iron_91x63.png",
    coin = "res_coin_81x68.png",
    stone = "res_stone_88x82.png",
}
local ResPositionMap = GameUIHome.ResPositionMap
function GameUIPveHomeNew:ShowResourceAni(resource, wp)
    if not icon_map[resource] then
        return
    end
    local pnt = self.top
    pnt:removeChildByTag(RES_ICON_TAG[resource])

    local lp = pnt:convertToNodeSpace(wp or cc.p(display.cx, display.cy))
    local tp = pnt:convertToNodeSpace(ResPositionMap[resource])

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
                end),
                cc.DelayTime:create(1),
                cc.RemoveSelf:create(),
            }
        })
    )
end


return GameUIPveHomeNew














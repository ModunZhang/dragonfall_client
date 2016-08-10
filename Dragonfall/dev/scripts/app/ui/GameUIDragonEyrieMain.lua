--
-- Author: Danny He
-- Date: 2014-10-28 16:14:06
--
local GameUIDragonEyrieMain = UIKit:createUIClass("GameUIDragonEyrieMain","GameUIUpgradeBuilding")
local GameUtils = GameUtils
local window = import("..utils.window")
local GameUINpc = import(".GameUINpc")
local TutorialLayer = import(".TutorialLayer")
local WidgetFteArrow = import("..widget.WidgetFteArrow")
local StarBar = import(".StarBar")
local WidgetDragons = import("..widget.WidgetDragons")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetProgress = import("..widget.WidgetProgress")
local DragonSprite = import("..sprites.DragonSprite")
local Localize = import("..utils.Localize")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUseItems = import("..widget.WidgetUseItems")
local GameUIDragonDeathSpeedUp = import(".GameUIDragonDeathSpeedUp")
local UICheckBoxButton = import(".UICheckBoxButton")

local terrain_map = {
    grassLand = "greenDragon",
    desert= "redDragon",
    iceField = "blueDragon",
}
-- lockDragon: 是否锁定选择龙的操作,默认不锁定
function GameUIDragonEyrieMain:ctor(city,building,default_tab,lockDragon,dragonType,show_setDefence_tip)
    GameUIDragonEyrieMain.super.ctor(self,city,_("龙巢"),building,default_tab)
    self.building = building
    self.city = city
    self.show_setDefence_tip = show_setDefence_tip
    self.draong_index = 1
    if type(lockDragon) ~= "boolean" then lockDragon = false end
    self.lockDragon = lockDragon

    if not UtilsForFte:IsHatchedAnyDragons(city:GetUser()) then
        self.dragonType = terrain_map[city:GetUser().basicInfo.terrain]
    else
        self.dragonType = dragonType
    end

    if not self.dragonSeq then
        local t = UtilsForDragon:GetSortDragonTypes(User)
        local powerfulType = UtilsForDragon:GetPowerfulDragonType(User)
        table.sort(t, function(a,b)
            return powerfulType == a
        end)
        if self.dragonType then
            local index = table.indexof(t,self.dragonType)
            local count = #t
            local dest = {}
            for i= index,count do
                table.insert(dest,t[i])
            end
            for i=1,index - 1 do
                table.insert(dest,t[i])
            end
            t = dest
        end
        self.dragonSeq = t
    end
end

function GameUIDragonEyrieMain:IsDragonLock()
    return self.lockDragon
end
function GameUIDragonEyrieMain:OnUserDataChanged_buildings(userData, deltaData)
    local ok,value = deltaData("buildings.location_4")
    if ok and self.hate_button then
        self.hate_button:setButtonEnabled(UtilsForDragon:CanHatchAnyDragons(userData))
    end
end
function GameUIDragonEyrieMain:OnUserDataChanged_dragons(userData, deltaData)
    for dragonType,dragon in pairs(userData.dragons) do
        if deltaData(string.format("dragons.%s", dragonType)) then
            local localIndex = self:GetDragonIndexByType(dragonType) - 1
            if self.draongContentNode then
                local eyrie = self.draongContentNode:GetItemByIndex(localIndex)
                if eyrie.dragon_image:isVisible() then
                    eyrie.dragon_image:hide()
                    eyrie.armature:show()
                    eyrie.armature:Resume()
                end
            end
        end
    end
    if deltaData("dragons") then
        self:RefreshUI()
    end
end
function GameUIDragonEyrieMain:OnUserDataChanged_dragonDeathEvents(userData, deltaData)
    if deltaData("dragonDeathEvents.add")
        or deltaData("dragonDeathEvents.edit")
        or deltaData("dragonDeathEvents.remove") then
        self:RefreshUI()
    end
end

------------------------------------------------------------------

function GameUIDragonEyrieMain:CreateBetweenBgAndTitle()
    GameUIDragonEyrieMain.super.CreateBetweenBgAndTitle(self)
    self.dragonNode = display.newNode():size(window.width,window.height):addTo(self:GetView(),3)
end


function GameUIDragonEyrieMain:OnMoveInStage()
    self:CreateUI()
    GameUIDragonEyrieMain.super.OnMoveInStage(self)

    User:AddListenOnType(self, "dragons")
    User:AddListenOnType(self, "buildings")
    User:AddListenOnType(self, "dragonDeathEvents")

    scheduleAt(self, function()
        local dragon = self:GetCurrentDragon()
        local event
        for i,v in ipairs(User.dragonDeathEvents) do
            if v.dragonType == dragon.type then
                event = v
            end
        end
        if event and self.progress_content_death
            and self.progress_content_death:isVisible()
        then
            local time, percent = UtilsForEvent:GetEventInfo(event)
            self.progress_death:setPercentage(percent)
            self.dragon_death_label:setString(GameUtils:formatTimeStyleDayHour(time))
        end

        if dragon.star > 0 then
            if self.dragon_hp_label and self.dragon_hp_label:isVisible() then
                local hp = UtilsForDragon:GetDragonHp(User, dragon.type)
                local hpMax = UtilsForDragon:GetDragonMaxHp(User.dragons[dragon.type])
                self.dragon_hp_label:setString(string.th000(hp) .. "/" .. string.th000(hpMax))
                self.progress_hated:setPercentage(hp/hpMax*100)
            end
        end
    end)
end
function GameUIDragonEyrieMain:onExit()
    User:RemoveListenerOnType(self, "dragons")
    User:RemoveListenerOnType(self, "buildings")
    User:RemoveListenerOnType(self, "dragonDeathEvents")
end

function GameUIDragonEyrieMain:CreateUI()
    self.tabButton = self:CreateTabButtons({
        {
            label = _("龙"),
            tag = "dragon",
        }
    },
    function(tag)
        self:TabButtonsAction(tag)
    end):pos(window.cx, window.bottom + 34)
end

function GameUIDragonEyrieMain:TabButtonsAction(tag)
    if tag == 'dragon' then
        self:CreateDragonContentNodeIf()
        self:RefreshUI()
        self.dragonNode:show()
    else
        self.dragonNode:hide()
    end
end

function GameUIDragonEyrieMain:RefreshUI()
    local dragon = self:GetCurrentDragon()
    if not self.dragon_info then return end
    if not (self:GetCurrentDragon().star > 0) then
        self.garrison_button:setButtonSelected(false)
        self.dragon_info:hide()
        self.death_speed_button:hide()
        self.progress_content_death:hide()
        self.progress_content_hated:hide()
        self.info_panel:hide()
        self.draogn_hate_node:show()
        self.star_bar:hide()
        self.hate_button:show()
    else
        self.star_bar:setNum(dragon.star)
        self.star_bar:show()
        self.draogn_hate_node:hide()
        self.garrison_button:setButtonSelected(dragon.status == "defence")
        self.info_panel:show()

        local strength = UtilsForDragon:GetDragonStrength(User.dragons[dragon.type])
        self.strength_val_label:setString(string.formatnumberthousands(strength))

        local hpMax = UtilsForDragon:GetDragonMaxHp(User.dragons[dragon.type])
        self.vitality_val_label:setString(string.formatnumberthousands(hpMax))
        local leadCitizen = UtilsForDragon:GetLeadershipByCitizen(User,dragon.type)
        self.leadership_val_label:setString(string.formatnumberthousands(leadCitizen))

        local isdead = UtilsForDragon:IsDragonDead(User, dragon.type)
        if isdead then
            local event
            for i,v in ipairs(User.dragonDeathEvents) do
                if v.dragonType == self:GetCurrentDragon().type then
                    event = v
                end
            end
            if event then
                local time, percent = UtilsForEvent:GetEventInfo(event)
                self.progress_death:setPercentage(percent)
                self.dragon_death_label:setString(GameUtils:formatTimeStyleDayHour(time))
            end
            self.death_speed_button:show()
            self.progress_content_death:show()
            self.progress_content_hated:hide()
            self.state_label:setString(Localize.dragon_status['dead'])
            self.state_label:setColor(UIKit:hex2c3b(0x7e0000))

        else
            self.dragon_info:show()
            self.progress_content_hated:show()
            local recovery = UtilsForDragon:GetDragonHPRecoveryWithBuff(User, dragon.type)
            self.dragon_hp_recovery_count_label:setString(string.format("+%s/h", recovery))

            local hp = UtilsForDragon:GetDragonHp(User, dragon.type)
            local hpMax = UtilsForDragon:GetDragonMaxHp(User.dragons[dragon.type])
            self.dragon_hp_label:setString(string.formatnumberthousands(hp) .. "/" .. string.formatnumberthousands(hpMax))
            self.progress_hated:setPercentage(hp/hpMax * 100)

            self.state_label:setString(Localize.dragon_status[dragon.status])
            if dragon.status == "defence" or dragon.status == "free" then
                self.state_label:setColor(UIKit:hex2c3b(0x07862b))
            else
                self.state_label:setColor(UIKit:hex2c3b(0x7e0000))
            end
            self.death_speed_button:hide()
            self.progress_content_death:hide()
        end
        self.draong_info_lv_label:setString("LV " .. dragon.level .. "/" .. UtilsForDragon:GetDragonLevelMax(dragon))
        self.draong_info_xp_label:setString(string.formatnumberthousands(dragon.exp) .. "/" .. string.formatnumberthousands(UtilsForDragon:GetDragonExpNeed(dragon)))
        -- self.expIcon:setPositionX(self.draong_info_xp_label:getPositionX() - self.draong_info_xp_label:getContentSize().width/2 - 10)
        -- self.exp_add_button:setPositionX(self.draong_info_xp_label:getPositionX() + self.draong_info_xp_label:getContentSize().width/2 + 10)
    end
    self.nameLabel:setString(Localize.dragon[dragon.type])
end

function GameUIDragonEyrieMain:CreateProgressTimer()
    local bg,progressTimer = nil,nil
    bg = display.newSprite("process_bar_540x40.png")
    progressTimer = UIKit:commonProgressTimer("progress_bar_540x40_2.png"):addTo(bg):align(display.LEFT_CENTER,0,20)
    progressTimer:setPercentage(0)
    local iconbg = display.newSprite("drgon_process_icon_bg.png")
        :addTo(bg)
        :align(display.LEFT_BOTTOM, -13,-2)
    display.newSprite("dragon_lv_icon.png")
        :addTo(iconbg)
        :pos(iconbg:getContentSize().width/2,iconbg:getContentSize().height/2)
    self.dragon_hp_label = UIKit:ttfLabel({
        text = "",
        color = 0xfff3c7,
        shadow = true,
        size = 20
    }):addTo(bg):align(display.LEFT_CENTER, 40, 20)

    self.dragon_hp_recovery_count_label = UIKit:ttfLabel({
        text =  "",
        color = 0xfff3c7,
        shadow = true,
        size = 20
    }):addTo(bg):align(display.RIGHT_CENTER, bg:getContentSize().width - 50, 20)
    local add_button = WidgetPushButton.new({normal = "add_btn_up_50x50.png",pressed = "add_btn_down_50x50.png"})
        :addTo(bg)
        :align(display.CENTER_RIGHT,bg:getContentSize().width+10,20)
        :onButtonClicked(function()
            self:OnDragonHpItemUseButtonClicked()
        end)
    return bg,progressTimer
end

function GameUIDragonEyrieMain:CreateDeathEventProgressTimer()
    local bg,progressTimer = nil,nil
    bg = display.newSprite("progress_bar_364x40_1.png")
    progressTimer = UIKit:commonProgressTimer("progress_bar_yellow_364x40.png"):addTo(bg):align(display.LEFT_CENTER,0,20)
    progressTimer:setPercentage(0)
    local icon_bg = display.newSprite("back_ground_43x43.png"):align(display.LEFT_CENTER, -20, 20):addTo(bg)
    display.newSprite("hourglass_30x38.png"):align(display.CENTER, 22, 22):addTo(icon_bg):scale(0.8)
    self.dragon_death_label = UIKit:ttfLabel({
        text = "",
        size = 22,
        color= 0xfff3c7,
        shadow= true
    }):addTo(bg):align(display.LEFT_CENTER, 50,20)
    return bg,progressTimer
end

function GameUIDragonEyrieMain:CreateDragonContentNodeIf()
    if not self.draongContentNode then
        self:CreateDragonHateNodeIf()
        local dragonAnimateNode,draongContentNode = self:CreateDragonScrollNode()
        self.draongContentNode = draongContentNode
        self.draongContentNode:SetScrollable(not self:IsDragonLock())
        dragonAnimateNode:addTo(self.dragonNode):pos(window.cx - 310,window.top_bottom - 576)
        -- 阻挡滑动龙超出的区域
        display.newLayer():addTo(self.dragonNode):pos(window.cx - 310,window.top_bottom - 676):size(620,100)
        --info
        local info_bg = display.newSprite("dragon_info_bg_290x92.png")
            :align(display.BOTTOM_CENTER, 309, 50)
            :addTo(dragonAnimateNode)
        local lv_bg = display.newSprite("dragon_lv_bg_270x30.png")
            :addTo(info_bg)
            :align(display.TOP_CENTER,info_bg:getContentSize().width/2,info_bg:getContentSize().height-10)
        info_bg:setTouchEnabled(true)
        self.dragon_info = info_bg

        local levelMax = UtilsForDragon:GetDragonLevelMax(self:GetCurrentDragon())
        self.draong_info_lv_label = UIKit:ttfLabel({
            text = "LV " .. self:GetCurrentDragon().level .. "/" .. levelMax,
            color = 0xffedae,
            size = 20
        }):addTo(lv_bg):align(display.CENTER,lv_bg:getContentSize().width/2,lv_bg:getContentSize().height/2)
        self.draong_info_xp_label = UIKit:ttfLabel({
            text = self:GetCurrentDragon().exp .. "/" .. UtilsForDragon:GetDragonExpNeed(self:GetCurrentDragon()),
            color = 0x403c2f,
            size = 20,
            align = cc.TEXT_ALIGNMENT_CENTER,
        }):align(display.CENTER_BOTTOM, 145, 20):addTo(info_bg)
        local expIcon = display.newSprite("upgrade_experience_icon.png")
            :addTo(info_bg)
            :scale(0.7)
            :align(display.BOTTOM_LEFT, 10,9)
        self.expIcon = expIcon
        local add_button = WidgetPushButton.new({normal = "add_btn_up_50x50.png",pressed = "add_btn_down_50x50.png"})
            :addTo(info_bg)
            :scale(0.8)
            :align(display.RIGHT_CENTER,info_bg:getContentSize().width - 10,9 + expIcon:getCascadeBoundingBox().height/2)
            :onButtonClicked(function()
                self:OnDragonExpItemUseButtonClicked()
            end)
        self.exp_add_button = add_button
        -- info end
        self.nextButton = cc.ui.UIPushButton.new({
            normal = "dragon_next_icon_28x31.png"
        })
            :addTo(dragonAnimateNode)
            :align(display.BOTTOM_CENTER, 306+170,80)
            :onButtonClicked(function()
                self:ChangeDragon('next')
            end)
        self.preButton = cc.ui.UIPushButton.new({
            normal = "dragon_next_icon_28x31.png"
        })
            :addTo(dragonAnimateNode)
            :align(display.TOP_CENTER, 306-170,80)
            :onButtonClicked(function()
                self:ChangeDragon('pre')
            end)
        self.preButton:setRotation(180)

        local info_layer = UIKit:shadowLayer():size(619,40):pos(window.left+10,dragonAnimateNode:getPositionY()):addTo(self.dragonNode)
        display.newSprite("line_624x58.png"):align(display.LEFT_TOP,0,20):addTo(info_layer)
        local nameLabel = UIKit:ttfLabel({
            text = "",
            color = 0xffedae,
            size  = 24
        }):addTo(info_layer):align(display.LEFT_CENTER,20, 20)
        local star_bar = StarBar.new({
            max = UtilsForDragon.dragonStarMax,
            bg = "Stars_bar_bg.png",
            fill = "Stars_bar_highlight.png",
            num = self:GetCurrentDragon().star,
            margin = 0,
        }):addTo(info_layer):align(display.RIGHT_CENTER, 610,20)
        self.nameLabel = nameLabel
        self.star_bar = star_bar
        --驻防
        local checkbox_image = {on = "draon_garrison_btn_d_82x86.png",off = "draon_garrison_btn_n_82x86.png",}
        local dragon = self:GetCurrentDragon()

        self.garrison_button = UICheckBoxButton.new(checkbox_image)
            :addTo(dragonAnimateNode):align(display.LEFT_BOTTOM, 25, 310)
            :setButtonSelected(dragon.status == "defence")
            :onButtonClicked(function()
                local target = self.garrison_button:isButtonSelected()
                self.garrison_button:setButtonSelected(false)
                local dragon = self:GetCurrentDragon()
                if target then
                    if not (dragon.star > 0) then
                        UIKit:showMessageDialog(nil,_("龙还未孵化"))
                        self.garrison_button:setButtonSelected(not target,false)
                        return
                    end
                    local isdead = UtilsForDragon:IsDragonDead(User, dragon.type)
                    if isdead then
                        UIKit:showMessageDialog(nil,_("选择的龙已经死亡"))
                        self.garrison_button:setButtonSelected(not target,false)
                        return
                    end
                    if dragon.status == "free" then
                        local military_soldiers
                        if not UtilsForFte:IsDefencedWithTroops(self.city:GetUser()) then
                            military_soldiers = {{name = "swordsman_1", count = 10}}
                        end
                        UIKit:newGameUI('GameUISendTroopNew',function(dragonType,soldiers)
                            local isdead = UtilsForDragon:IsDragonDead(User, dragonType)
                            if isdead then
                                UIKit:showMessageDialog(nil,_("选择的龙已经死亡"))
                                return
                            end
                            if UtilsForDragon:GetDefenceDragon(User) then
                                NetManager:getCancelDefenceTroopPromise():done(function()
                                    NetManager:getSetDefenceTroopPromise(dragonType,soldiers):done(function ()
                                        if self:GetCurrentDragon().type == dragonType then
                                            self.garrison_button:setButtonSelected(true)
                                        end
                                    end)
                                end)
                            else
                                NetManager:getSetDefenceTroopPromise(dragonType,soldiers):done(function ()
                                    if self:GetCurrentDragon().type == dragonType then
                                        self.garrison_button:setButtonSelected(true)
                                    end
                                    if self.defencePromise then
                                        self.defencePromise:resolve()
                                    end
                                end)
                            end
                        end,{
                            dragon = dragon,
                            isMilitary = true,
                            terrain = Alliance_Manager:GetMyAlliance().basicInfo.terrain,
                            title = _("驻防部队"),
                            military_soldiers = military_soldiers,
                        }):AddToCurrentScene(true)
                    else
                        UIKit:showMessageDialog(nil,_("龙未处于空闲状态"))
                        self.garrison_button:setButtonSelected(not target,false)
                    end
                else
                    if dragon.status == "defence" then
                        NetManager:getCancelDefenceTroopPromise():done(function()
                            GameGlobalUI:showTips(_("提示"),_("取消驻防成功"))
                        end)
                    else
                        UIKit:showMessageDialog(nil,_("还没有驻防"))
                        self.garrison_button:setButtonSelected(not target,false)
                    end
                end
            end)
        if not UtilsForDragon:GetDefenceDragon(User) and self.show_setDefence_tip then
            local r = self.garrison_button:getCascadeBoundingBox()
            local arrow = WidgetFteArrow.new(_("点击：驻防"))
                :addTo(self:GetView()):TurnUp(false):align(display.LEFT_TOP, r.x + 30, r.y - 20)
            self:performWithDelay(function()
                self:GetView():removeChild(arrow, true)
            end, 3)
        end


        --
        self.progress_content_hated,self.progress_hated = self:CreateProgressTimer()
        self.progress_content_hated:align(display.CENTER_TOP,window.cx,info_layer:getPositionY()-18):addTo(self.dragonNode)
        --
        self.progress_content_death,self.progress_death = self:CreateDeathEventProgressTimer()
        self.progress_content_death:align(display.LEFT_TOP,window.left+60,info_layer:getPositionY()-20):addTo(self.dragonNode)

        self.death_speed_button = WidgetPushButton.new({normal = 'green_btn_up_148x58.png',pressed = 'green_btn_down_148x58.png'})
            :setButtonLabel("normal",UIKit:commonButtonLable({
                text = _("加速")
            })):addTo(self.dragonNode)
            :align(display.LEFT_TOP,self.progress_content_death:getPositionX()+self.progress_content_death:getContentSize().width+18,
                self.progress_content_death:getPositionY()+7)
            :onButtonClicked(handler(self, self.OnDragonDeathSpeedUpClicked))
        local info_panel = UIKit:CreateBoxPanel9({width = 548, height = 114})
            :addTo(self.dragonNode)
            :align(display.CENTER_TOP,window.cx,self.progress_content_hated:getPositionY() - self.progress_content_hated:getContentSize().height - 32)
        self.info_panel = info_panel
        local strength_title_label =  UIKit:ttfLabel({
            text = _("攻击力"),
            color = 0x615b44,
            size  = 20
        }):addTo(info_panel):align(display.LEFT_BOTTOM,10,80)--  10 45
        self.strength_val_label =  UIKit:ttfLabel({
            text = "",
            color = 0x403c2f,
            size  = 20
        }):addTo(info_panel):align(display.RIGHT_BOTTOM, 234, 80) -- 活力

        local vitality_title_label =  UIKit:ttfLabel({
            text = _("生命值"),
            color = 0x615b44,
            size  = 20
        }):addTo(info_panel):align(display.LEFT_BOTTOM,10,45) -- 领导力 10

        self.vitality_val_label =  UIKit:ttfLabel({
            text = "",
            color = 0x403c2f,
            size  = 20
        }):addTo(info_panel):align(display.RIGHT_BOTTOM, 234, 45)

        local leadership_title_label =  UIKit:ttfLabel({
            text = _("带兵量"),
            color = 0x615b44,
            size  = 20
        }):addTo(info_panel):align(display.LEFT_BOTTOM,10,10) -- 力量

        self.leadership_val_label =  UIKit:ttfLabel({
            text = "",
            color = 0x403c2f,
            size  = 20
        }):addTo(info_panel):align(display.RIGHT_BOTTOM, 234, 10)

        self.state_label = UIKit:ttfLabel({
            text = "",
            color = 0x07862b,
            size  = 20
        }):addTo(info_panel):align(display.CENTER_BOTTOM,540 - 74,75)
        local detailButton = WidgetPushButton.new({
            normal = "blue_btn_up_148x58.png",pressed = "blue_btn_down_148x58.png"
        }):setButtonLabel("normal",UIKit:ttfLabel({
            text = _("详情"),
            size = 24,
            color = 0xffedae,
            shadow = true
        })):addTo(info_panel):align(display.RIGHT_BOTTOM,540,5):onButtonClicked(function(event)
            local triggerTips
            if event.target:getChildByTag(111) then
                triggerTips = true
                event.target:removeChildByTag(111)
            end
            UIKit:newGameUI("GameUIDragonEyrieDetail",
                            self.city,
                            self.building,
                            self:GetCurrentDragon().type,
                            triggerTips):AddToCurrentScene(false)
            self:LeftButtonClicked()
        end)
        self.detailButton = detailButton


        if UtilsForFte:NeedTriggerTips(User) and
            not app:GetGameDefautlt():IsPassedTriggerTips(self.building:GetType()) then
            UIKit:FingerAni():addTo(detailButton:zorder(10),10,111):pos(-10,-20)
            GameUINpc:PromiseOfSay(
                {npc = "woman", words = _("领主大人，巨龙的攻击力将直接影响战斗中龙战斗的胜负；而带兵量即为当前巨龙能带领出征的士兵数量。")}
            ):next(function()
                if not tolua.isnull(self) then
                    app:GetGameDefautlt():SetPassTriggerTips(self.building:GetType())
                end
                return GameUINpc:PromiseOfLeave()
            end)
        end
        self.draongContentNode:OnEnterIndex(math.abs(0))
    end

end

function GameUIDragonEyrieMain:CreateDragonHateNodeIf()
    if not self.draogn_hate_node then
        local node = display.newNode():size(window.width,210):addTo(self.dragonNode):pos(0,window.bottom_top)
        self.draogn_hate_node = node
        WidgetUIBackGround.new({width = 554, height = 100},WidgetUIBackGround.STYLE_TYPE.STYLE_3):addTo(node):align(display.CENTER_TOP, window.cx, 210)
        local tip_label = UIKit:ttfLabel({
            text = Localize.dragon_buffer[self:GetCurrentDragon().type],
            size = 20,
            color= 0x403c2f,
            align= cc.TEXT_ALIGNMENT_CENTER
        }):addTo(node):align(display.CENTER_TOP, window.cx, 200)
        self.dragon_hate_tips_label = tip_label
        local level = UtilsForDragon:HowManyLevelsCanHatchDragons(User)
        local hate_label = UIKit:ttfLabel({
            text = level and string.format(_("龙巢%d级时可孵化新的巨龙"),level) or "",
            size = 20,
            color= 0x403c2f,
            align= cc.TEXT_ALIGNMENT_CENTER,
            dimensions = cc.size(520,0)
        }):addTo(node):align(display.CENTER, window.cx, 150)
        self.hate_label = hate_label
        local hate_button = WidgetPushButton.new({ normal = "yellow_btn_up_186x66.png",pressed = "yellow_btn_down_186x66.png", disabled = "grey_btn_186x66.png"})
            :setButtonLabel("normal",UIKit:commonButtonLable({
                text = _("开始孵化"),
                size = 24,
                color = 0xffedae,
            }))
            :addTo(node):align(display.CENTER_BOTTOM,window.cx,35)
            :onButtonClicked(function()
                self:OnEnergyButtonClicked()
            end)
        hate_button:setButtonEnabled(UtilsForDragon:CanHatchAnyDragons(User))
        self.hate_button = hate_button
    end
    return self.draogn_hate_node
end


function GameUIDragonEyrieMain:OnEnergyButtonClicked()
    if not UtilsForDragon:CanHatchAnyDragons(User) then
        UIKit:showMessageDialog(nil, _("当前龙巢等级不能孵化新的巨龙"), function()end)
        return
    end

    local level = UtilsForDragon:HowManyLevelsCanHatchDragons(User)
    return NetManager:getHatchDragonPromise(self:GetCurrentDragon().type)
    :done(function ()
        self.hate_label:setString(level and string.format(_("龙巢%d级时可孵化新的巨龙"),level) or "")
        self.hate_button:setButtonEnabled(UtilsForDragon:CanHatchAnyDragons(User))
        if self.hatchPromise then
            self.hatchPromise:resolve()
        end
    end)
end

function GameUIDragonEyrieMain:GetCurrentDragon()
    return User.dragons[self:GetDragonTypeByIndex(self.draong_index)]
end
function GameUIDragonEyrieMain:GetDragonIndexByType(dragonType)
    local t = self.dragonSeq
    if self.dragonType then
        local index = table.indexof(t,self.dragonType)
        local count = #t
        local dest = {}
        for i= index,count do
            table.insert(dest,t[i])
        end
        for i=1,index - 1 do
            table.insert(dest,t[i])
        end
        t = dest
    end
    for i,v in ipairs(t) do
        if v == dragonType then
            return i
        end
    end
end
function GameUIDragonEyrieMain:GetDragonTypeByIndex(index)
    return self.dragonSeq[index]
end
function GameUIDragonEyrieMain:CreateDragonScrollNode()
    local clipNode = display.newClippingRegionNode(cc.rect(0,0,620,600))
    local contenNode = WidgetDragons.new(
        {
            OnLeaveIndexEvent = handler(self, self.OnLeaveIndexEvent),
            OnEnterIndexEvent = handler(self, self.OnEnterIndexEvent),
            OnTouchClickEvent = handler(self, self.OnTouchClickEvent),
        }
    ):addTo(clipNode):pos(310,300)
    for i,v in ipairs(contenNode:GetItems()) do
        local dragon = User.dragons[self:GetDragonTypeByIndex(i)]
        local dragon_image = display.newSprite(string.format("%s_egg_176x192.png",dragon.type))
            :align(display.CENTER, 300,355)
            :addTo(v)
        v.dragon_image = dragon_image
        dragon_image.resolution = {dragon_image:getContentSize().width,dragon_image:getContentSize().height}
        local dragon_armature = DragonSprite.new(display.getRunningScene():GetSceneLayer(),dragon.type)
            :addTo(v)
            :pos(300,350)
            :hide():scale(0.9)
        v.armature = dragon_armature
        v.armature:Pause()
        if dragon.star > 0 then
            v.armature:show()
            v.dragon_image:hide()
        end
    end
    return clipNode,contenNode
end
function GameUIDragonEyrieMain:OnEnterIndexEvent(index)
    if self.draongContentNode then
        self.draong_index = index + 1
        self:RefreshUI()
        local eyrie = self.draongContentNode:GetItemByIndex(index)
        if not (self:GetCurrentDragon().star > 0) then
            self.dragon_hate_tips_label:setString(Localize.dragon_buffer[self:GetCurrentDragon().type])
            return
        end
        eyrie.dragon_image:hide()
        eyrie.armature:show()
        eyrie.armature:Resume()
    end
end

function GameUIDragonEyrieMain:OnTouchClickEvent(index)
    local localIndex = index + 1
    if self.draong_index == localIndex then
        local dragon = User.dragons[self:GetDragonTypeByIndex(localIndex)]
        if dragon and dragon.star > 0 then
            app:GetAudioManager():PlayBuildingEffectByType('dragonEyrie')
        end
    end
end

function GameUIDragonEyrieMain:OnLeaveIndexEvent(index)
    if self.draongContentNode then
        local eyrie = self.draongContentNode:GetItemByIndex(index)
        if not (self:GetCurrentDragon().star > 0) then return end
        eyrie.armature:Pause()
        -- eyrie.armature:hide()
        -- eyrie.dragon_image:show()
    end
end

function GameUIDragonEyrieMain:ChangeDragon(direction)
    if self.isChanging or self:IsDragonLock() then return end
    self.isChanging = true
    if direction == 'next' then
        if self.draong_index + 1 > 3 then
            self.draong_index = 1
        else
            self.draong_index = self.draong_index + 1
        end
        self.draongContentNode:Next()
        self.isChanging = false
    else
        if self.draong_index - 1 == 0 then
            self.draong_index = 3
        else
            self.draong_index = self.draong_index - 1
        end
        self.draongContentNode:Before()
        self.isChanging = false
    end
end
function GameUIDragonEyrieMain:OnDragonHpItemUseButtonClicked()
    local widgetUseItems = WidgetUseItems.new():Create({
        item_name = "dragonHp_1",
        dragon = self:GetCurrentDragon()
    })
    widgetUseItems:AddToCurrentScene()
end

function GameUIDragonEyrieMain:OnDragonExpItemUseButtonClicked()
    local widgetUseItems = WidgetUseItems.new():Create({
        item_name = "dragonExp_1",
        dragon = self:GetCurrentDragon()
    })
    widgetUseItems:AddToCurrentScene()
end

function GameUIDragonEyrieMain:OnDragonDeathSpeedUpClicked()
    UIKit:newGameUI("GameUIDragonDeathSpeedUp", self:GetCurrentDragon().type):AddToCurrentScene(true)
end





-- fte
local promise = import("..utils.promise")
local cocos_promise = import("..utils.cocos_promise")
local WidgetFteArrow = import("..widget.WidgetFteArrow")
function GameUIDragonEyrieMain:FindHateBtn()
    return self.hate_button
end
function GameUIDragonEyrieMain:FindGarrisonBtn()
    return self.garrison_button
end
function GameUIDragonEyrieMain:FindDetailBtn()
    return self.detailButton
end
function GameUIDragonEyrieMain:PromiseOfFte()
    local p = cocos_promise.defer()
    local user = self.city:GetUser()
    if not UtilsForFte:IsHatchedAnyDragons(user) then
        p:next(function()
            return self:PromiseOfHate()
        end)
    end
    p:next(function()
        return GameUINpc:PromiseOfSay({words = _("不可思议，传说是真的？！觉醒者过让能够号令龙族。。。大人您真是厉害！"), brow = "shy"})
    end):next(function()
        return GameUINpc:PromiseOfLeave()
    end)
    if not UtilsForFte:IsStudyAnyDragonSkill(user) then
        p:next(function()
            return self:PormiseOfLearnSkill()
        end)
    end
    if not UtilsForFte:IsDefencedWithTroops(user) then
        p:next(function()
            return self:PormiseOfDefence()
        end)
    end
    p:next(function()
        return self:PromsieOfExit("GameUIDragonEyrieMain")
    end)
    return p
end
function GameUIDragonEyrieMain:PromiseOfHate()
    local r = self:FindHateBtn():getCascadeBoundingBox()
    self:GetFteLayer():SetTouchObject(self:FindHateBtn())
    WidgetFteArrow.new(_("点击按钮：孵化")):addTo(self:GetFteLayer())
    :TurnUp():pos(r.x + r.width/2, r.y - 40)

    self.hatchPromise = promise.new()
    return self.hatchPromise:next(function()
        if checktable(ext.market_sdk) and ext.market_sdk.onPlayerEventAF then
            ext.market_sdk.onPlayerEventAF("强制引导-孵化巨龙", "empty")
        end
        self:DestroyFteLayer()
    end)
end
function GameUIDragonEyrieMain:PormiseOfDefence()
    self:FindGarrisonBtn():setTouchSwallowEnabled(true)
    self:GetFteLayer():SetTouchObject(self:FindGarrisonBtn())

    UIKit:PromiseOfOpen("GameUISendTroopNew")
    :next(function(ui)
        ui:PromiseOfFte()
        self:DestroyFteLayer()
    end)

    local r = self:FindGarrisonBtn():getCascadeBoundingBox()
    WidgetFteArrow.new(_("点击设置：巨龙在城市驻防，如果敌军入侵，巨龙会自动带领士兵进行防御"))
        :addTo(self:GetFteLayer()):TurnUp(false):align(display.LEFT_TOP, r.x + 30, r.y - 20)

    self.defencePromise = promise.new()
    return self.defencePromise:next(function()
        if checktable(ext.market_sdk) and ext.market_sdk.onPlayerEventAF then
            ext.market_sdk.onPlayerEventAF("强制引导-部队驻防", "empty")
        end

        self:FindGarrisonBtn():setButtonEnabled(false)
        self:DestroyFteLayer()
    end)
end
function GameUIDragonEyrieMain:PormiseOfLearnSkill()
    local p = promise.new()
    self:GetFteLayer():SetTouchObject(self:FindDetailBtn())
    local r = self:FindDetailBtn():getCascadeBoundingBox()
    WidgetFteArrow.new(_("点击详情:学习技能"))
        :addTo(self:GetFteLayer()):TurnRight():align(display.RIGHT_CENTER, r.x - 10, r.y + r.height/2)

    self:FindDetailBtn():removeEventListenersByEvent("CLICKED_EVENT")
    self:FindDetailBtn():onButtonClicked(function()
        UIKit:newGameUI("GameUIDragonEyrieDetail",self.city,self.building,self:GetCurrentDragon().type):AddToCurrentScene(false)
    end)

    UIKit:PromiseOfOpen("GameUIDragonEyrieDetail")
    :next(function(ui)
        self:DestroyFteLayer()
        ui:PromiseOfFte():next(function()
            p:resolve()
        end)
    end)
    return p
end


return GameUIDragonEyrieMain



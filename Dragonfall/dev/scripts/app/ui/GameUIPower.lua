--
-- Author: Your Name
-- Date: 2016-04-28 09:20:45
--
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIMission = import(".GameUIMission")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")


local GameUIPower = UIKit:createUIClass("GameUIPower", "UIAutoClose")

function GameUIPower:ctor()
    GameUIPower.super.ctor(self)
    self.body = display.newScale9Sprite("background_notice_128x128_1.png", 0, 0,cc.size(496,484),cc.rect(30,30,68,68))
        :align(display.TOP_CENTER,display.cx,y or display.top-200)
    local body = self.body
    self:addTouchAbleChild(body)
    local rb_size = body:getContentSize()
    local title = display.newSprite("title_red_634x134.png"):align(display.CENTER, rb_size.width/2, rb_size.height - 4)
        :addTo(body)
        :scale(0.84)
    display.newSprite("icon_dragon_54x38.png"):align(display.CENTER, rb_size.width/2 - 140, rb_size.height + 14)
        :addTo(body)
    display.newSprite("icon_dragon_54x38.png"):align(display.CENTER, rb_size.width/2 + 140, rb_size.height + 14)
        :addTo(body)
        :flipX(true)
    self.title_label = UIKit:ttfLabel({
        text = _("战斗力"),
        size = 16,
        color = 0x9a946b,
    }):align(display.CENTER, rb_size.width/2, rb_size.height + 32)
        :addTo(body)
    self.power_label = UIKit:ttfLabel({
        text = string.formatnumberthousands(User.basicInfo.power),
        size = 24,
        color = 0xffedae,
        shadow = true
    }):align(display.CENTER, rb_size.width/2, rb_size.height + 12)
        :addTo(body)
    self.second_title_label = UIKit:ttfLabel({
        text = "",
        size = 24,
        color = 0xffedae,
        shadow = true
    }):align(display.CENTER, rb_size.width/2, rb_size.height + 18)
        :addTo(body)
        :hide()
    local bg = display.newScale9Sprite("background_notice_128x128_2.png", 0, 0,cc.size(458,420),cc.rect(15,15,98,98))
        :align(display.CENTER_BOTTOM,rb_size.width/2,20)
        :addTo(body)
    -- close button
    self.close_btn = WidgetPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:LeftButtonClicked()
            end
        end):align(display.RIGHT_CENTER, rb_size.width + 34,rb_size.height):addTo(body)
end

function GameUIPower:GetBody()
    return self.body
end

function GameUIPower:SetTitle(title)
    self.title_label:setString(title)
    return self
end
function GameUIPower:onEnter()
    GameUIPower.super.onEnter(self)
    local body = self.body
    local rb_size = body:getContentSize()
    self:CreateMainMenu()
    self:CreateGrowthMenu()
    self:CreateStrongthMenu()
    self:CreateFightMenu()
    self:CreateBoredMenu()
    User:AddListenOnType(self, "basicInfo")


end
function GameUIPower:onExit()
    User:RemoveListenerOnType(self, "basicInfo")
    GameUIPower.super.onExit(self)
end
local main_menu = {
    _("我要发展"),
    _("我要变强"),
    _("我要开战"),
    _("我很无聊"),
}
function GameUIPower:CreateMainMenu()
    local rb_size = self.body:getContentSize()
    local menu_node = display.newNode()
    menu_node:setContentSize(cc.size(424,420))
    menu_node:align(display.CENTER_BOTTOM,rb_size.width/2,20)
        :addTo(self.body)

    for i,v in ipairs(main_menu) do
        self:CreateBtn(v,function ()
            menu_node:hide()
            self:ShowOrHide(i)
        end):align(display.CENTER_TOP, 424/2, 408 - (i - 1) * 82):addTo(menu_node)
    end
    self.menu_node = menu_node
end
-- 我要发展
function GameUIPower:CreateGrowthMenu()
    local rb_size = self.body:getContentSize()
    local growth_node = display.newNode()
    growth_node:setContentSize(cc.size(424,420))
    growth_node:align(display.CENTER_BOTTOM,rb_size.width/2,20)
        :addTo(self.body)
    local btns = {
        {_("城堡"),_("提升所有建筑等级上限")},
        {_("兵营"),_("解锁高级兵种")},
        {_("学院"),_("解锁新科技")},
        {_("工具作坊"),_("制作建筑和军事材料")},
        {_("获得资源"),_("升级资源建筑")},
    }
    for i,v in ipairs(btns) do
        self:CreateBtn(v,function ()
            if i == 1 then
                UIKit:newGameUI("GameUIKeep", City, City:GetFirstBuildingByType("keep"), "upgrade"):AddToCurrentScene(true)
            elseif i == 2 then
                if #UtilsForBuilding:GetBuildingsBy(User, "barracks", 1) > 0 then
                    UIKit:newGameUI("GameUIBarracks", City, City:GetFirstBuildingByType("barracks"), "upgrade"):AddToCurrentScene(true)
                else
                    UIKit:showMessageDialog(_("提示"),string.format(_("%s还未解锁"),_("兵营")))
                end
            elseif i == 3 then
                if #UtilsForBuilding:GetBuildingsBy(User, "academy", 1) > 0 then
                    UIKit:newGameUI("GameUIAcademy", City, City:GetFirstBuildingByType("barracks"), "upgrade"):AddToCurrentScene(true)
                else
                    UIKit:showMessageDialog(_("提示"),string.format(_("%s还未解锁"),_("学院")))
                end
            elseif i == 4 then
                if #UtilsForBuilding:GetBuildingsBy(User, "toolShop", 1) > 0 then
                    UIKit:newGameUI("GameUIToolShop", City, City:GetFirstBuildingByType("toolShop"), "manufacture"):AddToCurrentScene(true)
                else
                    UIKit:showMessageDialog(_("提示"),string.format(_("%s还未解锁"),_("工具作坊")))
                end
            elseif i == 5 then
                local house = City:GetLowestLeveltHouse()
                local current_scene = display.getRunningScene()
                if house then
                    local uiName = house:GetType() == "dwelling" and "GameUIDwelling" or "GameUIResource"
                    local x,y = house:GetMidLogicPosition()
                    current_scene:GotoLogicPoint(x,y,40):next(function()
                        local building_sprite = current_scene:GetSceneLayer():FindBuildingSpriteByBuilding(house, City)
                        UIKit:newGameUI(uiName, City, building_sprite:GetEntity(), "upgrade"):AddToCurrentScene(true)
                    end)
                else
                    local ruins = City:GetRuinsNotBeenOccupied()[1]
                    local x,y = ruins:GetMidLogicPosition()
                    current_scene:GotoLogicPoint(x,y,40):next(function()
                        local building_sprite = current_scene:GetSceneLayer():FindBuildingSpriteByBuilding(ruins, City)
                        UIKit:newGameUI("GameUIBuild", City, building_sprite:GetEntity()):AddToCurrentScene(true)
                    end)
                end
            end
            self:LeftButtonClicked()
        end):align(display.CENTER_TOP, 424/2, 408 - (i - 1) * 82):addTo(growth_node)
    end
    growth_node:hide()
    self.growth_node = growth_node
end
-- 我要变强
function GameUIPower:CreateStrongthMenu()
    local rb_size = self.body:getContentSize()
    local strongth_node = display.newNode()
    strongth_node:setContentSize(cc.size(424,420))
    strongth_node:align(display.CENTER_BOTTOM,rb_size.width/2,20)
        :addTo(self.body)
    local btns = {
        {_("兵营"),_("招募与召唤士兵")},
        {_("龙巢"),_("升级龙的技能")},
        {_("铁匠铺"),_("打造龙的装备")},
        {_("军事科技"),_("提升兵种属性")},
        {_("塔楼"),_("提升城墙的攻击力")},
    }
    for i,v in ipairs(btns) do
        self:CreateBtn(v,function ()
            if i == 1 then
                if #UtilsForBuilding:GetBuildingsBy(User, "barracks", 1) > 0 then
                    UIKit:newGameUI("GameUIBarracks", City, City:GetFirstBuildingByType("barracks"), "recruit"):AddToCurrentScene(true)
                else
                    UIKit:showMessageDialog(_("提示"),string.format(_("%s还未解锁"),_("兵营")))
                end
            elseif i == 2 then
                UIKit:newGameUI("GameUIDragonEyrieMain", City, City:GetFirstBuildingByType("dragonEyrie"), "dragon"):AddToCurrentScene(true)
            elseif i == 3 then
                if #UtilsForBuilding:GetBuildingsBy(User, "blackSmith", 1) > 0 then
                    local tabs = {
                        "redDragon",
                        "blueDragon",
                        "greenDragon",
                    }
                    UIKit:newGameUI("GameUIBlackSmith", City, City:GetFirstBuildingByType("blackSmith"), tabs[math.random(3)]):AddToCurrentScene(true)
                else
                    UIKit:showMessageDialog(_("提示"),string.format(_("%s还未解锁"),_("铁匠铺")))
                end
            elseif i == 4 then
                if #UtilsForBuilding:GetBuildingsBy(User, "trainingGround", 1) > 0 or
                    #UtilsForBuilding:GetBuildingsBy(User, "stable", 1) > 0 or
                    #UtilsForBuilding:GetBuildingsBy(User, "hunterHall", 1) > 0 or
                    #UtilsForBuilding:GetBuildingsBy(User, "workshop", 1) > 0 then
                    app:EnterMyCityScene(false,"twinkle_military")
                else
                    UIKit:showMessageDialog(_("提示"),_("请先升级城堡，解锁军事科技建筑"))
                end
            elseif i == 5 then
                UIKit:newGameUI("GameUITower", City, City:GetTower(), "upgrade"):AddToCurrentScene(true)
            end
            self:LeftButtonClicked()
        end):align(display.CENTER_TOP, 424/2, 408 - (i - 1) * 82):addTo(strongth_node)
    end
    strongth_node:hide()
    self.strongth_node = strongth_node
end
-- 我要开战
function GameUIPower:CreateFightMenu()
    local rb_size = self.body:getContentSize()
    local fight_node = display.newNode()
    fight_node:setContentSize(cc.size(424,420))
    fight_node:align(display.CENTER_BOTTOM,rb_size.width/2,20)
        :addTo(self.body)
    local btns = {
        {_("飞艇探险"),_("收集材料召唤特殊兵种")},
        {_("村落"),_("占领村落采集资源")},
        {_("黑龙军团"),_("获得道具和材料")},
        {_("圣地战"),_("收集龙装备材料")},
        {_("联盟战"),_("开启联盟战获得奖励")},
    }
    for i,v in ipairs(btns) do
        self:CreateBtn(v,function ()
            if i == 1 then
                local dragon_manger = City:GetDragonEyrie():GetDragonManager()
                local dragon_type = dragon_manger:GetCanFightPowerfulDragonType()
                if #dragon_type > 0 or UtilsForDragon:GetDefenceDragon(User) then
                    app:EnterPVEScene(User:GetLatestPveIndex())
                else
                    UIKit:showMessageDialog(_("主人"),_("需要一条空闲状态的魔龙才能探险"))
                end
                app:GetAudioManager():PlayeEffectSoundWithKey("AIRSHIP")
            elseif i == 2 then
                local my_allaince = Alliance_Manager:GetMyAlliance()
                if my_allaince:IsDefault() then
                    UIKit:showMessageDialog(_("提示"),_("你必须加入联盟后，才能采集村落"))
                else
                    local village = Alliance_Manager:GetAllianceFreeVillageOrOnEventVillage(my_allaince)
                    if village then
                        my_allaince:IteratorVillages(function (k,v)
                            if v.id == village.id then
                                app:EnterMyAllianceScene({mapIndex = my_allaince.mapIndex,x = v.location.x,y = v.location.y,callback = function ( alliance_scene )
                                    local mapObj = alliance_scene:GetSceneLayer():FindMapObject(my_allaince.mapIndex,v.location.x, v.location.y)
                                    UIKit:newGameUI("GameUIAllianceVillageEnter",mapObj,my_allaince):AddToCurrentScene(true)
                                end})
                            end
                        end)
                    else
                        UIKit:showMessageDialog(_("提示"),_("联盟中当前没有空闲的村落,你可以尝试去其他联盟寻找"))
                    end
                end
            elseif i == 3 then
                local my_allaince = Alliance_Manager:GetMyAlliance()
                if my_allaince:IsDefault() then
                    UIKit:showMessageDialog(_("提示"),_("你必须加入联盟后，才能攻打黑龙军团"))
                else
                    local monster = my_allaince.monsters[1]
                    if monster then
                        my_allaince:IteratorMonsters(function (k,v)
                            if v.id == monster.id then
                                app:EnterMyAllianceScene({mapIndex = my_allaince.mapIndex,x = v.location.x,y = v.location.y,callback = function ( alliance_scene )
                                    local mapObj = alliance_scene:GetSceneLayer():FindMapObject(my_allaince.mapIndex,v.location.x, v.location.y)
                                    UIKit:newGameUI("GameUIAllianceMosterEnter",mapObj,my_allaince):AddToCurrentScene(true)
                                end})
                            end
                        end)
                    else
                        UIKit:showMessageDialog(_("提示"),_("联盟中当前没有黑龙军团,你可以尝试去其他联盟寻找"))
                    end
                end
            elseif i == 4 then
                if Alliance_Manager:GetMyAlliance():IsDefault() then
                    UIKit:showMessageDialog(_("提示"),_("你必须加入联盟后，才能参加圣地战"))
                else
                    UIKit:newGameUI("GameUIAllianceShrine",City,"stage",Alliance_Manager:GetMyAlliance():GetAllianceBuildingInfoByName("shrine")):AddToCurrentScene(true)
                end
            elseif i == 5 then
                local my_allaince = Alliance_Manager:GetMyAlliance()
                if my_allaince:IsDefault() then
                    UIKit:showMessageDialog(_("提示"),_("你必须加入联盟后，才能参加联盟战"))
                else
                    app:EnterMyAllianceScene({mapIndex = my_allaince.mapIndex,x = 8,y = 8,callback = function ( alliance_scene )
                    	local mapIndexData = Alliance_Manager.mapIndexData
                    	print(" my_allaince.mapIndex=", my_allaince.mapIndex)
                    	-- 找到一个离自己联盟最近的联盟开战
                    	local distance = math.huge
                    	local target_mapIndex
                    	if LuaUtils:table_size(mapIndexData) > 1 then
                    		for k,v in pairs(mapIndexData) do
                    			if tonumber(k) ~= my_allaince.mapIndex then
                    				if not target_mapIndex then
                    					target_mapIndex = tonumber(k)
                    				else
	                    				local new_distance = DataUtils:getAllianceLocationDistance(my_allaince, {x = 8,y = 8}, {mapIndex = tonumber(k)}, {x = 8,y = 8})
                    					if new_distance < distance then
                    						target_mapIndex = tonumber(k)
                    					end
                    				end
                    			end
                    		end
                			local UIWorldMap = UIKit:newGameUI("GameUIWorldMap", nil, nil, target_mapIndex):AddToCurrentScene()
                			local count = 0
                			self.handle = scheduler.scheduleGlobal(function ()
                				if LuaUtils:table_size(UIWorldMap:GetSceneLayer().allainceSprites) > 0 then
		        					UIKit:newWidgetUI("WidgetWorldAllianceInfo",UIWorldMap:GetSceneLayer():GetWorldObjectByIndex(target_mapIndex),target_mapIndex,true):AddToCurrentScene()
		        					scheduler.unscheduleGlobal(self.handle)
                				end
                				count = count + 1
                				if count > 3 then
		        					scheduler.unscheduleGlobal(self.handle)
                				end
                			end, 0.5, false)
                		else
                    		UIKit:showMessageDialog(_("提示"),_("没有其他联盟"))
                    	end
                    end})
                end
            end
            self:LeftButtonClicked()
        end):align(display.CENTER_TOP, 424/2, 408 - (i - 1) * 82):addTo(fight_node)
    end
    fight_node:hide()
    self.fight_node = fight_node
end
-- 我很无聊
function GameUIPower:CreateBoredMenu()
    local rb_size = self.body:getContentSize()
    local bored_node = display.newNode()
    bored_node:setContentSize(cc.size(424,420))
    bored_node:align(display.CENTER_BOTTOM,rb_size.width/2,20)
        :addTo(self.body)
    local btns = {
        {_("游乐场"),_("获得丰厚道具")},
        {_("世界聊天"),_("认识全世界的朋友")},
        {_("个人排行版"),_("查看顶尖玩家的实力")},
        {_("联盟排行版"),_("查看顶尖联盟的实力")},
        {_("日常任务"),_("完成任务获得奖励")},
    }
    for i,v in ipairs(btns) do
        self:CreateBtn(v,function ()
            if i == 1 then
                UIKit:newGameUI("GameUIGacha", City):AddToCurrentScene(true)
            elseif i == 2 then
                UIKit:newGameUI('GameUIChatChannel',"global"):AddToCurrentScene(true)
            elseif i == 3 then
                if City:GetFirstBuildingByType("keep"):GetLevel() >= 8 then
                    UIKit:newWidgetUI("WidgetRankingList", "player"):AddToCurrentScene(true)
                else
                    GameGlobalUI:showTips(_("提示"), _("城堡等级达到8级解锁"))
                end
            elseif i == 4 then
                if City:GetFirstBuildingByType("keep"):GetLevel() >= 8 then
                    UIKit:newWidgetUI("WidgetRankingList","alliance"):AddToCurrentScene(true)
                else
                    GameGlobalUI:showTips(_("提示"), _("城堡等级达到8级解锁"))
                end
            elseif i == 5 then
                UIKit:newGameUI("GameUIMission", City, GameUIMission.MISSION_TYPE.daily, false):AddToCurrentScene(true)
            end
            self:LeftButtonClicked()
        end):align(display.CENTER_TOP, 424/2, 408 - (i - 1) * 82):addTo(bored_node)
    end
    bored_node:hide()
    self.bored_node = bored_node
end
function GameUIPower:CreateBtn(btn_label,onClickFunc)
    local btn_bg = display.newScale9Sprite("background_event_42x42.png"):size(424,68)
    local btn = WidgetPushButton.new({normal = "blue_btn_up_108x38.png",pressed = "blue_btn_down_108x38.png"},{scale9 = true})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                onClickFunc()
            end
        end):pos(424/2, 68/2)
        :addTo(btn_bg)
    if type(btn_label) == 'table' then
        UIKit:ttfLabel({
            text = btn_label[1],
            size = 20,
            color = 0xffedae,
            shadow = true
        }):align(display.CENTER,424/2, 68/2 + 14)
            :addTo(btn_bg)
        UIKit:ttfLabel({
            text = btn_label[2],
            size = 20,
            color = 0xfed36c,
            shadow = true
        }):align(display.CENTER,424/2, 68/2 - 10)
            :addTo(btn_bg)
    else
        UIKit:ttfLabel({
            text = btn_label,
            size = 24,
            color = 0xffedae,
            shadow = true
        }):align(display.CENTER,424/2, 68/2)
            :addTo(btn_bg)
    end
    btn:setButtonSize(418, 62)
    return btn_bg
end
function GameUIPower:ShowOrHide(idx)
    self.title_label:hide()
    self.power_label:hide()
    local nodes = {
        self.growth_node,
        self.strongth_node,
        self.fight_node,
        self.bored_node,
    }
    for i,v in ipairs(nodes) do
        v:setVisible(i == idx)
        if i == idx then
            self.second_title_label:setString(main_menu[i])
            self.second_title_label:show()
        end
    end
end
function GameUIPower:OnUserDataChanged_basicInfo(userData, deltaData)
    if deltaData("basicInfo.power") then
        self.power_label:setString(string.formatnumberthousands(User.basicInfo.power))
    end
end
return GameUIPower


























--
-- Author: Kenny Dai
-- Date: 2016-05-18 15:36:52
--
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local GameUISeasonDetails = class("GameUISeasonDetails", WidgetPopDialog)
local window = import("..utils.window")
local Localize = import("..utils.Localize")
local Localize_item = import("..utils.Localize_item")
local UIListView = import(".UIListView")
local UILib = import(".UILib")
local ScheduleActivities = GameDatas.ScheduleActivities.type
local allianceType = GameDatas.ScheduleActivities.allianceType
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
function GameUISeasonDetails:ctor(activity_data)
    GameUISeasonDetails.super.ctor(self,766,Localize.activities[activity_data.activity.type],window.top_bottom)
    self.activity_data = activity_data
    dump(self.activity_data.activity)
end

function GameUISeasonDetails:onEnter()
    GameUISeasonDetails.super.onEnter(self)
    self:CreateList()
    ActivityManager:AddListenOnType(self,ActivityManager.LISTEN_TYPE.ACTIVITY_CHANGED)
end
function GameUISeasonDetails:onExit()
    GameUISeasonDetails.super.onExit(self)
    ActivityManager:RemoveListenerOnType(self,ActivityManager.LISTEN_TYPE.ACTIVITY_CHANGED)
end
function GameUISeasonDetails:CreateList()
    if self.listView then
        self.listView:removeFromParent()
        self.listView = nil
    end
    local body = self:GetBody()
    local list = UIListView.new({
        -- bgColor = UIKit:hex2c4b(0x7a10ff00),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(10,38,590,710),
    }):addTo(body)
    self.listView = list
    self:GetListNode()
    list:reload()
end
function GameUISeasonDetails:GetListNode()
    local list = self.listView
    local item = list:newItem()
    local content = display.newNode()
    local activity_data = self.activity_data
    local isAlliance = activity_data.isAlliance
    local activity_type = activity_data.activity.type
    local isValid
    if isAlliance then
        isValid = ActivityManager:IsAllianceExpiredActivityValid(activity_type)
    else
        isValid = ActivityManager:IsPlayerExpiredActivityValid(activity_type)
    end
    local myRank
    if isAlliance then
        myRank = ActivityManager:GetMyAllianceRank(activity_type)
    else
        myRank = ActivityManager:GetMyRank(activity_type)
    end
    local config = isAlliance and allianceType or ScheduleActivities
    -- 奖励列表
    -- 过期活动显示我的奖励
    local status = activity_data.status
    local reward_y = 0
    if status == "expired" then
        local reward = isAlliance and ActivityManager:GetMyAllianceActivityRankReward(activity_type) or ActivityManager:GetMyActivityRankReward(activity_type)
        if #reward > 0 then
            local reward_height = 18 + #reward * 64
            local reward_content = WidgetUIBackGround.new({width = 540,height = reward_height},WidgetUIBackGround.STYLE_TYPE.STYLE_6)
                :align(display.LEFT_BOTTOM, 12, 0):addTo(content)
            local got_tips = _("获得").." "
            for i,data in ipairs(reward) do
                local body_image = i%2 == 0 and "back_ground_548x40_1.png" or "back_ground_548x40_2.png"
                local body = display.newScale9Sprite(body_image,0,0,cc.size(520,64),cc.rect(10,10,528,20))
                    :align(display.CENTER_BOTTOM, 270, 10 + (i -1)*64)
                    :addTo(reward_content)

                local item_bg = display.newSprite("box_118x118.png"):align(display.CENTER, 30, 32):addTo(body):scale(54/118)
                local sp = display.newSprite(UIKit:GetItemImage("items",data.name),59,59):addTo(item_bg)
                local size = sp:getContentSize()
                sp:scale(90/math.max(size.width,size.height))
                UIKit:ttfLabel({
                    text = Localize_item.item_name[data.name],
                    size = 20,
                    color = 0x403c2f,
                }):align(display.LEFT_CENTER,100,32)
                    :addTo(body)
                UIKit:ttfLabel({
                    text = "X "..data.count,
                    size = 20,
                    color = 0x403c2f,
                }):align(display.RIGHT_CENTER,506,32)
                    :addTo(body)
                got_tips = got_tips .. Localize_item.item_name[data.name].." X "..data.count.." "
            end

            UIKit:ttfLabel({
                text = string.format(_("我的排名：%s"),myRank and ""..myRank or _("无")),
                size = 20,
                color = 0x403c2f,
            }):align(display.LEFT_CENTER,12,reward_content:getContentSize().height + 60)
                :addTo(content)
            local btn = WidgetPushButton.new(
                {normal = "yellow_btn_up_148x58.png", pressed = "yellow_btn_down_148x58.png",disabled = "grey_btn_148x58.png"}
            ):setButtonLabel(UIKit:ttfLabel({
                text = _("全部领取"),
                size = 20,
                color = 0xfff3c7,
                shadow = true
            })):addTo(content):align(display.LEFT_BOTTOM, 416, reward_content:getContentSize().height + 16)
                :onButtonClicked(function(event)
                    if event.name == "CLICKED_EVENT" then
                        if isAlliance then
                            NetManager:getAllianceActivityRankRewardsPromise(activity_type):done(function ()
                                app:GetAudioManager():PlayeEffectSoundWithKey("BUY_ITEM")
                                GameGlobalUI:showTips(_("提示"),got_tips)
                                self:LeftButtonClicked()
                            end)
                        else
                            NetManager:getPlayerActivityRankRewardsPromise(activity_type):done(function ()
                                app:GetAudioManager():PlayeEffectSoundWithKey("BUY_ITEM")
                                GameGlobalUI:showTips(_("提示"),got_tips)
                                self:LeftButtonClicked()
                            end)
                        end
                    end
                end)
            local ep_time = app.timer:GetServerTime() - (activity_data.activity.removeTime/1000 - config[activity_type].expireHours * 60 * 60) -- 过期后十分钟可以领取排行榜奖励
            local could_got = ep_time > ActivityManager.EXPIRED_GET_LIMIT
            local my_reward_label = UIKit:ttfLabel({
                text = _("我的奖励"),
                size = 20,
                color = 0x403c2f,
            }):align(display.LEFT_CENTER,12,reward_content:getContentSize().height + 24)
                :addTo(content)
            if not could_got  then
                btn:setButtonEnabled(false)
                scheduleAt(self, function()
                    local ep_time = app.timer:GetServerTime() - (activity_data.activity.removeTime/1000 - config[activity_type].expireHours * 60 * 60) -- 过期后十分钟可以领取排行榜奖励
                    if ep_time <= ActivityManager.EXPIRED_GET_LIMIT then
                        my_reward_label:setString(string.format(_("奖励在%s后可领取"),GameUtils:formatTimeStyle1(ActivityManager.EXPIRED_GET_LIMIT - ep_time)))
                        my_reward_label:setColor(UIKit:hex2c4b(0x7e0000))
                    else
                        btn:setButtonEnabled(true)
                        my_reward_label:setString(_("我的奖励"))
                        my_reward_label:setColor(UIKit:hex2c4b(0x403c2f))
                    end
                end)
            end
            reward_y = reward_content:getContentSize().height + 88
        end
    else
        local reward = isAlliance and ActivityManager:GetAllianceActivityRankReward(activity_type) or ActivityManager:GetActivityRankReward(activity_type)
        local region = ActivityManager:GetActivityRankRewardRegion()
        local reward_data = {}
        local reward_height = 18
        for i = #reward,1 ,-1 do
            table.insert(reward_data, {
                level = region[i][1] ~= region[i][2] and region[i][1].."-"..region[i][2] or region[i][1],
                items = reward[i]
            })
            reward_height = reward_height + #reward[i] * 54 + (#reward[i] + 1) * 5
        end
        local reward_content = WidgetUIBackGround.new({width = 540,height = reward_height},WidgetUIBackGround.STYLE_TYPE.STYLE_6)
            :align(display.LEFT_BOTTOM, 12, 0):addTo(content)
        reward_y = reward_content:getContentSize().height + 16
        local pre_body -- 上一条添加的节点
        for i,data in ipairs(reward_data) do
            local body_image = i%2 == 0 and "back_ground_548x40_1.png" or "back_ground_548x40_2.png"
            pre_height = #data.items * 54 + (#data.items + 1) * 5
            local body = display.newScale9Sprite(body_image,0,0,cc.size(520,pre_height),cc.rect(10,10,528,20))
                :align(display.CENTER_BOTTOM, 270, pre_body and pre_body:getPositionY() + pre_body:getContentSize().height or 10)
                :addTo(reward_content)
            pre_body = body
            UIKit:ttfLabel({
                text = data.level,
                size = 22,
                color = 0x403c2f,
            }):align(display.CENTER,40,body:getContentSize().height/2)
                :addTo(body)
            for i,item in ipairs(data.items) do
                local y = 32 + (i - 1) * 59
                local item_bg = display.newSprite("box_118x118.png"):align(display.CENTER, 130, y):addTo(body):scale(54/118)
                local sp = display.newSprite(UIKit:GetItemImage("items",item.name),59,59):addTo(item_bg)
                local size = sp:getContentSize()
                sp:scale(90/math.max(size.width,size.height))
                UIKit:ttfLabel({
                    text = Localize_item.item_name[item.name],
                    size = 20,
                    color = 0x403c2f,
                }):align(display.LEFT_CENTER,170,y)
                    :addTo(body)
                UIKit:ttfLabel({
                    text = "X "..item.count,
                    size = 20,
                    color = 0x403c2f,
                }):align(display.RIGHT_CENTER,506,y)
                    :addTo(body)
            end
        end
    end
    -- 查看排名
    local rank_btn
    if status ~= "next" then
        rank_btn = WidgetPushButton.new({normal = 'title_red_564x54_1.png'})
            :addTo(content)
            :align(display.LEFT_BOTTOM, 0, reward_y)
            :onButtonClicked(function()
                UIKit:newGameUI("GameUISeasonRank",self.activity_data):AddToCurrentScene()
            end)
        local btn_label = UIKit:commonButtonLable({
            text = _("查看排名")
        }):align(display.CENTER, rank_btn:getCascadeBoundingBox().size.width/2, rank_btn:getCascadeBoundingBox().size.height/2 + 6)
            :addTo(rank_btn)
        display.newSprite("info_16x33.png")
            :align(display.RIGHT_CENTER,btn_label:getPositionX() + btn_label:getContentSize().width/2 + 20, btn_label:getPositionY())
            :addTo(rank_btn)
            :scale(0.8)
    end
    -- 活动项目
    local ac_pro = ActivityManager:GetActivityScoreCondition(activity_type)
    local season_pro_bg = display.newScale9Sprite("back_ground_548x40_1.png",0,0,cc.size(550,30 + #ac_pro*38),cc.rect(10,10,528,20))
        :align(display.LEFT_BOTTOM, 6, (rank_btn and rank_btn:getPositionY() + rank_btn:getCascadeBoundingBox().size.height + 16) or reward_y)
        :addTo(content)
    local t_bg = display.newScale9Sprite("back_ground_blue_254x42.png", 0, 0,cc.size(546,30),cc.rect(10,10,234,22))
        :align(display.CENTER_TOP,season_pro_bg:getContentSize().width/2, season_pro_bg:getContentSize().height)
        :addTo(season_pro_bg)
    UIKit:ttfLabel({
        text = _("积分规则"),
        size = 20,
        color = 0xffedae,
    }):align(display.LEFT_CENTER,10,15)
        :addTo(t_bg)
    UIKit:ttfLabel({
        text = _("分数"),
        size = 20,
        color = 0xffedae,
    }):align(display.RIGHT_CENTER,536,15)
        :addTo(t_bg)
    for i,v in ipairs(ac_pro) do
        local pro_bg = display.newScale9Sprite(string.format("back_ground_548x40_%d.png",i%2==0 and 1 or 2),0,0,cc.size(546,38),cc.rect(10,10,528,20))
            :align(display.CENTER_TOP,season_pro_bg:getContentSize().width/2, season_pro_bg:getContentSize().height - 30 - (i-1) * 38)
            :addTo(season_pro_bg)
        UIKit:ttfLabel({
            text = v[1],
            size = 20,
            color = 0x403c2f,
        }):align(display.LEFT_CENTER,10,19)
            :addTo(pro_bg)
        UIKit:ttfLabel({
            text = v[2],
            size = 20,
            color = 0x403c2f,
        }):align(display.RIGHT_CENTER,536,19)
            :addTo(pro_bg)
    end

    -- 领取奖励部分
    local citizen_num_bg = display.newSprite("citizen_num_bg_170x714.png")
        :align(display.LEFT_BOTTOM, 6, season_pro_bg:getPositionY() + season_pro_bg:getContentSize().height + 16)
        :addTo(content)
        :scale(121/170)
    local reward_points = isAlliance and ActivityManager:GetAllianceActivityScorePonits(activity_type) or ActivityManager:GetActivityScorePonits(activity_type)
    local gotIndex
    if isValid then
        if isAlliance then
            gotIndex = ActivityManager:GetAllianceActivityScoreIndex(activity_type)
        else
            gotIndex = ActivityManager:GetActivityScoreIndex(activity_type)
        end
    else
        gotIndex = 0
    end
    local my_score
    if isValid then
        if isAlliance then
            my_score = Alliance_Manager:GetMyAlliance().activities[activity_type].score
        else
            my_score = User.activities[activity_type].score
        end
    else
        my_score = 0
    end
    local progress_percent = 0
    for i,v in ipairs(reward_points) do
        if v <= my_score then
            progress_percent = progress_percent + 0.2
        else
            local pre_value = reward_points[i - 1] and reward_points[i - 1] or 0
            local gap = v - pre_value
            local pass = my_score - pre_value
            progress_percent = progress_percent + 0.2 * pass / gap
            break
        end
    end
    if progress_percent>0 then
        display.newScale9Sprite("line_92x1.png"):align(display.LEFT_TOP, 20, season_pro_bg:getPositionY() + season_pro_bg:getContentSize().height + 26 + 478)
            :addTo(content)
            :size(92,478 * progress_percent)
    end
    self.pointbtn = {}
    self.got_labels = {}
    for i,v in ipairs(reward_points) do
        local y = citizen_num_bg:getPositionY() + (#reward_points - i) * 478/5

        local point_bg = display.newSprite(my_score >= v and "title_yellow_80x30.png" or "title_blue_80x30.png")
            :align(display.LEFT_BOTTOM, 128, y)
            :addTo(content)
        UIKit:ttfLabel({
            text = GameUtils:formatNumber(v),
            size = 22,
            color = 0xffedae,
            shadow = true
        }):align(display.CENTER,point_bg:getContentSize().width/2,point_bg:getContentSize().height/2 + 2)
            :addTo(point_bg)
        local item_rewards = isAlliance and ActivityManager:GetAllianceActivityScoreByIndex(activity_type,i) or ActivityManager:GetActivityScoreByIndex(activity_type,i)
        local item_bg = display.newSprite("box_118x118.png"):align(display.LEFT_BOTTOM, 228, y):addTo(content):scale(74/118)
        local sp = display.newSprite(UIKit:GetItemImage("items",item_rewards[1].name),59,59):addTo(item_bg)
        local size = sp:getContentSize()
        sp:scale(90/math.max(size.width,size.height))
        UIKit:addTipsToNode(item_bg,Localize_item.item_name[item_rewards[1].name].." X "..item_rewards[1].count,self:getParent(),nil,50,10)
        local item_bg = display.newSprite("box_118x118.png"):align(display.LEFT_BOTTOM, 322, y):addTo(content):scale(74/118)
        local sp = display.newSprite(UIKit:GetItemImage("items",item_rewards[2].name),59,59):addTo(item_bg)
        local size = sp:getContentSize()
        sp:scale(90/math.max(size.width,size.height))
        UIKit:addTipsToNode(item_bg,Localize_item.item_name[item_rewards[2].name].." X "..item_rewards[2].count,self:getParent(),nil,50,10)
        self.pointbtn[i] = WidgetPushButton.new(
            {normal = "yellow_btn_up_148x58.png", pressed = "yellow_btn_down_148x58.png",disabled = "grey_btn_148x58.png"}
        ):setButtonLabel(UIKit:ttfLabel({
            text = _("领取"),
            size = 20,
            color = 0xfff3c7,
            shadow = true
        })):addTo(content):align(display.LEFT_BOTTOM, 416, y)
            :onButtonClicked(function(event)
                if event.name == "CLICKED_EVENT" then
                    local scoreRewardedIndex = isAlliance and ActivityManager:GetAllianceActivityScoreGotIndex(activity_type) or ActivityManager:GetActivityScoreGotIndex(activity_type)
                    if scoreRewardedIndex ~= i then
                        UIKit:showMessageDialog(_("提示"),_("请首先领取前面的奖励"))
                        return
                    end
                    if isAlliance then
                        NetManager:getAllianceActivityScoreRewardsPromise(activity_type):done(function ()
                            self:RefreshAfterGotPointReward()
                            app:GetAudioManager():PlayeEffectSoundWithKey("BUY_ITEM")
                            GameGlobalUI:showTips(_("提示"),
                                _("获得").." "..Localize_item.item_name[item_rewards[1].name].." X "..item_rewards[1].count.." , "..Localize_item.item_name[item_rewards[2].name].." X "..item_rewards[2].count)
                        end)
                    else
                        NetManager:getPlayerActivityScoreRewardsPromise(activity_type):done(function ()
                            self:RefreshAfterGotPointReward()
                            app:GetAudioManager():PlayeEffectSoundWithKey("BUY_ITEM")
                            GameGlobalUI:showTips(_("提示"),
                                _("获得").." "..Localize_item.item_name[item_rewards[1].name].." X "..item_rewards[1].count.." , "..Localize_item.item_name[item_rewards[2].name].." X "..item_rewards[2].count)
                        end)
                    end
                end
            end)
        self.pointbtn[i]:setButtonEnabled(gotIndex < i and my_score >= v)
        self.pointbtn[i]:setVisible(status == "expired" and gotIndex < i and my_score >= v or status ~= "expired" and gotIndex < i)
        self.got_labels[i] = UIKit:ttfLabel({
            text =  status == "expired" and gotIndex < i and _("过期") or _("已领取"),
            size = 22,
            color = 0x403c2f,
        }):addTo(content):align(display.CENTER_BOTTOM, 490, y + 20)
        self.got_labels[i]:setVisible(status == "expired" and gotIndex < i and my_score < v or gotIndex >= i)
    end
    local my_porint_bg = display.newSprite("title_red_564x54_1.png")
        :align(display.LEFT_BOTTOM, 0,citizen_num_bg:getPositionY() + 511 + 20)
        :addTo(content)
    UIKit:ttfLabel({
        text = string.format(_("我的分数：%s"),status ~= "next" and isValid and string.formatnumberthousands(my_score) or "0"),
        size = 22,
        color = 0xffcb4e,
        shadow = true
    }):align(display.CENTER,my_porint_bg:getContentSize().width/2,my_porint_bg:getContentSize().height/2 + 6)
        :addTo(my_porint_bg)
    local season_icon = display.newSprite(UILib.actvities[activity_type])
        :align(display.LEFT_BOTTOM, 0,my_porint_bg:getPositionY() + my_porint_bg:getContentSize().height + 20)
        :addTo(content)
    local season_desc_label = UIKit:ttfLabel({
        text = Localize.activities_desc[activity_type],
        size = 20,
        color = 0x403c2f,
        dimensions = cc.size(400,0)
    }):align(display.LEFT_TOP,season_icon:getPositionX() + season_icon:getContentSize().width + 10,season_icon:getPositionY() + 100)
        :addTo(content)
    local finish_time_label = UIKit:ttfLabel({
        text = "",
        size = 18,
        color = 0x7e0000
    }):addTo(content):align(display.LEFT_TOP,season_desc_label:getPositionX(),season_desc_label:getPositionY() - 55)
    if activity_data.status == "on" then
        scheduleAt(self, function()
            finish_time_label:setString(string.format(_("结束时间：%s"),GameUtils:formatTimeStyle1(activity_data.activity.finishTime/1000 - app.timer:GetServerTime())))
        end)
    elseif activity_data.status == "next" then
        scheduleAt(self, function()
            finish_time_label:setString(string.format(_("距离开始还有：%s"),GameUtils:formatTimeStyle1(activity_data.activity.startTime/1000 - app.timer:GetServerTime())))
        end)
    elseif activity_data.status == "expired" then
        scheduleAt(self, function()
            finish_time_label:setString(string.format(_("%s后消失"),GameUtils:formatTimeStyle1(activity_data.activity.removeTime/1000 - app.timer:GetServerTime())))
        end)
    end

    local item_width,item_height = content:getCascadeBoundingBox().width,content:getCascadeBoundingBox().height
    item:addContent(content)
    content:setContentSize(cc.size(item_width,item_height))
    item:setItemSize(item_width,item_height)
    list:addItem(item)
end
function GameUISeasonDetails:RefreshAfterGotPointReward()
    local activity_type = self.activity_data.activity.type
    local isAlliance = self.activity_data.isAlliance
    local activity = isAlliance and Alliance_Manager:GetMyAlliance().activities or User.activities
    local my_score = activity[activity_type].score
    local gotIndex = isAlliance and ActivityManager:GetAllianceActivityScoreIndex(activity_type) or ActivityManager:GetActivityScoreIndex(activity_type)
    local reward_points = isAlliance and ActivityManager:GetAllianceActivityScorePonits(activity_type) or ActivityManager:GetActivityScorePonits(activity_type)
    for i,v in ipairs(reward_points) do
        self.pointbtn[i]:setButtonEnabled(gotIndex < i and my_score >= v)
        self.pointbtn[i]:setVisible(self.activity_data.status == "expired" and gotIndex < i and my_score >= v or self.activity_data.status ~= "expired" and gotIndex < i)
        self.got_labels[i]:setVisible(self.activity_data.status == "expired" and gotIndex < i and my_score < v or gotIndex >= i)
        self.got_labels[i]:setString(self.activity_data.status == "expired" and gotIndex < i and _("过期") or _("已领取"))
    end
end
function GameUISeasonDetails:OnActivitiesChanged()
    self:LeftButtonClicked()
end
return GameUISeasonDetails











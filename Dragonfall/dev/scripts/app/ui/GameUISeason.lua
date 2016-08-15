--
-- Author: Kenny Dai
-- Date: 2016-08-12 11:01:28
--
local GameUISeason = UIKit:createUIClass("GameUISeason","GameUIWithCommonHeader")
local GameUtils = GameUtils
local UILib = import(".UILib")
local Enum = import("..utils.Enum")
local window = import("..utils.window")
local Localize = import("..utils.Localize")
local RichText = import("..widget.RichText")
local UIListView = import(".UIListView")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local ScheduleActivities = GameDatas.ScheduleActivities.type
local User = User
local GameUIActivityRewardNew = import(".GameUIActivityRewardNew")
local WidgetPushButton = import("..widget.WidgetPushButton")
local Localize_item = import("..utils.Localize_item")
--赛季列表条类型
GameUISeason.SEASON_ITEMS_TYPE = Enum("HAVE_IN_HAND","OVERDUE","COMING")

function GameUISeason:ctor(city)
    GameUISeason.super.ctor(self,city, _("赛季"))
    ActivityManager:GetActivitiesFromServer()
    ActivityManager:GetAllianceActivitiesFromServer()

    scheduleAt(self, function()
        if self.season_list_view then
            for i,item in ipairs(self.season_list_view:getItems()) do
                local content = item:getContent()
                if content.finish_time_label then
                    content.finish_time_label:setString(string.format(_("结束时间：%s"),GameUtils:formatTimeStyle1(content.activity.finishTime/1000 - app.timer:GetServerTime())))
                elseif content.coming_time_label then
                    content.coming_time_label:setString(string.format(_("距离开始还有：%s"),GameUtils:formatTimeStyle1(content.activity.startTime/1000 - app.timer:GetServerTime())))
                elseif content.over_time_label then
                    content.over_time_label:setString(string.format(_("%s后消失"),GameUtils:formatTimeStyle1(content.activity.removeTime/1000 - app.timer:GetServerTime())))
                end
            end
        end
    end)
end

function GameUISeason:onCleanup()
    User:RemoveListenerOnType(self, "activities")
    User:RemoveListenerOnType(self, "allianceActivities")
    Alliance_Manager:GetMyAlliance():RemoveListenerOnType(self, "activities")
    ActivityManager:RemoveListenerOnType(self,ActivityManager.LISTEN_TYPE.ACTIVITY_CHANGED)
    ActivityManager:RemoveListenerOnType(self,ActivityManager.LISTEN_TYPE.ON_RANK_CHANGED)
    ActivityManager:RemoveListenerOnType(self,ActivityManager.LISTEN_TYPE.ON_LIMIT_CHANGED)
    GameUISeason.super.onCleanup(self)
end

function GameUISeason:OnMoveInStage()
    GameUISeason.super.OnMoveInStage(self)
    self:CreateTabIf_season()
end

function GameUISeason:CreateTabIf_season()
    if not self.season_list_view then
        local list = UIListView.new({
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            viewRect = cc.rect(window.left+(window.width - 612)/2,window.bottom_top + 20,612,785),
        }):addTo(self:GetView())
        list:onTouch(handler(self, self.OnSeasonListViewTouch))
        self.season_list_view = list
        User:AddListenOnType(self, "activities")
        User:AddListenOnType(self, "allianceActivities")
        Alliance_Manager:GetMyAlliance():AddListenOnType(self, "activities")
        ActivityManager:AddListenOnType(self,ActivityManager.LISTEN_TYPE.ACTIVITY_CHANGED)
        ActivityManager:AddListenOnType(self,ActivityManager.LISTEN_TYPE.ON_RANK_CHANGED)
        ActivityManager:AddListenOnType(self,ActivityManager.LISTEN_TYPE.ON_LIMIT_CHANGED)
    end
    self:RefreshSeasonList()
    return self.season_list_view
end
function GameUISeason:OnSeasonListViewTouch(event)
    if event.name == "clicked" and event.item and event.item:getContent().activity then
        local content = event.item:getContent()
        local data = {}
        data.activity = content.activity
        data.status = content.status
        data.isAlliance = content.isAlliance
        if content.isAlliance and Alliance_Manager:GetMyAlliance():IsDefault() then
            UIKit:showMessageDialog(_("提示"),_("请加入联盟"))
            return
        end
        app:GetAudioManager():PlayeEffectSoundWithKey("NORMAL_DOWN")
        UIKit:newGameUI("GameUISeasonDetails",data):AddToCurrentScene()
    end
end
function GameUISeason:RefreshSeasonList()
    local list = self.season_list_view
    list:removeAllItems()
    local activities = ActivityManager:GetLocalActivities()
    local alliance_activities = ActivityManager:GetLocalAllianceActivities()

    -- 进行中的赛季
    if #activities.on > 0 or #alliance_activities.on > 0 then
        self:GetSeasonTitleItem(_("进行中"))
        ActivityManager:IteratorActivityOn(function (i,activity)
            self:GetSeasonItem(self.SEASON_ITEMS_TYPE.HAVE_IN_HAND,activity,false)
        end)
        ActivityManager:IteratorAllianceActivityOn(function (i,activity)
            self:GetSeasonItem(self.SEASON_ITEMS_TYPE.HAVE_IN_HAND,activity,true)
        end)
    end
    -- 过期的赛季
    if #activities.expired > 0 or #alliance_activities.expired > 0 then
        self:GetSeasonTitleItem(_("已过期"))
        ActivityManager:IteratorActivityExpired(function (i,activity)
            self:GetSeasonItem(self.SEASON_ITEMS_TYPE.OVERDUE,activity,false)
        end)
        ActivityManager:IteratorAllianceActivityExpired(function (i,activity)
            self:GetSeasonItem(self.SEASON_ITEMS_TYPE.OVERDUE,activity,true)
        end)
    end
    -- 即将来临的赛季
    if #activities.next > 0 or #alliance_activities.next > 0 then
        self:GetSeasonTitleItem(_("即将来临"))
        ActivityManager:IteratorActivityNext(function (i,activity)
            self:GetSeasonItem(self.SEASON_ITEMS_TYPE.COMING,activity,false)
        end)
        ActivityManager:IteratorAllianceActivityNext(function (i,activity)
            self:GetSeasonItem(self.SEASON_ITEMS_TYPE.COMING,activity,true)
        end)
    end
    list:reload()
end
function GameUISeason:GetSeasonTitleItem(title)
    local list = self.season_list_view
    local item = list:newItem()
    local item_width,item_height = 568, 40
    item:setItemSize(item_width,item_height)
    local content = display.newNode()
    content:setContentSize(cc.size(item_width,item_height))
    display.newSprite("line_116x16.png"):align(display.RIGHT_CENTER, item_width, item_height/2):addTo(content)
    display.newSprite("line_116x16.png"):align(display.LEFT_CENTER, 0, item_height/2):addTo(content):flipX(true)
    UIKit:ttfLabel({
        text = title,
        size = 20,
        color = 0x403c2f
    }):addTo(content):align(display.CENTER,284,item_height/2)
    item:addContent(content)
    list:addItem(item)
end
function GameUISeason:GetSeasonItem(season_type,activity,isAlliance)
    local list = self.season_list_view
    local item = list:newItem()
    local content
    local item_width,item_height
    if season_type == self.SEASON_ITEMS_TYPE.HAVE_IN_HAND then
        item_width,item_height = 568, 138
        item:setItemSize(item_width,item_height)
        content = WidgetUIBackGround.new({width = item_width,height = item_height},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
        content.activity = activity
        content.isAlliance = isAlliance
        content.status = "on"
        local title_bg = display.newSprite("title_blue_522x54.png"):align(display.LEFT_CENTER, - 2, item_height - 40):addTo(content)
        local title_label = UIKit:ttfLabel({
            text = ActivityManager:GetActivityLocalize(activity.type).." ["..(isAlliance and _("联盟") or _("个人")).."]",
            size = 20,
            color = 0xffcb4e,
            shadow = true
        }):addTo(title_bg):align(display.LEFT_CENTER,146,title_bg:getContentSize().height/2 + 4)

        content.finish_time_label = UIKit:ttfLabel({
            text = string.format(_("结束时间：%s"),GameUtils:formatTimeStyle1(activity.finishTime/1000 - app.timer:GetServerTime())),
            size = 18,
            color = 0x7e0000
        }):addTo(content):align(display.LEFT_CENTER,144,item_height/2 - 10)
        local season_desc_label = UIKit:ttfLabel({
            text = isAlliance and _("联盟赛事") or _("个人赛事"),
            size = 18,
            color = 0x403c2f
        }):addTo(content):align(display.LEFT_CENTER,144,item_height/2 - 40)

        local season_icon = display.newSprite(UILib.actvities[activity.type]):align(display.LEFT_CENTER, 10, item_height/2):addTo(content)
        local hot_icon = display.newSprite("icon_hot_64x76.png"):align(display.RIGHT_TOP, item_width, item_height + 2):addTo(content)
        local hasReward = false
        if isAlliance then
            hasReward = ActivityManager:GetAllianceActivityScoreGotIndex(activity.type) > 0
        else
            hasReward = ActivityManager:GetActivityScoreGotIndex(activity.type) > 0
        end
        if hasReward then
            UIKit:ttfLabel({
                text = _("有奖励可领取"),
                size = 18,
                color = 0x007c23
            }):addTo(content):align(display.RIGHT_CENTER,item_width - 60,item_height/2 - 10)
        end
    elseif season_type == self.SEASON_ITEMS_TYPE.OVERDUE then
        item_width,item_height = 568, 128
        item:setItemSize(item_width, item_height)
        content = WidgetUIBackGround.new({width = item_width,height = item_height},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
        content.activity = activity
        content.isAlliance = isAlliance
        content.status = "expired"
        local title_bg = display.newSprite("title_red_522x54.png"):align(display.LEFT_CENTER, -2, item_height - 40):addTo(content)
        
        local title_label = UIKit:ttfLabel({
            text = ActivityManager:GetActivityLocalize(activity.type).." ["..(isAlliance and _("联盟") or _("个人")).."]",
            size = 20,
            color = 0xffcb4e,
            shadow = true
        }):addTo(title_bg):align(display.LEFT_CENTER,30,title_bg:getContentSize().height/2 + 4)
        content.over_time_label = UIKit:ttfLabel({
            text = string.format(_("%s后消失"),GameUtils:formatTimeStyle1(activity.removeTime/1000 - app.timer:GetServerTime())),
            size = 18,
            color = 0x7e0000
        }):addTo(content):align(display.LEFT_CENTER,28,item_height/2 - 24)
        local hasReward = false
        if isAlliance then
            hasReward = ActivityManager:HaveAllianceRewardByType(activity.type)
        else 
            hasReward = ActivityManager:HaveRewardByType(activity.type)
        end
        if hasReward then
            UIKit:ttfLabel({
                text = _("有奖励可领取"),
                size = 20,
                color = 0x007c23
            }):addTo(content):align(display.RIGHT_CENTER,item_width - 60,item_height/2 - 24)
        else
            UIKit:ttfLabel({
                text = _("无奖励可领取"),
                size = 20,
                color = 0x615b44
            }):addTo(content):align(display.RIGHT_CENTER,item_width - 60,item_height/2 - 24)
        end
    elseif season_type == self.SEASON_ITEMS_TYPE.COMING then
        item_width,item_height = 568, 128
        item:setItemSize(item_width, item_height)
        content = WidgetUIBackGround.new({width = item_width,height = item_height},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
        content.activity = activity
        content.isAlliance = isAlliance
        content.status = "next"
        local title_bg = display.newSprite("title_blue_522x54.png"):align(display.LEFT_CENTER, -2, item_height - 40):addTo(content)
        local title_label = UIKit:ttfLabel({
            text = ActivityManager:GetActivityLocalize(activity.type).." ["..(isAlliance and _("联盟") or _("个人")).."]",
            size = 20,
            color = 0xffcb4e,
            shadow = true
        }):addTo(title_bg):align(display.LEFT_CENTER,30,title_bg:getContentSize().height/2 + 4)
        content.coming_time_label = UIKit:ttfLabel({
            text = string.format(_("距离开始还有：%s"),GameUtils:formatTimeStyle1(activity.startTime/1000 - app.timer:GetServerTime())),
            size = 18,
            color = 0x007c23
        }):addTo(content):align(display.LEFT_CENTER,28,item_height/2 - 12)
        local season_desc_label = UIKit:ttfLabel({
            text = isAlliance and _("联盟赛事") or _("个人赛事"),
            size = 18,
            color = 0x403c2f
        }):addTo(content):align(display.LEFT_CENTER,28,item_height/2 - 40)
    end
    display.newSprite("next_32x38.png"):align(display.RIGHT_CENTER, 560, item_height/2 - 10):addTo(content)
    item:addContent(content)
    list:addItem(item)
end

local WidgetFteArrow = import("..widget.WidgetFteArrow")

function GameUISeason:OnUserDataChanged_activities()
    self:RefreshSeasonList()
    self:RefreshSeasonCountTips()
end
function GameUISeason:OnUserDataChanged_allianceActivities()
    self:RefreshSeasonList()
    self:RefreshSeasonCountTips()
end
function GameUISeason:OnAllianceDataChanged_activities()
    self:RefreshSeasonList()
    self:RefreshSeasonCountTips()
end
function GameUISeason:OnActivitiesChanged()
    self:RefreshSeasonList()
    self:RefreshSeasonCountTips()
end
function GameUISeason:OnActivitiesExpiredLimitChanged()
    self:RefreshSeasonList()
    self:RefreshSeasonCountTips()
end
function GameUISeason:OnRankChanged()
    self:RefreshSeasonList()
    self:RefreshSeasonCountTips()
end

return GameUISeason
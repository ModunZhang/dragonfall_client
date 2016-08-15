--
-- Author: Kenny Dai
-- Date: 2016-08-12 10:56:45
--
local WidgetNumberTips = import(".WidgetNumberTips")
local WidgetAutoSeasonButton = class("WidgetAutoSeasonButton",cc.ui.UIPushButton)

function WidgetAutoSeasonButton:ctor()
    WidgetAutoSeasonButton.super.ctor(self,{normal = "season_icon_79x90.png"})
    self:setNodeEventEnabled(true)
    self:onButtonClicked(handler(self, self.OnSeasonButtonClicked))
end

function WidgetAutoSeasonButton:OnSeasonButtonClicked()
    UIKit:newGameUI("GameUISeason",City):AddToCurrentScene(true)
end


function WidgetAutoSeasonButton:SetTimeInfo(time)
    if self.time_bg then
        if math.floor(time) > 0 then
            self.time_label:SetNumString(GameUtils:formatTimeStyle1(time))
            self.time_bg:show()
        else
            self.time_bg:hide()
        end
    else
        local label = UIKit:CreateNumberImageNode({
            text = GameUtils:formatTimeStyle1(time),
            size = 16,
            color = 0xffedae,
        })
        local time_bg = display.newSprite("red_title_98x30.png"):addTo(self):align(display.CENTER,0,-55)
        label:addTo(time_bg):align(display.CENTER,48,18)
        self.time_bg = time_bg
        self.time_label = label
        self.time_bg:setVisible(time > 0)
    end
end

function WidgetAutoSeasonButton:onEnter()
    User:AddListenOnType(self, "activities")
    User:AddListenOnType(self, "allianceActivities")
    Alliance_Manager:GetMyAlliance():AddListenOnType(self, "activities")
    ActivityManager:AddListenOnType(self,ActivityManager.LISTEN_TYPE.ACTIVITY_CHANGED)
    ActivityManager:AddListenOnType(self,ActivityManager.LISTEN_TYPE.ON_RANK_CHANGED)
    ActivityManager:AddListenOnType(self,ActivityManager.LISTEN_TYPE.ON_LIMIT_CHANGED)
    self.tips_button_count = WidgetNumberTips.new():addTo(self):pos(24,-24)
    self.tips_button_count:SetNumber(ActivityManager:GetHaveRewardActivitiesCount())
    self.min_time = ActivityManager:GetOnActivityMinTime()
    scheduleAt(self, function()
    	if self.min_time then
    		self:SetTimeInfo(self.min_time - app.timer:GetServerTime())
    	end
    end)
end
function WidgetAutoSeasonButton:onExit()
    User:RemoveListenerOnType(self, "activities")
    User:RemoveListenerOnType(self, "allianceActivities")
    Alliance_Manager:GetMyAlliance():RemoveListenerOnType(self, "activities")
    ActivityManager:RemoveListenerOnType(self,ActivityManager.LISTEN_TYPE.ACTIVITY_CHANGED)
    ActivityManager:RemoveListenerOnType(self,ActivityManager.LISTEN_TYPE.ON_RANK_CHANGED)
    ActivityManager:RemoveListenerOnType(self,ActivityManager.LISTEN_TYPE.ON_LIMIT_CHANGED)
end

function WidgetAutoSeasonButton:OnUserDataChanged_activities()
    self.min_time = ActivityManager:GetOnActivityMinTime()
    self.tips_button_count:SetNumber(ActivityManager:GetHaveRewardActivitiesCount())
end
function WidgetAutoSeasonButton:OnUserDataChanged_allianceActivities()
    self.min_time = ActivityManager:GetOnActivityMinTime()
    self.tips_button_count:SetNumber(ActivityManager:GetHaveRewardActivitiesCount())
end
function WidgetAutoSeasonButton:OnAllianceDataChanged_activities()
    self.min_time = ActivityManager:GetOnActivityMinTime()
    self.tips_button_count:SetNumber(ActivityManager:GetHaveRewardActivitiesCount())
end
function WidgetAutoSeasonButton:OnActivitiesChanged()
    self.min_time = ActivityManager:GetOnActivityMinTime()
    self.tips_button_count:SetNumber(ActivityManager:GetHaveRewardActivitiesCount())
end
function WidgetAutoSeasonButton:OnActivitiesExpiredLimitChanged()
    self.min_time = ActivityManager:GetOnActivityMinTime()
    self.tips_button_count:SetNumber(ActivityManager:GetHaveRewardActivitiesCount())
end
function WidgetAutoSeasonButton:OnRankChanged()
    self.min_time = ActivityManager:GetOnActivityMinTime()
    self.tips_button_count:SetNumber(ActivityManager:GetHaveRewardActivitiesCount())
end
-- For WidgetAutoOrder
function WidgetAutoSeasonButton:CheckVisible()
    return ActivityManager:IsAnyActivityEnable()
end

function WidgetAutoSeasonButton:GetElementSize()
    return {width = 68, height = 90 * self:getScaleY()}
end

return WidgetAutoSeasonButton


--
-- Author: Kenny Dai
-- Date: 2016-05-26 11:09:41
--
local Enum = import("..utils.Enum")
local MultiObserver = import("..entity.MultiObserver")
local Localize = import("..utils.Localize")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local ScheduleActivities = GameDatas.ScheduleActivities.type
local scoreCondition = GameDatas.ScheduleActivities.scoreCondition
local ActivityManager = class("ActivityManager", MultiObserver)
ActivityManager.LISTEN_TYPE = Enum("ACTIVITY_CHANGED","ON_RANK_CHANGED","ON_LIMIT_CHANGED")
ActivityManager.EXPIRED_GET_LIMIT = 600 --获取过期赛季排名奖励限制时间 10分钟后

function ActivityManager:ctor()
    ActivityManager.super.ctor(self)
    self:GetActivitiesFromServer()
    self.rank = {}
end
-- 从服务器获取所有活动信息
function ActivityManager:GetActivitiesFromServer()
    NetManager:getActivitiesPromise():done(function (response)
        if response.success then
            self.activities = response.msg.activities
            self:IteratorActivityExpired(function (i,activity)
                self:GetExpiredActivityPlayerRankFromServer(activity.type)
                local ep_time = app.timer:GetServerTime() - (activity.removeTime/1000 - ScheduleActivities[activity.type].expireHours * 60 * 60) -- 过期后十分钟可以领取排行榜奖励
                if ep_time <= self.EXPIRED_GET_LIMIT then
                    self:SchedulerExpiredGetReward(activity.type,self.EXPIRED_GET_LIMIT - ep_time)
                end
            end)
            if self.handle_next then
                scheduler.unscheduleGlobal(self.handle_next)
                self.handle_next = nil
            end
            if self.handle then
                scheduler.unscheduleGlobal(self.handle)
                self.handle = nil
            end
            self:addSchdulerRefresh__()
            self:NotifyListeneOnType(ActivityManager.LISTEN_TYPE.ACTIVITY_CHANGED,function(listener)
                listener:OnActivitiesChanged()
            end)
        end
    end)
end
-- 添加延时计时器更新活动信息
function ActivityManager:addSchdulerRefresh__()
    local activities = self.activities
    local now = app.timer:GetServerTime()
    local next_time,n_activity
    for i,nextActivity in ipairs(activities.next) do
        local tmpTime = nextActivity.startTime/1000 - now
        if not next_time or tmpTime < next_time then
            next_time = tmpTime
            n_activity = nextActivity
        end
    end
    local on_time
    for i,onActivity in ipairs(activities.on) do
        local tmpTime = onActivity.finishTime/1000 - now
        if not on_time or tmpTime < on_time then
            on_time = tmpTime
        end
    end
    local expired_time
    for i,expiredActivity in ipairs(activities.expired) do
        local tmpTime = expiredActivity.removeTime/1000 - now
        if not expired_time or tmpTime < expired_time then
            expired_time = tmpTime
        end
    end
    local time = math.min(on_time or math.huge,next_time or math.huge,expired_time or math.huge) 
    if time and time~= math.huge then
        self.handle = scheduler.performWithDelayGlobal(function ()
            self:GetActivitiesFromServer()
        end, time)
    end
    if next_time then
        self.handle_next = scheduler.performWithDelayGlobal(function ()
            GameGlobalUI:showNotice("info",string.format(_("%s已经开始"),Localize.activities[n_activity.type]))
        end, next_time)
    end
end
-- 获取已经结束的活动的玩家排行
function ActivityManager:GetExpiredActivityPlayerRankFromServer(type)
    NetManager:getPlayerActivityRankPromise(type):done(function ( response )
        local myRank = response.msg.myRank
        if myRank ~= json.null and tonumber(myRank) then
            self.rank[type] = tonumber(myRank)
            self:NotifyListeneOnType(ActivityManager.LISTEN_TYPE.ON_RANK_CHANGED,function(listener)
                listener:OnRankChanged()
            end)
        end
    end)
end
function ActivityManager:GetActivityConfig(type)
    return ScheduleActivities[type]
end
-- 获取本地活动信息
function ActivityManager:GetLocalActivities()
    return self.activities
end
function ActivityManager:IteratorActivityOn(func)
    table.foreach(self.activities.on, func)
end
function ActivityManager:IteratorActivityExpired(func)
    table.foreach(self.activities.expired, func)
end
function ActivityManager:IteratorActivityNext(func)
    table.foreach(self.activities.next, func)
end
function ActivityManager:GetMyRank(type)
    return self.rank[type]
end
-- 获取所有能领取奖励的活动的数量
function ActivityManager:GetHaveRewardActivitiesCount()
    local count = 0
    self:IteratorActivityOn(function (i,serverActivity)
        if self:IsPlayerExpiredActivityValid(serverActivity.type) then
            if self:GetActivityScoreGotIndex(serverActivity.type) > 0 then
                count = count + 1
            end
        end
    end)
    self:IteratorActivityExpired(function (i,serverActivity)
        if self:IsPlayerExpiredActivityValid(serverActivity.type) then
            if self:GetActivityScoreGotIndex(serverActivity.type) > 0 then
                count = count + 1
            elseif not User.activities[serverActivity.type].rankRewardsGeted then
                local ep_time = app.timer:GetServerTime() - (serverActivity.removeTime/1000 - ScheduleActivities[serverActivity.type].expireHours * 60 * 60) -- 过期后十分钟可以领取排行榜奖励
                if ep_time > self.EXPIRED_GET_LIMIT and self.rank[serverActivity.type] and self.rank[serverActivity.type] <= ScheduleActivities[serverActivity.type].maxRank then
                    count = count + 1
                end
            end
        end
    end)
    return count
end
function ActivityManager:HaveRewardByType(type)
    local isHave = false
    self:IteratorActivityOn(function (i,serverActivity)
        if type == serverActivity.type and self:IsPlayerExpiredActivityValid(serverActivity.type) then
            if self:GetActivityScoreGotIndex(serverActivity.type) > 0 then
                isHave = true
            end
        end
    end)
    self:IteratorActivityExpired(function (i,serverActivity)
        if type == serverActivity.type and self:IsPlayerExpiredActivityValid(type) then
            if self:GetActivityScoreGotIndex(type) > 0 then
                isHave = true
            end
            if not User.activities[type].rankRewardsGeted then
                local ep_time = app.timer:GetServerTime() - (serverActivity.removeTime/1000 - ScheduleActivities[type].expireHours * 60 * 60) -- 过期后十分钟可以领取排行榜奖励
                if ep_time > self.EXPIRED_GET_LIMIT and self.rank[type] and self.rank[type] <= ScheduleActivities[type].maxRank then
                    isHave = true
                end
            end
        end
    end)
    return isHave
end
function ActivityManager:SchedulerExpiredGetReward(type,ep_time)
    self.expired_handle = self.expired_handle or {}
    if self.expired_handle[type] then
        scheduler.unscheduleGlobal(self.expired_handle[type])
        self.expired_handle[type] = nil
    end
    self.expired_handle[type] = scheduler.performWithDelayGlobal(function ()
        self:NotifyListeneOnType(ActivityManager.LISTEN_TYPE.ON_LIMIT_CHANGED,function(listener)
            listener:OnActivitiesExpiredLimitChanged()
        end)
    end, ep_time)
end
-- 玩家活动数据是否有效
function ActivityManager:IsPlayerExpiredActivityValid(activity_type)
    local activities = self.activities
    local userActiviy = User.activities
    for i,serverActivity in ipairs(activities.on) do
        if serverActivity.type == activity_type then
            return userActiviy[activity_type].lastActive >= (serverActivity.finishTime - (ScheduleActivities[activity_type].existHours * 60 * 60 * 1000))
        end
    end
    for i,serverActivity in ipairs(activities.expired) do
        if serverActivity.type == activity_type then
            return userActiviy[activity_type].lastActive >= (serverActivity.removeTime - (ScheduleActivities[activity_type].expireHours * 60 * 60 * 1000) - (ScheduleActivities[activity_type].existHours * 60 * 60 * 1000))
        end
    end
end
-- 获取活动积分奖励当前可领取index
function ActivityManager:GetActivityScoreGotIndex(type)
    local userActiviy = User.activities[type]
    if userActiviy.scoreRewardedIndex < 5 then
        if self:IsPlayerExpiredActivityValid(type) then
            local config = self:GetActivityConfig(type)
            for i = userActiviy.scoreRewardedIndex + 1,5 do
                if userActiviy.score >= config["scoreIndex"..i] then
                    return i
                end
            end
        end
    end
    return 0
end
-- 获取活动积分奖励
function ActivityManager:GetActivityScoreByIndex(type,index)
    local reward = string.split(self:GetActivityConfig(type)["scoreRewards"..index],',')
    local score_reward = {}
    for i,re in ipairs(reward) do
        local tmp = string.split(re,":")
        table.insert(score_reward, {type = tmp[1],name = tmp[2],count = tmp[3]})
    end
    return score_reward
end
-- 获取活动积分分数段
function ActivityManager:GetActivityScorePonits(type)
    local score_points = {}
    for i=1,5 do
        table.insert(score_points, self:GetActivityConfig(type)["scoreIndex"..i])
    end
    return score_points
end
-- 获取我的活动排名奖励
function ActivityManager:GetMyActivityRankReward(type)
    local score_reward = {}
    local myRank = self.rank[type]
    local config = self:GetActivityConfig(type)
    if self:IsPlayerExpiredActivityValid(type) and not User.activities[type].rankRewardsGeted and myRank and myRank <= config.maxRank then
        for i,v in ipairs(self:GetActivityRankRewardRegion()) do
            local point = config["rankPoint"..i]
            if myRank <= v[2] and myRank >= v[1] then
                local reward = string.split(config["rankRewards"..i],',')
                for i,re in ipairs(reward) do
                    local tmp = string.split(re,":")
                    table.insert(score_reward, {type = tmp[1],name = tmp[2],count = tmp[3]})
                end
            end
        end
    end
    return score_reward
end
-- 获取活动排名奖励
function ActivityManager:GetActivityRankReward(type)
    local score_reward = {}
    local config = self:GetActivityConfig(type)
    for i=1,8 do
        score_reward[i] = {}
        local reward = string.split(config["rankRewards"..i],',')
        for j,re in ipairs(reward) do
            local tmp = string.split(re,":")
            table.insert(score_reward[i], {type = tmp[1],name = tmp[2],count = tmp[3]})
        end
    end
    return score_reward
end
-- 排名奖励范围区间
function ActivityManager:GetActivityRankRewardRegion()
    return {
        {1,1},
        {2,2},
        {3,3},
        {4,10},
        {11,25},
        {26,50},
        {51,75},
        {76,100},
    }
end
-- 获取活动本地化
function ActivityManager:GetActivityLocalize(type)
    return Localize.activities[type]
end
-- 获取活动获取积分条件
function ActivityManager:GetActivityScoreCondition(type)
    local config = scoreCondition
    if type == "gacha" then
        return {
            {_("普通抽奖1次"),config.normalGacha.score},
            {_("高级抽奖1次"),config.andvancedGacha.score},
        }
    elseif type == "collectResource" then
        return {
            {_("村落每采集1单位的木材"),config.collectOne_wood.score},
            {_("村落每采集1单位的石料"),config.collectOne_stone.score},
            {_("村落每采集1单位的铁矿"),config.collectOne_iron.score},
            {_("村落每采集1单位的粮食"),config.collectOne_food.score},
            {_("村落每采集1单位的银币"),config.collectOne_coin.score},
            {_("掠夺玩家1单位的木材"),config.robOne_wood.score},
            {_("掠夺玩家1单位的石料"),config.robOne_stone.score},
            {_("掠夺玩家1单位的铁矿"),config.robOne_iron.score},
            {_("掠夺玩家1单位的粮食"),config.robOne_food.score},
            {_("掠夺玩家1单位的银币"),config.robOne_coin.score},
        }
    elseif type == "pveFight" then
        return {
            {_("探索1-4章的1个关卡"),config.attackPve_1_4.score},
            {_("探索5-8章的1个关卡"),config.attackPve_5_8.score},
            {_("探索9-12章的1个关卡"),config.attackPve_9_12.score},
            {_("探索13-16章的1个关卡"),config.attackPve_13_16.score},
            {_("探索17-20章的1个关卡"),config.attackPve_17_20.score},
            {_("探索21-24章的1个关卡"),config.attackPve_21_24.score},
        }
    elseif type == "attackMonster" then
        return {
            {_("黑龙军团Lv1-Lv8"),config.attackOneMonster_1_8.score},
            {_("黑龙军团Lv9-Lv16"),config.attackOneMonster_9_16.score},
            {_("黑龙军团Lv17-Lv24"),config.attackOneMonster_17_24.score},
            {_("黑龙军团Lv25-Lv32"),config.attackOneMonster_25_32.score},
            {_("黑龙军团Lv33-Lv40"),config.attackOneMonster_33_40.score},
        }
    elseif type == "collectHeroBlood" then
        return {
            {_("获取1单位的英雄之血"),config.getOneBlood.score},
        }
    elseif type == "recruitSoldiers" then
        return {
            {_("招募部队Ⅰ：步兵/弓兵"),config.recruitOneLevel1_infantry_archer.score},
            {_("招募部队Ⅰ：骑兵/攻城武器"),config.recruitOneLevel1_cavalry_siege.score},
            {_("招募部队Ⅱ：步兵/弓兵"),config.recruitOneLevel2_infantry_archer.score},
            {_("招募部队Ⅱ：骑兵/攻城武器"),config.recruitOneLevel2_cavalry_siege.score},
            {_("招募部队Ⅲ：步兵/弓兵"),config.recruitOneLevel3_infantry_archer.score},
            {_("招募部队Ⅲ：骑兵/攻城武器"),config.recruitOneLevel3_cavalry_siege.score},
        }
    end
end
return ActivityManager
















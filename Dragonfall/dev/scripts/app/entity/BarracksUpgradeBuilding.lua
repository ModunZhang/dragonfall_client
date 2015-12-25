local barracks_config = GameDatas.BuildingFunction.barracks
local promise = import("..utils.promise")
local Localize = import("..utils.Localize")
local UpgradeBuilding = import(".UpgradeBuilding")
local BarracksUpgradeBuilding = class("BarracksUpgradeBuilding", UpgradeBuilding)
function BarracksUpgradeBuilding:ctor(...)
    BarracksUpgradeBuilding.super.ctor(self, ...)
    self.recruit_soldier_callbacks = {}
    self.finish_soldier_callbacks = {}
end
function BarracksUpgradeBuilding:ResetAllListeners()
    self.recruit_soldier_callbacks = {}
    self.finish_soldier_callbacks = {}
    BarracksUpgradeBuilding.super.ResetAllListeners(self)
end
function BarracksUpgradeBuilding:GeneralSoldierLocalPush(event)
    if ext and ext.localpush then
        local soldier_type, soldier_count = event:GetRecruitInfo()
        local pushIdentity = event:Id()
        local title = string.format(_("招募%s X%d完成"),Localize.soldier_name[soldier_type],soldier_count)
        app:GetPushManager():UpdateSoldierPush(event:FinishTime(),title,pushIdentity)
    end
end
function BarracksUpgradeBuilding:CancelSoldierLocalPush(pushIdentity)
    if ext and ext.localpush then
        app:GetPushManager():CancelSoldierPush(pushIdentity)
    end
end
function BarracksUpgradeBuilding:GetNextLevelMaxRecruitSoldierCount()
    return barracks_config[self:GetNextLevel()].maxRecruit
end
function BarracksUpgradeBuilding:GetMaxRecruitSoldierCount()
    if self:GetLevel() > 0 then
        return barracks_config[self:GetEfficiencyLevel()].maxRecruit
    end
    return 0
end
function BarracksUpgradeBuilding:OnUserDataChanged(...)
    BarracksUpgradeBuilding.super.OnUserDataChanged(self, ...)
    local userData, current_time, location_info, sub_location_id, deltaData = ...
    if deltaData then
        local ok, value = deltaData("soldierEvents.add")
        if ok then
            self:CheckRecruit(value[1].name)
        end
        local ok, value = deltaData("soldierEvents.remove")
        if ok then
            self:CheckFinish(value[1].name)
        end
    end
end
function BarracksUpgradeBuilding:GetUnlockSoldiers()
    local r = {}
    for _,config in ipairs(barracks_config) do
        for _,v in ipairs(string.split(config.unlockedSoldiers, ",")) do
            local level = r[v]
            r[v] = not level and config.level or (config.level < level and config.level or level)
        end
    end
    return r
end


return BarracksUpgradeBuilding





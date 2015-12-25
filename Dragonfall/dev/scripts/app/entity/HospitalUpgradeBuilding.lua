local config_function = GameDatas.BuildingFunction.hospital
local promise = import("..utils.promise")
local Localize = import("..utils.Localize")
local UpgradeBuilding = import(".UpgradeBuilding")
local HospitalUpgradeBuilding = class("HospitalUpgradeBuilding", UpgradeBuilding)
function HospitalUpgradeBuilding:ctor(building_info)
    HospitalUpgradeBuilding.super.ctor(self, building_info)

    self.treat_soldier_callbacks = {}
    self.finish_soldier_callbacks = {}
end
function HospitalUpgradeBuilding:GeneralSoldierLocalPush(event)
    if ext and ext.localpush then
        local soldiers = event:GetTreatInfo()
        local pushIdentity = event:Id()
        local soldiers_desc = ""
        for k,v in pairs(soldiers) do
            local soldier_type = v.name
            local count = v.count
            soldiers_desc = soldiers_desc .. (soldiers_desc == "" and "" or ",").. string.format(_("%s X %d "),Localize.soldier_name[soldier_type],count)
        end
        local title = string.format(_("治愈%s完成"),soldiers_desc)
        app:GetPushManager():UpdateSoldierPush(event:FinishTime(),title,pushIdentity)
    end
end
function HospitalUpgradeBuilding:CancelSoldierLocalPush(id)
    if ext and ext.localpush then
        app:GetPushManager():CancelSoldierPush(id)
    end
end
function HospitalUpgradeBuilding:ResetAllListeners()
    self.treat_soldier_callbacks = {}
    self.finish_soldier_callbacks = {}

    HospitalUpgradeBuilding.super.ResetAllListeners(self)
end
-- 医院伤兵是否超过上限
function HospitalUpgradeBuilding:IsWoundedSoldierOverhead()
    local max = self:GetMaxCasualty()
    local current = self:BelongCity():GetUser():GetTreatCitizen()
    return current > max
end
--获取下一级伤病最大上限
function HospitalUpgradeBuilding:GetNextLevelMaxCasualty()
    local tech = self:BelongCity():GetUser().productionTechs["rescueTent"]
    local tech_effect = UtilsForTech:GetEffect("rescueTent", tech)
    return  math.floor(config_function[self:GetNextLevel()].maxCitizen * (1 + tech_effect))
end
--获取伤病最大上限
function HospitalUpgradeBuilding:GetMaxCasualty()
    if self:GetLevel() > 0 then
        local tech = self:BelongCity():GetUser().productionTechs["rescueTent"]
        local tech_effect = UtilsForTech:GetEffect("rescueTent", tech)
        return math.floor(config_function[self:GetEfficiencyLevel()].maxCitizen * (1 + tech_effect))
    end
    return 0
end
--获取战斗伤病比例
function HospitalUpgradeBuilding:GetCasualtyRate()
    if self:GetLevel() > 0 then
        return config_function[self:GetEfficiencyLevel()].casualtyRate
    end
    return 0
end
return HospitalUpgradeBuilding













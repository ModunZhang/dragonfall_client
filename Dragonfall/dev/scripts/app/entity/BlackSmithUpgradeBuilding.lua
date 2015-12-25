local config_equipments = GameDatas.DragonEquipments.equipments
local config_function = GameDatas.BuildingFunction.blackSmith
local config_levelup = GameDatas.BuildingLevelUp.blackSmith
local Localize = import("..utils.Localize")
local UpgradeBuilding = import(".UpgradeBuilding")
local BlackSmithUpgradeBuilding = class("BlackSmithUpgradeBuilding", UpgradeBuilding)

function BlackSmithUpgradeBuilding:ctor(...)
    BlackSmithUpgradeBuilding.super.ctor(self, ...)
end
function BlackSmithUpgradeBuilding:GetNextLevelEfficiency()
    return config_function[self:GetNextLevel()].efficiency
end
function BlackSmithUpgradeBuilding:GetEfficiency()
    if self:GetLevel() > 0 then
        return config_function[self:GetLevel()].efficiency
    end
    return 0
end
return BlackSmithUpgradeBuilding




















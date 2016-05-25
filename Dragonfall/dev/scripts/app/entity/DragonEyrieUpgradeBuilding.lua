--
-- Author: Danny He
-- Date: 2014-09-17 09:22:12
--
local config_function            = GameDatas.BuildingFunction.dragonEyrie
local UpgradeBuilding            = import(".UpgradeBuilding")
local DragonEyrieUpgradeBuilding = class("DragonEyrieUpgradeBuilding", UpgradeBuilding)


function DragonEyrieUpgradeBuilding:ctor(building_info)
    DragonEyrieUpgradeBuilding.super.ctor(self,building_info)
end
function DragonEyrieUpgradeBuilding:EnergyMax()
    return config_function[self:GetEfficiencyLevel()].energyMax
end

function DragonEyrieUpgradeBuilding:GetHPRecoveryPerHourWithoutBuff()
    local hprecoveryperhour = config_function[self:GetEfficiencyLevel()].hpRecoveryPerHour
    return hprecoveryperhour
end
function DragonEyrieUpgradeBuilding:GetNextLevelHPRecoveryPerHour()
    return config_function[self:GetNextLevel()].hpRecoveryPerHour
end


return DragonEyrieUpgradeBuilding



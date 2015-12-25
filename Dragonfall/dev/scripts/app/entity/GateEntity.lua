local UpgradeBuilding = import(".UpgradeBuilding")
local GateEntity = class("GateEntity", UpgradeBuilding)
local config_wall = GameDatas.BuildingFunction.wall
function GateEntity:ctor(building_info)
    GateEntity.super.ctor(self, building_info)
end
function GateEntity:GetConfig()
    return config_wall
end

return GateEntity






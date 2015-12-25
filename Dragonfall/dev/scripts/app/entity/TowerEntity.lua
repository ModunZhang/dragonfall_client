local UpgradeBuilding = import(".UpgradeBuilding")
local TowerEntity = class("TowerEntity", UpgradeBuilding)
local abs = math.abs
function TowerEntity:ctor(building_info)
    TowerEntity.super.ctor(self, building_info)
end
function TowerEntity:GetConfig()
    return self.config_building_function[self:GetType()]
end
return TowerEntity






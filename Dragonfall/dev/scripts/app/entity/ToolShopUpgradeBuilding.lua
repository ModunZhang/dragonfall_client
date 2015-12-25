local config_function = GameDatas.BuildingFunction.toolShop
local config_levelup = GameDatas.BuildingLevelUp.toolShop
local UpgradeBuilding = import(".UpgradeBuilding")
local ToolShopUpgradeBuilding = class("ToolShopUpgradeBuilding", UpgradeBuilding)
local unpack = unpack
local pairs = pairs
function ToolShopUpgradeBuilding:ctor(building_info)
    ToolShopUpgradeBuilding.super.ctor(self, building_info)
end
local needs = {"Wood", "Stone", "Iron", "time"}
function ToolShopUpgradeBuilding:GetNeedByCategory(category)
    local config = config_function[self:GetEfficiencyLevel()]
    local key = category == "buildingMaterials" and "Bm" or "Am"
    local need = {}
    for _, v in ipairs(needs) do
        table.insert(need, config[string.format("product%s%s", key, v)])
    end
    return config["production"], unpack(need)
end
function ToolShopUpgradeBuilding:GetProduction()
    local config = config_function[self:GetEfficiencyLevel()]
    return config["production"]
end
function ToolShopUpgradeBuilding:GetNextLevelProduction()
    local config = config_function[self:GetNextLevel()]
    return config["production"]
end
function ToolShopUpgradeBuilding:GetProductionType()
    local config = config_function[self:GetEfficiencyLevel()]
    return config["productionType"]
end
function ToolShopUpgradeBuilding:GetNextLevelProductionType()
    local config = config_function[self:GetNextLevel()]
    return config["productionType"]
end
return ToolShopUpgradeBuilding
















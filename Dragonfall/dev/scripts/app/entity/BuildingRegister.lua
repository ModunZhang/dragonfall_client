local UpgradeBuilding = import("..entity.UpgradeBuilding")
local BuildingRegister = {
    woodcutter 		= import("..entity.WoodResourceUpgradeBuilding"),
    farmer 			= import("..entity.FoodResourceUpgradeBuilding"),
    miner 			= import("..entity.IronResourceUpgradeBuilding"),
    quarrier 		= import("..entity.StoneResourceUpgradeBuilding"),
    dwelling 		= import("..entity.CitizenResourceUpgradeBuilding"),
    dragonEyrie     = import("..entity.DragonEyrieUpgradeBuilding"),
}
setmetatable(BuildingRegister, {__index = function(t, k)
	return UpgradeBuilding
end})   
return BuildingRegister
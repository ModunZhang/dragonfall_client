local UpgradeBuilding = import("..entity.UpgradeBuilding")
local BuildingRegister = {
    toolShop 		= import("..entity.ToolShopUpgradeBuilding"),
    woodcutter 		= import("..entity.WoodResourceUpgradeBuilding"),
    farmer 			= import("..entity.FoodResourceUpgradeBuilding"),
    miner 			= import("..entity.IronResourceUpgradeBuilding"),
    quarrier 		= import("..entity.StoneResourceUpgradeBuilding"),
    dwelling 		= import("..entity.CitizenResourceUpgradeBuilding"),
    dragonEyrie     = import("..entity.DragonEyrieUpgradeBuilding"),
    foundry         = import("..entity.PResourceUpgradeBuilding"),
    stoneMason      = import("..entity.PResourceUpgradeBuilding"),
    lumbermill      = import("..entity.PResourceUpgradeBuilding"),
    mill            = import("..entity.PResourceUpgradeBuilding"),
    townHall 	    = import("..entity.PResourceUpgradeBuilding"),
    tradeGuild 	    = import("..entity.TradeGuildUpgradeBuilding"),
}
setmetatable(BuildingRegister, {__index = function(t, k)
	return UpgradeBuilding
end})   
return BuildingRegister
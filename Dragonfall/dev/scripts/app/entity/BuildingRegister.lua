local UpgradeBuilding = import("..entity.UpgradeBuilding")
local BuildingRegister = {
    toolShop 		= import("..entity.ToolShopUpgradeBuilding"),
    blackSmith      = import("..entity.BlackSmithUpgradeBuilding"),
    woodcutter 		= import("..entity.WoodResourceUpgradeBuilding"),
    farmer 			= import("..entity.FoodResourceUpgradeBuilding"),
    miner 			= import("..entity.IronResourceUpgradeBuilding"),
    quarrier 		= import("..entity.StoneResourceUpgradeBuilding"),
    dwelling 		= import("..entity.CitizenResourceUpgradeBuilding"),
    dragonEyrie     = import("..entity.DragonEyrieUpgradeBuilding"),
    materialDepot   = import("..entity.MaterialDepotUpgradeBuilding"),
    foundry         = import("..entity.PResourceUpgradeBuilding"),
    stoneMason      = import("..entity.PResourceUpgradeBuilding"),
    lumbermill      = import("..entity.PResourceUpgradeBuilding"),
    mill            = import("..entity.PResourceUpgradeBuilding"),
    townHall 	    = import("..entity.TownHallUpgradeBuilding"),
    tradeGuild 	    = import("..entity.TradeGuildUpgradeBuilding"),
    trainingGround  = import("..entity.MilitaryTechnologyUpgradeBuilding"),
    stable          = import("..entity.MilitaryTechnologyUpgradeBuilding"),
    hunterHall      = import("..entity.MilitaryTechnologyUpgradeBuilding"),
    workshop        = import("..entity.MilitaryTechnologyUpgradeBuilding"),
}
setmetatable(BuildingRegister, {__index = function(t, k)
	return UpgradeBuilding
end})   
return BuildingRegister
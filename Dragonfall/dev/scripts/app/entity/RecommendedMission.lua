local cityBuild = GameDatas.GrowUpTasks.cityBuild
local function cityBuildIdBy(name,level)
	for i,v in pairs(cityBuild) do
		if v.name == name and v.level == level then
			return v.id
		end
	end
	print(name,level)
	assert(false, "没有找到cityBuild成长任务!")
end

local soldierCount = GameDatas.GrowUpTasks.soldierCount
local function soldierCountIdBy(name,index)
	for i,v in pairs(soldierCount) do
		if v.name == name and v.index == index then
			return v.id
		end
	end
	assert(false, "没有找到soldierCount成长任务!")
end

local pveCount = GameDatas.GrowUpTasks.pveCount
local function pveCountIdBy(index)
	for i,v in pairs(pveCount) do
		if v.index == index then
			return v.id
		end
	end
	assert(false, "没有找到pveCount成长任务!")
end


local productionTech = GameDatas.GrowUpTasks.productionTech
local function productionTechIdBy(name, level)
	for i,v in pairs(productionTech) do
		if v.name == name and v.level == level then
			return v.id
		end
	end
	assert(false, "没有找到productionTech成长任务!")
end

local recommands = {	
	{ type = "cityBuild"		, id = cityBuildIdBy("dwelling", 1)		  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("keep", 2) 		  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("barracks", 1) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("farmer", 1)		  	},
	{ type = "soldierCount"		, id = soldierCountIdBy("swordsman_1", 1) 	},
	{ type = "pveCount"			, id = pveCountIdBy(1) 					  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("keep", 3) 		  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("hospital", 1) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("woodcutter", 1)	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("keep", 4) 		  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("academy", 1) 	  	  	},
	{ type = "productionTech"	, id = productionTechIdBy("forestation",1)	},
	{ type = "cityBuild"		, id = cityBuildIdBy("barracks", 2) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("warehouse", 2)	  	},
	{ type = "soldierCount"		, id = soldierCountIdBy("ranger_1", 1) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("keep", 5)	  		  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("materialDepot", 1)  	},
	{ type = "pveCount"			, id = pveCountIdBy(2) 	  				  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("quarrier", 1)		  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("miner", 1)		  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("hospital", 2)		  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("academy", 2)		  	},
	{ type = "productionTech"	, id = productionTechIdBy("crane",1)		},
	{ type = "cityBuild"		, id = cityBuildIdBy("materialDepot", 2)  	},
	{ type = "pveCount"			, id = pveCountIdBy(3) 	  				  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("barracks", 3) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("wall", 2)		  		},
	{ type = "soldierCount"		, id = soldierCountIdBy("swordsman_1", 2) 	},
	{ type = "cityBuild"		, id = cityBuildIdBy("dragonEyrie", 2) 		},
	{ type = "cityBuild"		, id = cityBuildIdBy("tower", 2) 			},
	{ type = "pveCount"			, id = pveCountIdBy(4) 	  				  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("dwelling", 2)		  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("quarrier", 2)		  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("woodcutter", 2)		},
	{ type = "cityBuild"		, id = cityBuildIdBy("miner", 2)		  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("farmer", 2)		  	},
	{ type = "pveCount"			, id = pveCountIdBy(5) 	  				  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("academy", 3) 	  		},
	{ type = "cityBuild"		, id = cityBuildIdBy("warehouse", 3) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("materialDepot", 3) 	},
	{ type = "cityBuild"		, id = cityBuildIdBy("wall", 3) 			},
	{ type = "cityBuild"		, id = cityBuildIdBy("dwelling", 3) 		},
	{ type = "cityBuild"		, id = cityBuildIdBy("dwelling", 4) 		},
	{ type = "soldierCount"		, id = soldierCountIdBy("ranger_1", 2) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("quarrier", 3)		  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("quarrier", 4)		  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("woodcutter", 3)		},
	{ type = "cityBuild"		, id = cityBuildIdBy("woodcutter", 4)		},
	{ type = "cityBuild"		, id = cityBuildIdBy("miner", 3)		  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("miner", 4)		  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("barracks", 4) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("barracks", 5) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("warehouse", 4) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("warehouse", 5) 	  	},
	{ type = "pveCount"			, id = pveCountIdBy(6) 	  				  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("hospital", 3) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("dragonEyrie", 3) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("wall", 4) 	  		},
	{ type = "productionTech"	, id = productionTechIdBy("stoneCarving", 2)},
	{ type = "cityBuild"		, id = cityBuildIdBy("wall", 5) 	  		},
	
	{ type = "cityBuild"		, id = cityBuildIdBy("keep", 6) 	  		},
	{ type = "cityBuild"		, id = cityBuildIdBy("blackSmith", 1) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("dwelling", 5) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("dwelling", 6) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("quarrier", 5) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("quarrier", 6) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("woodcutter", 5) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("woodcutter", 6) 	  	},
	{ type = "pveCount"			, id = pveCountIdBy(7) 	  				  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("warehouse", 6) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("academy", 4) 	  		},
	{ type = "cityBuild"		, id = cityBuildIdBy("dragonEyrie", 4) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("miner", 5) 	  		},
	{ type = "cityBuild"		, id = cityBuildIdBy("miner", 6) 	  		},
	{ type = "cityBuild"		, id = cityBuildIdBy("farmer", 3) 	  		},
	{ type = "cityBuild"		, id = cityBuildIdBy("farmer", 4) 	  		},
	{ type = "cityBuild"		, id = cityBuildIdBy("farmer", 5) 	  		},
	{ type = "cityBuild"		, id = cityBuildIdBy("farmer", 6) 	  		},
	{ type = "pveCount"			, id = pveCountIdBy(8) 	  				  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("barracks", 6) 	  	},
	{ type = "soldierCount"		, id = soldierCountIdBy("lancer_1", 1) 	  	},
	{ type = "cityBuild"		, id = cityBuildIdBy("blackSmith", 2) 		},
	{ type = "cityBuild"		, id = cityBuildIdBy("wall", 6) 			},
}



for i = 1, 11 do
	table.insert(recommands,
	{ type = "cityBuild"		, id = cityBuildIdBy("keep", 6 + i) 		})
	table.insert(recommands,
	{ type = "cityBuild"		, id = cityBuildIdBy("dwelling", 6 + i) 	})
	table.insert(recommands,
	{ type = "cityBuild"		, id = cityBuildIdBy("quarrier", 6 + i) 	})
	table.insert(recommands,
	{ type = "cityBuild"		, id = cityBuildIdBy("woodcutter", 6 + i) 	})
	table.insert(recommands,
	{ type = "pveCount"			, id = pveCountIdBy(8 + (i-1) * 2 + 1) 		})
	table.insert(recommands,
	{ type = "cityBuild"		, id = cityBuildIdBy("warehouse", 6 + i) 	})
	table.insert(recommands,
	{ type = "cityBuild"		, id = cityBuildIdBy("academy", 4 + i) 		})
	table.insert(recommands,
	{ type = "cityBuild"		, id = cityBuildIdBy("dragonEyrie", 4 + i) 	})
	table.insert(recommands,
	{ type = "cityBuild"		, id = cityBuildIdBy("miner", 6 + i) 		})
	table.insert(recommands,
	{ type = "cityBuild"		, id = cityBuildIdBy("farmer", 6 + i) 		})
	table.insert(recommands,
	{ type = "pveCount"			, id = pveCountIdBy(8 + (i-1) * 2 + 2) 		})
	table.insert(recommands,
	{ type = "cityBuild"		, id = cityBuildIdBy("barracks", 6 + i) 	})
	table.insert(recommands,
	{ type = "cityBuild"		, id = cityBuildIdBy("hospital", 3 + i)		})
	table.insert(recommands,
	{ type = "cityBuild"		, id = cityBuildIdBy("blackSmith", 2 + i)	})
	table.insert(recommands,
	{ type = "cityBuild"		, id = cityBuildIdBy("wall", 6 + i)			})
end


local cityBuild_checkmap = {}
local soldierCount_checkmap = {}
local pveCount_checkmap = {}
for i,v in ipairs(recommands) do
	if "cityBuild" == v.type then
		local config = cityBuild[v.id]
		cityBuild_checkmap[config.name] = cityBuild_checkmap[config.name] or {}
		cityBuild_checkmap[config.name][config.index] = true
	elseif "soldierCount" == v.type then
		local config = soldierCount[v.id]
		soldierCount_checkmap[config.name] = soldierCount_checkmap[config.name] or {}
		soldierCount_checkmap[config.name][config.index] = true
	elseif "pveCount" == v.type then
		local config = pveCount[v.id]
		pveCount_checkmap[config.index] = true
	end
end

for k,v in pairs(cityBuild_checkmap) do
	if table.nums(v) ~= #v then
		assert(false, k.."城建任务不连续")
	end
end
for k,v in pairs(soldierCount_checkmap) do
	if table.nums(v) ~= #v then
		assert(false, k.."士兵任务不连续")
	end
end
if table.nums(pveCount_checkmap) ~= #pveCount_checkmap then
	assert(false, "pve任务不联系")
end



return recommands





			
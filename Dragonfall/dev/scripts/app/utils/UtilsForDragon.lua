UtilsForDragon = {
	dragonStarMax = 4
}
local Localize = import(".Localize")
local dragonEyrie = GameDatas.BuildingFunction.dragonEyrie
function UtilsForDragon:CanHatchAnyDragons(userData)
	local level = userData.buildings.location_4.level
	return #self:GetHatchedDragons(userData) < dragonEyrie[level].dragonCount
end
function UtilsForDragon:HowManyLevelsCanHatchDragons(userData)
    local count = #self:GetHatchedDragons(userData)
    for i = 1,#dragonEyrie do
        if dragonEyrie[i].dragonCount > count then
            return i
        end
    end
end
local dragonLevel = GameDatas.Dragons.dragonLevel
function UtilsForDragon:GetDragonExpNeed(dragon)
	return dragonLevel[dragon.level] and dragonLevel[dragon.level].expNeed or 0
end
local dragonStar = GameDatas.Dragons.dragonStar
function UtilsForDragon:GetDragonLevelMax(dragon)
	return dragonStar[dragon.star] and dragonStar[dragon.star].levelMax or 0
end
function UtilsForDragon:GetDragon(userData, dragonType)
	return userData.dragons[dragonType]
end
function UtilsForDragon:GetDragonsByPowerSeq(userData)
	local t = {}
	for i,v in ipairs(self:GetSortDragonTypes(userData)) do
		local dragon = userData.dragons[v]
		if dragon.star > 0 then
			table.insert(t, dragon)
		end
	end
    table.sort( t, function(a,b)
    	return self:GetDragonWeight(a) > self:GetDragonWeight(b)
    end )
    return t
end
function UtilsForDragon:GetSortDragonTypes(userData)
	local t = {}
	for k,v in pairs(userData.dragons) do
		table.insert(t, v.type)
	end
	table.sort(t, function(a,b) return a < b end)
	return t
end
function UtilsForDragon:IsDragonHatched(userData, dragonType)
	return userData.dragons[dragonType].star > 0
end
function UtilsForDragon:GetSkillsBySeq(dragon)
	local skills = dragon.skills
	local keys = table.keys(skills)
	table.sort(keys, function(a,b) return a < b end)
    local seqSkills = {}
    for i,v in ipairs(keys) do
        table.insert(seqSkills,skills[v])
    end
    return seqSkills
end
function UtilsForDragon:GetSkillByName(dragon, skillName)
	for k,v in pairs(dragon.skills) do
		if v.name == skillName then
			return v
		end
	end
end
function UtilsForDragon:GetSkillKey(dragon, skill)
	for k,v in pairs(dragon.skills) do
		if skill.name == v.name then
			return k
		end
	end
end
local dragonStar = GameDatas.Dragons.dragonStar
function UtilsForDragon:IsSkillLocked(dragon, skill)
	if dragonStar[dragon.star] then
		local unlockSkills = string.split(dragonStar[dragon.star].skillsUnlocked,",")
		if not table.indexof(unlockSkills, skill.name) then
			return true
		else
			return false
		end
	end
	return true
end
local DragonSkills = GameDatas.DragonSkills
function UtilsForDragon:GetSkillEffect(skill, offset)
	offset = offset or 0
	local configs = DragonSkills[skill.name]
	local level = skill.level + offset
	level = level > #configs and #configs or level
	local config = configs[level]
	if config then
		return config.effect
	end
	return 0
end
function UtilsForDragon:IsSkillLevelMax(skill)
	local configs = DragonSkills[skill.name]
	return #configs == skill.level
end
function UtilsForDragon:GetBloodCost(skill, offset)
	offset = offset or 0
	local configs = DragonSkills[skill.name]
	local config = configs[skill.level + offset]
	if config then
		return config.bloodCost
	end
	return 0
end
function UtilsForDragon:GetSkillEffects(dragon)
	local r = {}
	table.foreach(dragon.skills, function(key,skill)
		if not self:IsSkillLocked(dragon, skill) then
			table.insert(r,{skill.name,self:GetSkillEffect(skill)})
		end
	end)
	return r
end
local equipmentBuff = GameDatas.DragonEquipments.equipmentBuff
function UtilsForDragon:GetEquipmentEffects(dragon)
	local buffer_count = {}
	for k,v in pairs(dragon.equipments) do
		for i,v in ipairs(v.buffs) do
			if not buffer_count[v] then
				buffer_count[v] = 1
			else
				buffer_count[v] = buffer_count[v] + 1
			end
		end
	end
	local equipmentsbuffs = {}
	for key,v in pairs(buffer_count) do
		table.insert(equipmentsbuffs,{key,equipmentBuff[key].buffEffect * v})
	end
	return equipmentsbuffs
end

local citizenPerLeadership = GameDatas.AllianceInitData.intInit.citizenPerLeadership.value
function UtilsForDragon:GetLeadershipByCitizen(userData, dragonType)
	return self:GetLeadershipWithBuff(userData, dragonType) * citizenPerLeadership
end
local dragonLevel = GameDatas.Dragons.dragonLevel
local dragonStar = GameDatas.Dragons.dragonStar
local DragonEquipments = GameDatas.DragonEquipments
function UtilsForDragon:GetLeadershipWithBuff(userData, dragonType)
	local dragon = userData.dragons[dragonType]
	if dragon.level <= 0 then return 0 end
	local leadership = dragonLevel[dragon.level].leadership +  dragonStar[dragon.star].initLeadership
	local buff = self:GetLeadershipBuff(userData, dragonType)
	leadership = leadership + math.floor(leadership * buff)
	for k,v in pairs(dragon.equipments) do
		if #v.name > 0 then
			local config = DragonEquipments[k][string.format("%d_%d",dragon.star,v.star)]
			leadership = leadership + config.leadership
		end
	end
	return leadership
end
function UtilsForDragon:LeaderShipWithoutBuff(dragon)
	local leadership = dragonLevel[dragon.level].leadership +  dragonStar[dragon.star].initLeadership
	return leadership * citizenPerLeadership
end
function UtilsForDragon:GetLeadershipBuff(userData, dragonType)
	local dragon = userData.dragons[dragonType]
	local effect = self:GetSkillEffect(self:GetSkillByName(dragon, 'leadership'))
	if UtilsForItem:IsItemEventActive(userData, "troopSizeBonus") then
		effect = effect + UtilsForItem:GetItemBuff("troopSizeBonus")
	end
	table.foreachi(self:GetEquipmentEffects(dragon),function(__,buffData)
		if buffData[1] == 'troopSizeAdd' then
			effect = effect + buffData[2]
		end
	end)
	effect = effect + UtilsForVip:GetVipBuffByName(userData, "dragonLeaderShipAdd")
	return effect
end
function UtilsForDragon:IsDragonDefenced(userData, dragonType)
	return userData.dragons[dragonType].status == 'defence'
end
function UtilsForDragon:IsDragonFree(userData, dragonType)
	return userData.dragons[dragonType].status == 'free'
end
function UtilsForDragon:IsDragonDead(userData, dragonType)
	return userData.dragons[dragonType].hp <= 0 
end
function UtilsForDragon:GetDragonMaxHp(dragon)
	return self:GetDragonVitality(dragon) * 4
end
function UtilsForDragon:GetDragonVitality(dragon)
	if dragon.level <= 0 then return 0 end
	local vitality = dragonLevel[dragon.level].vitality + dragonStar[dragon.star].initVitality
	local buff = self:GetSkillEffect(self:GetSkillByName(dragon, 'dragonBlood'))
	vitality = vitality + math.floor(vitality * buff)
	for category,equipment in pairs(dragon.equipments) do
		if #equipment.name > 0 then
			local maxStar = DragonEquipments.equipments[equipment.name].maxStar
			local equipmentConfig = DragonEquipments[category][maxStar .. "_" .. equipment.star]
			local strengthAdd = equipmentConfig.vitality
			vitality = vitality + strengthAdd
		end
	end
	return vitality
end
function UtilsForDragon:GetDragonMaxHpWithoutBuff(dragon)
	local vitality = dragonLevel[dragon.level].vitality + dragonStar[dragon.star].initVitality
	return vitality * 4
end
function UtilsForDragon:GetDragonHp(userData, dragonType)
	local dragon = userData.dragons[dragonType]
	if dragon.hp <= 0 or dragon.status == "march" then
		return dragon.hp
	end
    return GameUtils:GetCurrentProduction(
        dragon.hp,
        dragon.hpRefreshTime / 1000,
        self:GetDragonMaxHp(dragon),
		self:GetDragonHPRecoveryWithBuff(userData, dragonType),
        app.timer:GetServerTime()
    )
end
function UtilsForDragon:GetDragonHPRecoveryWithBuff(userData, dragonType)
	local dragon = userData.dragons[dragonType]
	if dragon.hp <= 0 or dragon.status == "march" then
		return 0
	end
	return math.floor(self:GetDragonHPRecovery(userData) * (1 + DataUtils:GetDragonHpBuffTotal()))
end
local dragonEyrie = GameDatas.BuildingFunction.dragonEyrie
function UtilsForDragon:GetDragonHPRecovery(userData, offset)
	offset = offset or 0
	local level = userData.buildings.location_4.level
	return dragonEyrie[level + offset].hpRecoveryPerHour
end
function UtilsForDragon:GetDragonStatusDesc(dragon)
	return dragon.hp <= 0 and Localize.dragon_status.dead or Localize.dragon_status[dragon.status]
end
function UtilsForDragon:NeedWarning(dragon)
	local hpMax = self:GetDragonMaxHp(dragon)
	return math.ceil(dragon.hp/hpMax * 100) <= 10
end
local dragonStrengthTerrainAddPercent = GameDatas.PlayerInitData.intInit.dragonStrengthTerrainAddPercent.value
local AllianceMap_buff = GameDatas.AllianceMap.buff
function UtilsForDragon:GetDragonStrength(dragon)
	if dragon.level <= 0 then return 0 end
	local strength = dragonLevel[dragon.level].strength + dragonStar[dragon.star].initStrength
	local buff = self:GetDragonStrengthBuff(dragon)
	strength = strength + math.floor(strength * buff)

	for category,equipment in pairs(dragon.equipments) do
		if #equipment.name > 0 then
			local maxStar = DragonEquipments.equipments[equipment.name].maxStar
			local equipmentConfig = DragonEquipments[category][maxStar .. "_" .. equipment.star]
			local strengthAdd = equipmentConfig.strength
			strength = strength + strengthAdd
		end
	end
	return strength
end
function UtilsForDragon:GetDragonStrengthWithoutBuff(dragon)
	local strength = dragonLevel[dragon.level].strength + dragonStar[dragon.star].initStrength
	return strength
end
local terrainMap = {
    redDragon = "desert",
    greenDragon = "grassLand",
    blueDragon = "iceField"
}
function UtilsForDragon:GetDragonStrengthBuff(dragon)
	local terrainBuff = terrainMap[dragon.type] == terrain and (dragonStrengthTerrainAddPercent / 100) or 0
	local skillBuff = self:GetSkillEffect(self:GetSkillByName(dragon, 'dragonBreath'))
	local mapRoundBuff = 0
	if not Alliance_Manager:GetMyAlliance():IsDefault() then
		local round = DataUtils:getMapRoundByMapIndex(Alliance_Manager:GetMyAlliance().mapIndex)
		mapRoundBuff = (AllianceMap_buff[round].dragonStrengthAddPercent / 100)
	end
	return terrainBuff + skillBuff + mapRoundBuff
end
function UtilsForDragon:GetCanFightPowerfulDragonType(userData)
	local dragonWeight = 0
    local dragonType = ""
    for k,dragon in pairs(userData.dragons) do
        if (dragon.status == "free" or dragon.status == "defence") 
        	and dragon.hp > 0 then
        	local weight = self:GetDragonWeight(dragon)
            if weight > dragonWeight then
                dragonWeight = weight
                dragonType = k
            end
        end
    end
    return dragonType
end
function UtilsForDragon:GetPowerfulDragonType(userData)
    local dragonWeight = 0
    local dragonType = ""
    for k,dragon in pairs(userData.dragons) do
        local weight = self:GetDragonWeight(dragon)
    	if weight > dragonWeight then
            dragonWeight = weight
            dragonType = k
        end
    end
    return dragonType
end
function UtilsForDragon:GetDragonWeight(dragon)
	if dragon.star <= 0 then
		return 0
	else 
		return self:GetDragonStrength(dragon)
	end
end
local equipments = DragonEquipments.equipments
function UtilsForDragon:GetEquipAttributes(equip, part)
	local maxStar = equipments[equip.name].maxStar
  	local config = self:GetEquipStarConfig(equip, part)
  	return {
		strength = config.strength,
		vitality = config.vitality * 4,
		leadership = config.leadership * citizenPerLeadership,
  	}
end
local equipments = DragonEquipments.equipments
function UtilsForDragon:GetEquipStarConfig(equip, part, offset)
	local maxStar = equipments[equip.name].maxStar
	local star = (equip.star or 0) + (offset or 0)
	return DragonEquipments[part][maxStar .. "_" .. star]
end
local equipmentBuff = GameDatas.DragonEquipments.equipmentBuff
function UtilsForDragon:GetDragonEquipBuff(equip)
	local r = {}
  	for _,v in ipairs(equip.buffs) do
    	table.insert(r, {v, equipmentBuff[v].buffEffect})
  	end
  return r
end
local equipments = DragonEquipments.equipments
function UtilsForDragon:IsAllEquipmentsReachMaxStar(dragon)
	for category,equipment in pairs(dragon.equipments) do
		if #equipment.name > 0 then
			if equipment.star ~= equipments[equipment.name].maxStar then
				return false
			end
		else
			local unlocked = DragonEquipments[category][dragon.star.."_"..0]
			if unlocked then
				return false
			end
		end
	end
	return true
end
function UtilsForDragon:GetCanEquipedByDragonPart(dragon, part)
	for k,v in pairs(equipments) do
		if dragon.star == v.maxStar and dragon.type == v.usedFor and string.find(v.category, part) then
			return v
		end
	end
end
function UtilsForDragon:GetPartByEquipment(equipment)
	return string.split(equipments[equipment.name].category, ",")[1]
end
function UtilsForDragon:GetConfigByName(equipmentName)
	return equipments[equipmentName]
end
function UtilsForDragon:IsPartUnLocked(dragon, part)
	return not not DragonEquipments[part][dragon.star.."_"..0]
end
function UtilsForDragon:GetEquipmentMaxStar(equipment)
	return equipments[equipment.name].maxStar
end
function UtilsForDragon:GetDefenceDragon(userData)
    for i,v in ipairs(self:GetHatchedDragons(userData)) do
    	if v.status == 'defence' then
    		return v
    	end
    end
end
function UtilsForDragon:GetHatchedDragons(userData)
	local hatcheddragons = {}
    for k,v in pairs(userData.dragons) do
		if v.star > 0 then
			table.insert(hatcheddragons, v)
		end
	end
	return hatcheddragons
end
function UtilsForDragon:GetDragonAttributesMaxByStar(dragon, star)
	local starConfig = dragonStar[star]
	local config = dragonLevel[starConfig.levelMax]
	return {
		strength = config.strength,
		vitality = (config.vitality + starConfig.initVitality) * 4,
		leadership = (config.leadership + starConfig.initLeadership) * citizenPerLeadership
	}
end
function UtilsForDragon:GetDragonAttributesByLevel(dragon, level)
	local starConfig = dragonStar[dragon.star]
	local config = dragonLevel[level]
	return {
		strength = config.strength,
		vitality = (config.vitality + starConfig.initVitality) * 4,
		leadership = (config.leadership + starConfig.initLeadership) * citizenPerLeadership
	}
end




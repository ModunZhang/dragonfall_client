UtilsForFte = {}

function UtilsForFte:IsHatchedAnyDragons(userData)
    return #UtilsForDragon:GetHatchedDragons(userData) > 0
end
function UtilsForFte:IsStudyAnyDragonSkill(userData)
	for i,v in ipairs(UtilsForDragon:GetHatchedDragons(userData)) do
		if v.skills.skill_1.level > 0 then
			return true
		end
	end
	return false
end
function UtilsForFte:IsDefencedWithTroops(userData)
	if userData.countInfo.isFTEFinished then
		return true
	end
	return userData.defenceTroop and userData.defenceTroop ~= json.null
end


function UtilsForFte:ShouldFingerOnFree(userData)
	return UtilsForTask:NeedTips(userData) and
		   UtilsForBuilding:CouldFreeSpeedUpWithShortestBuildingEvent(userData)
end
function UtilsForFte:ShouldFingerOnTask(userData)
	if self:ShouldFingerOnFree(userData) then
		return false
	end
	return UtilsForTask:NeedTips(userData)
end
function UtilsForFte:CanUpgradeAnySkills(userData)
    local blood = userData.resources.blood
    for type,dragon in pairs(userData.dragons) do
        for _,skill in pairs(dragon.skills) do
            if skill.level > 0 then
                if blood >= UtilsForDragon:GetBloodCost(skill, 1) then
                    return true
                end
            end
        end
    end
    return false
end
local equipments = GameDatas.DragonEquipments.equipments
function UtilsForFte:CanMakeAnyEquipment(userData)
    for i,v in ipairs(UtilsForBuilding:GetBuildingsBy(userData, "blackSmith", 1)) do
        local level = v.level
        for k,config in pairs(equipments) do
            if (config.maxStar-1) * 10 <= level then
                local canmake = true
                for i,m in ipairs(string.split(config.materials, ",")) do
                    local type, num = unpack(string.split(m, ":"))
                    num = tonumber(num)

                    if userData.dragonMaterials[type] < num then
                        canmake = false
                    end
                end
                if canmake then
                    return true
                end
            end
        end
    end
    return false
end
function UtilsForFte:CanMakeAnyMaterials(userData)
    return #userData.materialEvents == 0 and
            #UtilsForBuilding:GetBuildingsBy(userData, "toolShop", 1) > 0
end
function UtilsForFte:CanStartDailyQuest(userData)
    local unlock = #UtilsForBuilding:GetBuildingsBy(userData, "townHall", 1) > 0
    return #userData.dailyQuestEvents == 0
        and not userData:IsFinishedAllDailyQuests()
        and unlock
end
function UtilsForFte:CanUpgradeMilitaryTechs(userData)
    local materials = userData.technologyMaterials
    for name,tech in pairs(userData.militaryTechs) do
        local config = UtilsForTech:GetTechInfo(name, tech.level + 1)
        if #UtilsForBuilding:GetBuildingsBy(userData, tech.building, 1) > 0 then
            if materials.trainingFigure >= config.trainingFigure and
                materials.bowTarget >= config.bowTarget and
                materials.saddle >= config.saddle and
                materials.ironPart >= config.ironPart then
                return tech.building
            end
        end
    end
    return false
end
function UtilsForFte:HasAnyShrineEvents()
    return  not Alliance_Manager:GetMyAlliance():IsDefault()
            and Alliance_Manager:GetMyAlliance().shrineEvents
            and #Alliance_Manager:GetMyAlliance().shrineEvents > 0
end
function UtilsForFte:IsPromoteAny(userData)
    for k,v in pairs(userData.soldierStars) do
        if v > 1 then
            return true
        end
    end

    return #userData.soldierStarEvents > 0
end
function UtilsForFte:IsMakeAnyEquip(userData)
    for k,dragon in pairs(userData.dragons) do
        if dragon.star > 1 then
            return true
        end
        for k,v in pairs(dragon.equipments) do
            if #v.name > 0 then
                return true
            end
        end
    end
    for k,v in pairs(userData.dragonEquipments) do
        if v > 0 then
            return true
        end
    end

    return #userData.dragonEquipmentEvents > 0
end
function UtilsForFte:IsMakeAnyMaterial(userData)
    for k,v in pairs(userData.buildingMaterials) do
        if v > 0 then
            return true
        end
    end
    for k,v in pairs(userData.technologyMaterials) do
        if v > 0 then
            return true
        end
    end
    return #userData.materialEvents > 0
end
local tech_building_name = {
    "trainingGround",
    "stable",
    "hunterHall",
    "workshop",
}
function UtilsForFte:IsUpgradeAnyMilitaryTech(userData)
    for location = 17, 20 do
        local type = userData.buildings[string.format("location_%d", location)].type
        if userData:GetTechPoints(type) > 0 then
            return true
        end
    end
    return #userData.militaryTechEvents > 0
end
function UtilsForFte:IsPassedBuildingTips(userData, type)
    local ispassed = app:GetGameDefautlt():IsPassedTriggerTips(type)
    if ispassed or #UtilsForBuilding:GetBuildingsBy(userData, type, 2) > 0 then
        return true
    else
        return false
    end
end
function UtilsForFte:NeedTriggerTips(userData)
    local time = app.timer:GetServerTime()
    local needTips = ((time - userData.countInfo.registerTime/1000) < 7 * 24 * 60 * 60)
    return not UtilsForTask:NeedTips(userData) and needTips and userData.countInfo.isFTEFinished
end

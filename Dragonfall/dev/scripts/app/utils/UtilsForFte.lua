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
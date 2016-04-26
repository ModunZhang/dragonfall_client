UtilsForFte = {}

function UtilsForFte:IsHatedAnyDragon(userData)
    return #UtilsForDragon:GetHatedDragons(userData) > 0
end
function UtilsForFte:IsStudyAnyDragonSkill(userData)
	for i,v in ipairs(UtilsForDragon:GetHatedDragons(userData)) do
		if v.skills.skill_1.level > 0 then
			return true
		end
	end
	return false
end
function UtilsForFte:IsDefencedWithTroops(userData)
	return userData.defenceTroop and userData.defenceTroop ~= json.null and userData.countInfo.isFTEFinished
end
UtilsForDragon = {}

function UtilsForDragon:GetDefenceDragon(userData)
    for i,v in ipairs(self:GetHatedDragons(userData)) do
    	if v.status == 'defence' then
    		return v
    	end
    end
end
function UtilsForDragon:GetCanHatedDragon(userData)
	for k,v in pairs(userData.dragons) do
		if v.star <= 0 then
			return v
		end
	end
end
function UtilsForDragon:IsDragonAllHated(userData)
    local max 	= 0
	local count = 0
	for k,v in pairs(userData.dragons) do
		max = max + 1
		if v.star > 0 then
			count = count + 1
		end
	end
	return max == count
end
function UtilsForDragon:GetHatedDragons(userData)
	local hateddragons = {}
    for k,v in pairs(userData.dragons) do
		if v.star > 0 then
			table.insert(hateddragons, v)
		end
	end
	return hateddragons
end
UtilsForDragon = {}


function UtilsForDragon:GetCanHatedDragon(userData)
	for k,v in pairs(userData.dragons) do
		if v.star <= 0 then
			return v
		end
	end
end
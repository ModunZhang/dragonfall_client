local GameUIReplay = UIKit:createUIClass('GameUIReplay')



local soldiers = {
    "swordsman_1",
    "swordsman_2",
    "swordsman_3",
    "ranger_1",
    "ranger_2",
    "ranger_3",
    "lancer_1",
    "lancer_2",
    "lancer_3",
    "catapult_1",
    "catapult_2",
    "catapult_3",
    "sentinel_1",
    "sentinel_2",
    "sentinel_3",
    "crossbowman_1",
    "crossbowman_2",
    "crossbowman_3",
    "horseArcher_1",
    "horseArcher_2",
    "horseArcher_3",
    "ballista_1",
    "ballista_2",
    "ballista_3",
    "skeletonWarrior",
    "skeletonArcher",
    "deathKnight",
    "meatWagon",
}
local dragonTypes = {
    "redDragon",
    "blueDragon",
    "greenDragon",
}
local isTroops = function(troops)
    assert(troops)
    return troops.IsTroops
end
local isDragon = function(dragon)
    assert(dragon)
    return dragon.IsDragon
end

function GameUIReplay:ctor()
	self.speed = 3
    cc.LayerGradient:create(cc.c4b(0,255,0,255), cc.c4b(255,0,0,255), cc.p(1, 1)):addTo(self)
    self:Setup()
    self:Start()
end
function GameUIReplay:MovingTimeForAttack()
    return 2
end
function GameUIReplay:MoveSpeed()
    return 100
end
function GameUIReplay:LeftPosition()
    return 150
end
function GameUIReplay:RightPosition()
    return display.width - 150
end
function GameUIReplay:Setup()
	self.isFightWall = false
	self.fightWallCount = 0

    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    self.dragonLeft = UIKit:CreateSkillDragon(dragonTypes[math.random(#dragonTypes)], 90, self):addTo(self):pos(-400, display.cy)
    self.dragonRight = UIKit:CreateSkillDragon(dragonTypes[math.random(#dragonTypes)], 360, self):addTo(self):pos(display.width + 400, display.cy)

    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    self.leftTroops = {}
    self.leftTroops[1] = UIKit:CreateFightTroops(soldiers[math.random(#soldiers)], {isleft = true,},self):addTo(self)
    self.leftTroops[2] = UIKit:CreateFightTroops(soldiers[math.random(#soldiers)], {isleft = true,},self):addTo(self)
    self.leftTroops[3] = UIKit:CreateFightTroops(soldiers[math.random(#soldiers)], {isleft = true,},self):addTo(self)
    self.leftTroops[4] = UIKit:CreateFightTroops(soldiers[math.random(#soldiers)], {isleft = true,},self):addTo(self)
    self.leftTroops[5] = UIKit:CreateFightTroops(soldiers[math.random(#soldiers)], {isleft = true,},self):addTo(self)
    self.leftTroops[6] = UIKit:CreateFightTroops(soldiers[math.random(#soldiers)], {isleft = true,},self):addTo(self)
    for i,v in ipairs(self.leftTroops) do
        v:pos(self:LeftPosition(), display.height - 200 - (i-1) * 100):FaceCorrect():Idle()
    end

    self.rightTroops = {}
    self.rightTroops[1] = UIKit:CreateFightTroops(soldiers[math.random(#soldiers)], {isleft = false,},self):addTo(self)
    self.rightTroops[2] = UIKit:CreateFightTroops(soldiers[math.random(#soldiers)], {isleft = false,},self):addTo(self)
    self.rightTroops[3] = UIKit:CreateFightTroops(soldiers[math.random(#soldiers)], {isleft = false,},self):addTo(self)
    self.rightTroops[4] = UIKit:CreateFightTroops(soldiers[math.random(#soldiers)], {isleft = false,},self):addTo(self)
    self.rightTroops[5] = UIKit:CreateFightTroops(soldiers[math.random(#soldiers)], {isleft = false,},self):addTo(self)
    -- self.rightTroops[6] = UIKit:CreateFightTroops(soldiers[math.random(#soldiers)], {isleft = false,},self):addTo(self)
    for i,v in ipairs(self.rightTroops) do
        v:pos(self:RightPosition(), display.height - 200 - (i-1) * 100):FaceCorrect():Idle()
    end
    -- self.rightTroops[1] = UIKit:CreateFightTroops("wall", {isleft = false,},self)
    --                     :addTo(self):pos(self:RightPosition() + 300, display.cy):FaceCorrect()
end
function GameUIReplay:Start()
    self:OnStartRound()
end
function GameUIReplay:OnStartRound()
    if self.rightTroops[1]:IsWall() then
        self:OnStartWallBattle()
    else
        self:OnStartSoldierBattle()
    end
end
function GameUIReplay:OnFinishRound()
    for k,v in ipairs(self.leftTroops) do
        v.isfighted = false
        v.effectsNode:removeAllChildren()
    end
    for k,v in ipairs(self.rightTroops) do
        v.isfighted = false
        v.effectsNode:removeAllChildren()
    end
	if #self.leftTroops > 0 and #self.rightTroops > 0 then
		self:OnStartRound()
    elseif #self.leftTroops > 0 and not self.isFightWall then
        self.rightTroops[1] = UIKit:CreateFightTroops("wall", {isleft = false,},self)
                        :addTo(self):pos(self:RightPosition() + 300, display.cy):FaceCorrect()
        self:OnStartMoveToWall()
	end
end
function GameUIReplay:OnStartWallBattle()
	self:OnStartMoveToWall()
end
-- 打城墙
function GameUIReplay:OnStartMoveToWall()
    local indexes = {1,2,3,4,5,6}
    local flip = false
    while(#indexes > #self.leftTroops) do
        if flip then
            table.remove(indexes, 1)
        else
            table.remove(indexes, #indexes)
        end
        flip = not flip
    end
    for i,v in pairs(self.leftTroops) do
        local tx, ty = self:LeftPosition(), display.height - 200 - (indexes[i]-1) * 100
        v:Move(tx, ty, 2).effectsNode:removeAllChildren()
    end
    self.rightTroops[1]:Move(self:RightPosition() + 300 - 180 , display.cy, 2, function(isend)
        if not isend then
            for i,v in pairs(self.leftTroops) do
                v:Idle()
            end
        else
            self:OnFinishMoveToWall()
        end
    end)
end
function GameUIReplay:OnFinishMoveToWall()
    self.isFightWall = true
    local wall = self.rightTroops[1]
    local point = cc.p(wall:getPosition())
    local wp = wall:getParent():convertToWorldSpace(point)
    wp.x = wp.x - 100
    local move_count = 0
    local need_move = false
    local melee_count = 0
    for i,v in pairs(self.leftTroops) do
        if v:IsMelee() then
            melee_count = melee_count + 1
            need_move = true
            local np = v:getParent():convertToNodeSpace(wp)
            local attack_x, attack_y = v:getPosition()
            if np.x ~= attack_x then
                v:Move(np.x, attack_y, 2, function(isend)
                    if isend then
                        move_count = move_count + 1
                        if move_count == melee_count then
                            self:OnAttackWall()
                        end
                    end
                end)
            end
        end
    end
    if not need_move then
        self:OnAttackWall()
    end
end
function GameUIReplay:OnAttackWall()
	self.hurtCount = 0
    for i,v in ipairs(self.leftTroops) do
        self:OnAttacking(v, self.rightTroops[1])
    end
end
function GameUIReplay:OnStartSoldierBattle()
    -- 本轮是士兵对打
    self.dualCount = 0
    local need_move = false
    local need_move_count = 0
    local move_count = 0
    for i,v in ipairs(self.leftTroops) do
        local tx, ty = self:LeftPosition(), display.height - 200 - (i-1) * 100
        local x,y = v:getPosition()
        if (x ~= tx or y ~= ty) and not v:IsWall() then
            need_move_count = need_move_count + 1
            need_move = true
            local move_time = math.abs(ty - y)/self:MoveSpeed()
            v:Move(tx, ty, move_time, function(isend)
                if isend then
                    move_count = move_count + 1
                    if move_count == need_move_count then
                        self:OnFinishAdjustPosition()
                    end
                end
            end)
        end
    end
    for i,v in ipairs(self.rightTroops) do
        local tx, ty = self:RightPosition(), display.height - 200 - (i-1) * 100
        local x,y = v:getPosition()
        if (x ~= tx or y ~= ty) and not v:IsWall() then
            need_move_count = need_move_count + 1
            need_move = true
            local move_time = math.abs(ty - y)/self:MoveSpeed()
            v:Move(tx, ty, move_time, function(isend)
                if isend then
                    move_count = move_count + 1
                    if move_count == need_move_count then
                        self:OnFinishAdjustPosition()
                    end
                end
            end)
        end
    end
    if not need_move then
        self:OnFinishAdjustPosition()
    end
end
function GameUIReplay:OnFinishAdjustPosition()
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local select_action = math.random(3)
    if true then
        -- if select_action == 1 then -- only left
        --     self:OnLeftDragonAttackTroops()
        -- elseif select_action == 2 then -- only right
        --     self:OnRightDragonAttackTroops()
        -- elseif select_action == 3 then -- both
        self:OnBothDragonAttackTroops()
        -- end
    else
        self:OnStartNewDuals()
    end
end
function GameUIReplay:OnLeftDragonAttackTroops()
    self.dragonLeft:pos(-400, display.cy)
        :Move(display.width + 400, display.cy, 2, function(isend)
            if isend then
                self:OnStartNewDuals()
            else
                self:OnDragonAttackTroops(self.dragonLeft,self.rightTroops)
            end
        end)
end
function GameUIReplay:OnRightDragonAttackTroops()
    self.dragonRight:pos(display.width + 400, display.cy)
        :Move(-400, display.cy, 2, function(isend)
            if isend then
                self:OnStartNewDuals()
            else
                self:OnDragonAttackTroops(dragonRight,self.leftTroops)
            end
        end)
end
function GameUIReplay:OnBothDragonAttackTroops()
    self.dragonLeft:pos(-400, display.cy)
        :Move(display.width + 400, display.cy, 2, function(isend)
            if isend then
                self.dragonRight:pos(display.width + 400, display.cy)
                    :Move(-400, display.cy, 2, function(isend)
                        if isend then
                            self:OnStartNewDuals()
                        else
                            self:OnDragonAttackTroops(self.dragonRight,self.leftTroops)
                        end
                    end)
            else
                self:OnDragonAttackTroops(self.dragonLeft,self.rightTroops)
            end
        end)
end
function GameUIReplay:OnDragonAttackTroops(dragon, allTroops)
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    if dragon.dragonType == "redDragon" then
        local troops = allTroops[math.random(#allTroops)]
        UIKit:ttfLabel({
            text = "红龙特效",
            size = 40,
            color = 0xffedae,
        }):addTo(troops.effectsNode, 10, 111):align(display.CENTER, 0, 50)
    elseif dragon.dragonType == "blueDragon" then
        local v1, v2, v3 = math.random(#allTroops), math.random(#allTroops), math.random(#allTroops)
        for i,v in ipairs({v1, v2, v3}) do
            UIKit:ttfLabel({
                text = "蓝龙特效",
                size = 40,
                color = 0xffedae,
            }):addTo(allTroops[v].effectsNode, 10, 111):align(display.CENTER, 0, 50)
        end
    elseif dragon.dragonType == "greenDragon" then
        for i,v in ipairs(allTroops) do
            UIKit:ttfLabel({
                text = "绿龙特效",
                size = 40,
                color = 0xffedae,
            }):addTo(v.effectsNode, 10, 111):align(display.CENTER, 0, 50)
        end
    end
end
function GameUIReplay:OnStartNewDuals()
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local index = math.random(10)
    if index > 6 then
        self:OnStartDual(self.leftTroops[1], self.rightTroops[1])
    else
        self:OnStartDual(self.rightTroops[1], self.leftTroops[1])
    end
end
function GameUIReplay:OnFinishDual()
	local l,r
	for i,v in ipairs(self.leftTroops) do
		if not v.isfighted then
			l = v
			break
		end
	end
	for i,v in ipairs(self.rightTroops) do
		if not v.isfighted then
			r = v
			break
		end
	end
	if l and r then
        math.randomseed(tostring(os.time()):reverse():sub(1, 6))
        local index = math.random(10)
        if index > 6 then
            self:OnStartDual(l, r)
        else
            self:OnStartDual(r, l)
        end
	else
		self:OnFinishRound()
	end
end
function GameUIReplay:OnStartDual(attackTroops, defenceTroops)
	self.hurtCount = 0
	self.dualCount = self.dualCount + 1
    self:OnFight(attackTroops, defenceTroops)
end
function GameUIReplay:OnAttackFinished(attackTroops)
	assert(attackTroops.properties.target)
    if self.isFightWall then
        self.fightWallCount = self.fightWallCount + 1
    end
    attackTroops:Idle()
    
    if isTroops(attackTroops.properties.target) then
        if not self.isFightWall or self.fightWallCount == 1 then
            attackTroops.properties.target:Hurt()
        end
    else
        for _,v in pairs(attackTroops.properties.target) do
            v:Hurt()
        end
    end
	attackTroops.properties.target = nil
end
function GameUIReplay:OnHurtFinished(hurtTroops)
	self.hurtCount = self.hurtCount + 1
	hurtTroops:Idle()

    if not self.isFightWall then
		if self.hurtCount == 1 then -- 反击
            hurtTroops:Hold(0.2, function()
                self:OnFight(hurtTroops, hurtTroops.properties.target)
            end)
    	else -- 死亡
    		local attackTroops = hurtTroops.properties.target
    		if attackTroops:IsMelee() and self:IsMoved(attackTroops) then
    			hurtTroops:Death(function()
                    self:RemoveDeathTroops(hurtTroops)
                end)
                local x,y = self:GetOriginPoint(attackTroops)
                attackTroops:Return(x,y, self:MovingTimeForAttack(), function()
                    attackTroops:FaceCorrect()
                    self:OnFinishDual()
                end)
    		else
    			hurtTroops:Death(function()
					self:RemoveDeathTroops(hurtTroops)
					self:OnFinishDual()
				end)
    		end
			attackTroops.properties.target = nil
			hurtTroops.properties.target = nil
		end
    else
        if hurtTroops:IsWall() then
            self:OnAttacking(hurtTroops, self.leftTroops)
        end
        if self.hurtCount == #self.leftTroops then
            math.randomseed(tostring(os.time()):reverse():sub(1, 6))
            for _,v in pairs(self.leftTroops) do
                if math.random(2) % 2 == 0 then
                    v:Death(function()
                        self:RemoveDeathTroops(v)
                    end)
                end
            end
            math.randomseed(tostring(os.time()):reverse():sub(1, 6))
            if math.random(2) % 2 == 0 then
                self.rightTroops[1]:Death(function()
                    self:RemoveDeathTroops(self.rightTroops[1])
                end)
            end
        end
    end
end
function GameUIReplay:OnFight(attackTroops, defenceTroops)
	if attackTroops:IsMelee() then
		local point = cc.p(defenceTroops:getPosition())
        local wp = defenceTroops:getParent():convertToWorldSpace(point)
        if attackTroops:IsLeft() then
            wp.x = wp.x - 100
        else
            wp.x = wp.x + 100
        end
        local np = attackTroops:getParent():convertToNodeSpace(wp)
        local attack_x, attack_y = attackTroops:getPosition()
        if np.x ~= attack_x or attack_y ~= np.y then
        	attackTroops:Move(np.x, np.y, self:MovingTimeForAttack(), function(isend)
                if isend then
                    self:OnAttacking(attackTroops, defenceTroops)
                end
            end)
            return
        end
    end
    self:OnAttacking(attackTroops, defenceTroops)
end
function GameUIReplay:OnAttacking(attackTroops, defenceTroops)
    attackTroops.isfighted = true
    attackTroops.properties.target = defenceTroops
    if isTroops(defenceTroops) then
        defenceTroops.properties.target = attackTroops
    else
        for _,v in pairs(defenceTroops) do
            v.properties.target = attackTroops
        end
    end
    attackTroops:Attack(defenceTroops)
end
function GameUIReplay:IsMoved(troops)
    local tx,ty = self:GetOriginPoint(troops)
    local x,y = troops:getPosition()
    return x ~= tx or y ~= ty
end
function GameUIReplay:GetOriginPoint(troops)
    local pos_y = display.height - 200 - (self.dualCount-1) * 100
    local x,y = troops:IsLeft() and self:LeftPosition() or self:RightPosition(), pos_y
    return x, y
end
function GameUIReplay:RemoveDeathTroops(deathTroops)
	if deathTroops:IsLeft() then
		for i,v in ipairs(self.leftTroops or {}) do
			if deathTroops == v then
				table.remove(self.leftTroops, i)
				break
			end
		end
	else
		for i,v in ipairs(self.rightTroops or {}) do
			if deathTroops == v then
				table.remove(self.rightTroops, i)
				break
			end
		end
	end
end
function GameUIReplay:Stop()

end
function GameUIReplay:CleanUp()

end
function GameUIReplay:Speed()
    return 4
end

return GameUIReplay


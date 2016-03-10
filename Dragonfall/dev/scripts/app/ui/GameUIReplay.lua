local window = import("..utils.window")
local promise = import("..utils.promise")
local Localize = import("..utils.Localize")
local cocos_promise = import("..utils.cocos_promise")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local GameUIReplay = UIKit:createUIClass('GameUIReplay')

userdata = json.null
local report = {
        ["attackPlayerData"] = {
            ["alliance"] = {
                ["name"] = "Crius and Hebe",
                ["id"] = "E1XMoXLne",
                ["mapIndex"] = 294,
                ["flag"] = "2,4,5,9,4",
                ["tag"] = "CnH",
            }
,
            ["name"] = "ewr",
            ["fightWithDefenceTroop"] = {
                ["dragon"] = {
                    ["type"] = "greenDragon",
                    ["hpDecreased"] = 16,
                    ["level"] = 3,
                    ["hp"] = 180,
                    ["expAdd"] = 86,
                }
,
                ["soldiers"] = {
                    [1] = {
                        ["count"] = 60,
                        ["star"] = 1,
                        ["countDecreased"] = 5,
                        ["name"] = "sentinel_3",
                    }
,
                    [2] = {
                        ["count"] = 30,
                        ["star"] = 1,
                        ["countDecreased"] = 4,
                        ["name"] = "horseArcher_3",
                    }
,
                    [3] = {
                        ["count"] = 30,
                        ["star"] = 1,
                        ["countDecreased"] = 3,
                        ["name"] = "lancer_3",
                    }
,
                    [4] = {
                        ["count"] = 60,
                        ["star"] = 1,
                        ["countDecreased"] = 3,
                        ["name"] = "swordsman_3",
                    }
,
                    [5] = {
                        ["count"] = 30,
                        ["star"] = 1,
                        ["countDecreased"] = 3,
                        ["name"] = "ballista_3",
                    }
,
                    [6] = {
                        ["count"] = 30,
                        ["star"] = 1,
                        ["countDecreased"] = 2,
                        ["name"] = "catapult_3",
                    }
,
                }
,
            }
,
            ["id"] = "VJPCpM83g",
            ["rewards"] = {
                [1] = {
                    ["type"] = "resources",
                    ["name"] = "blood",
                    ["count"] = 309,
                }
,
                [2] = {
                    ["type"] = "resources",
                    ["name"] = "coin",
                    ["count"] = 415,
                }
,
                [3] = {
                    ["type"] = "resources",
                    ["name"] = "wood",
                    ["count"] = 4800,
                }
,
                [4] = {
                    ["type"] = "resources",
                    ["name"] = "stone",
                    ["count"] = 4783,
                }
,
                [5] = {
                    ["type"] = "resources",
                    ["name"] = "iron",
                    ["count"] = 4783,
                }
,
                [6] = {
                    ["type"] = "resources",
                    ["name"] = "food",
                    ["count"] = 0,
                }
,
                [7] = {
                    ["type"] = "dragonMaterials",
                    ["name"] = "redSoul_2",
                    ["count"] = 3,
                }
,
            }
,
            ["icon"] = 4,
            ["fightWithDefenceWall"] = {
                ["soldiers"] = {
                    [1] = {
                        ["count"] = 55,
                        ["star"] = 1,
                        ["countDecreased"] = 1,
                        ["name"] = "sentinel_3",
                    }
,
                    [2] = {
                        ["count"] = 26,
                        ["star"] = 1,
                        ["countDecreased"] = 1,
                        ["name"] = "horseArcher_3",
                    }
,
                    [3] = {
                        ["count"] = 27,
                        ["star"] = 1,
                        ["countDecreased"] = 1,
                        ["name"] = "lancer_3",
                    }
,
                    [4] = {
                        ["count"] = 57,
                        ["star"] = 1,
                        ["countDecreased"] = 1,
                        ["name"] = "swordsman_3",
                    }
,
                    [5] = {
                        ["count"] = 27,
                        ["star"] = 1,
                        ["countDecreased"] = 1,
                        ["name"] = "ballista_3",
                    }
,
                    [6] = {
                        ["count"] = 28,
                        ["star"] = 1,
                        ["countDecreased"] = 1,
                        ["name"] = "catapult_3",
                    }
,
                }
,
            }
,
        }
,
        ["attackTarget"] = {
            ["alliance"] = {
                ["name"] = "Freyr",
                ["id"] = "412b0DLnl",
                ["mapIndex"] = 252,
                ["flag"] = "2,11,7,19,6",
                ["tag"] = "Fre",
            }
,
            ["name"] = "ppo",
            ["terrain"] = "desert",
            ["id"] = "4yVyRvLhg",
            ["location"] = {
                ["y"] = 9,
                ["x"] = 15,
            }
,
        }
,
        ["defencePlayerData"] = {
            ["id"] = "4yVyRvLhg",
            ["rewards"] = {
                [1] = {
                    ["type"] = "resources",
                    ["name"] = "blood",
                    ["count"] = 320,
                }
,
                [2] = {
                    ["type"] = "resources",
                    ["name"] = "coin",
                    ["count"] = -415,
                }
,
                [3] = {
                    ["type"] = "resources",
                    ["name"] = "wood",
                    ["count"] = -4800,
                }
,
                [4] = {
                    ["type"] = "resources",
                    ["name"] = "stone",
                    ["count"] = -4783,
                }
,
                [5] = {
                    ["type"] = "resources",
                    ["name"] = "iron",
                    ["count"] = -4783,
                }
,
                [6] = {
                    ["type"] = "resources",
                    ["name"] = "food",
                    ["count"] = 0,
                }
,
                [7] = {
                    ["type"] = "dragonMaterials",
                    ["name"] = "ingo_2",
                    ["count"] = 1,
                }
,
            }
,
            ["soldiers"] = {
                [1] = {
                    ["count"] = 46,
                    ["star"] = 1,
                    ["countDecreased"] = 7,
                    ["name"] = "sentinel_3",
                }
,
                [2] = {
                    ["count"] = 23,
                    ["star"] = 1,
                    ["countDecreased"] = 5,
                    ["name"] = "horseArcher_3",
                }
,
                [3] = {
                    ["count"] = 23,
                    ["star"] = 1,
                    ["countDecreased"] = 4,
                    ["name"] = "lancer_3",
                }
,
                [4] = {
                    ["count"] = 46,
                    ["star"] = 1,
                    ["countDecreased"] = 4,
                    ["name"] = "swordsman_3",
                }
,
                [5] = {
                    ["count"] = 23,
                    ["star"] = 1,
                    ["countDecreased"] = 4,
                    ["name"] = "ballista_3",
                }
,
                [6] = {
                    ["count"] = 23,
                    ["star"] = 1,
                    ["countDecreased"] = 3,
                    ["name"] = "catapult_3",
                }
,
            }
,
            ["dragon"] = {
                ["type"] = "greenDragon",
                ["hpDecreased"] = 27,
                ["level"] = 2,
                ["hp"] = 148,
                ["expAdd"] = 64,
            }
,
            ["alliance"] = {
                ["name"] = "Freyr",
                ["id"] = "412b0DLnl",
                ["mapIndex"] = 252,
                ["flag"] = "2,11,7,19,6",
                ["tag"] = "Fre",
            }
,
            ["name"] = "ppo",
            ["masterOfDefender"] = false,
            ["wall"] = {
                ["hp"] = 124,
                ["hpDecreased"] = 116,
            }
,
            ["icon"] = 2,
        }
,
        ["fightWithDefencePlayerReports"] = {
            ["soldierRoundDatas"] = {
                [1] = {
                    ["attackResults"] = {
                        [1] = {
                            ["soldierName"] = "sentinel_3",
                            ["soldierWoundedCount"] = 2,
                            ["soldierStar"] = 1,
                            ["isWin"] = true,
                            ["soldierDamagedCount"] = 5,
                            ["soldierCount"] = 60,
                        }
,
                        [2] = {
                            ["soldierName"] = "horseArcher_3",
                            ["soldierWoundedCount"] = 1,
                            ["soldierStar"] = 1,
                            ["isWin"] = true,
                            ["soldierDamagedCount"] = 4,
                            ["soldierCount"] = 30,
                        }
,
                        [3] = {
                            ["soldierName"] = "lancer_3",
                            ["soldierWoundedCount"] = 1,
                            ["soldierStar"] = 1,
                            ["isWin"] = true,
                            ["soldierDamagedCount"] = 3,
                            ["soldierCount"] = 30,
                        }
,
                        [4] = {
                            ["soldierName"] = "swordsman_3",
                            ["soldierWoundedCount"] = 1,
                            ["soldierStar"] = 1,
                            ["isWin"] = true,
                            ["soldierDamagedCount"] = 3,
                            ["soldierCount"] = 60,
                        }
,
                        [5] = {
                            ["soldierName"] = "ballista_3",
                            ["soldierWoundedCount"] = 1,
                            ["soldierStar"] = 1,
                            ["isWin"] = true,
                            ["soldierDamagedCount"] = 3,
                            ["soldierCount"] = 30,
                        }
,
                        [6] = {
                            ["soldierName"] = "catapult_3",
                            ["soldierWoundedCount"] = 0,
                            ["soldierStar"] = 1,
                            ["isWin"] = true,
                            ["soldierDamagedCount"] = 2,
                            ["soldierCount"] = 30,
                        }
,
                    }
,
                    ["defenceResults"] = {
                        [1] = {
                            ["soldierName"] = "sentinel_3",
                            ["soldierWoundedCount"] = 2,
                            ["soldierStar"] = 1,
                            ["isWin"] = false,
                            ["soldierDamagedCount"] = 7,
                            ["soldierCount"] = 46,
                        }
,
                        [2] = {
                            ["soldierName"] = "horseArcher_3",
                            ["soldierWoundedCount"] = 1,
                            ["soldierStar"] = 1,
                            ["isWin"] = false,
                            ["soldierDamagedCount"] = 5,
                            ["soldierCount"] = 23,
                        }
,
                        [3] = {
                            ["soldierName"] = "lancer_3",
                            ["soldierWoundedCount"] = 1,
                            ["soldierStar"] = 1,
                            ["isWin"] = false,
                            ["soldierDamagedCount"] = 4,
                            ["soldierCount"] = 23,
                        }
,
                        [4] = {
                            ["soldierName"] = "swordsman_3",
                            ["soldierWoundedCount"] = 1,
                            ["soldierStar"] = 1,
                            ["isWin"] = false,
                            ["soldierDamagedCount"] = 4,
                            ["soldierCount"] = 46,
                        }
,
                        [5] = {
                            ["soldierName"] = "ballista_3",
                            ["soldierWoundedCount"] = 1,
                            ["soldierStar"] = 1,
                            ["isWin"] = false,
                            ["soldierDamagedCount"] = 4,
                            ["soldierCount"] = 23,
                        }
,
                        [6] = {
                            ["soldierName"] = "catapult_3",
                            ["soldierWoundedCount"] = 0,
                            ["soldierStar"] = 1,
                            ["isWin"] = false,
                            ["soldierDamagedCount"] = 3,
                            ["soldierCount"] = 23,
                        }
,
                    }
,
                }
,
            }
,
            ["defencePlayerDragonFightData"] = {
                ["hpMax"] = 148,
                ["type"] = "greenDragon",
                ["hpDecreased"] = 27,
                ["hp"] = 148,
                ["isWin"] = false,
            }
,
            ["attackPlayerWallRoundDatas"] = {
                [1] = {
                    ["soldierName"] = "sentinel_3",
                    ["soldierWoundedCount"] = 0,
                    ["soldierStar"] = 1,
                    ["isWin"] = false,
                    ["soldierDamagedCount"] = 1,
                    ["soldierCount"] = 55,
                }
,
                [2] = {
                    ["soldierName"] = "horseArcher_3",
                    ["soldierWoundedCount"] = 0,
                    ["soldierStar"] = 1,
                    ["isWin"] = false,
                    ["soldierDamagedCount"] = 1,
                    ["soldierCount"] = 26,
                }
,
                [3] = {
                    ["soldierName"] = "lancer_3",
                    ["soldierWoundedCount"] = 0,
                    ["soldierStar"] = 1,
                    ["isWin"] = false,
                    ["soldierDamagedCount"] = 1,
                    ["soldierCount"] = 27,
                }
,
                [4] = {
                    ["soldierName"] = "swordsman_3",
                    ["soldierWoundedCount"] = 0,
                    ["soldierStar"] = 1,
                    ["isWin"] = false,
                    ["soldierDamagedCount"] = 1,
                    ["soldierCount"] = 57,
                }
,
                [5] = {
                    ["soldierName"] = "ballista_3",
                    ["soldierWoundedCount"] = 0,
                    ["soldierStar"] = 1,
                    ["isWin"] = false,
                    ["soldierDamagedCount"] = 1,
                    ["soldierCount"] = 27,
                }
,
                [6] = {
                    ["soldierName"] = "catapult_3",
                    ["soldierWoundedCount"] = 0,
                    ["soldierStar"] = 1,
                    ["isWin"] = false,
                    ["soldierDamagedCount"] = 1,
                    ["soldierCount"] = 28,
                }
,
            }
,
            ["attackPlayerDragonFightData"] = {
                ["hpMax"] = 180,
                ["type"] = "greenDragon",
                ["hpDecreased"] = 16,
                ["hp"] = 180,
                ["isWin"] = true,
            }
,
            ["defencePlayerWallRoundDatas"] = {
                [1] = {
                    ["wallHp"] = 124,
                    ["wallDamagedHp"] = 28,
                    ["wallMaxHp"] = 124,
                    ["isWin"] = true,
                }
,
                [2] = {
                    ["wallHp"] = 96,
                    ["wallDamagedHp"] = 25,
                    ["wallMaxHp"] = 124,
                    ["isWin"] = true,
                }
,
                [3] = {
                    ["wallHp"] = 71,
                    ["wallDamagedHp"] = 20,
                    ["wallMaxHp"] = 124,
                    ["isWin"] = true,
                }
,
                [4] = {
                    ["wallHp"] = 51,
                    ["wallDamagedHp"] = 16,
                    ["wallMaxHp"] = 124,
                    ["isWin"] = true,
                }
,
                [5] = {
                    ["wallHp"] = 35,
                    ["wallDamagedHp"] = 16,
                    ["wallMaxHp"] = 124,
                    ["isWin"] = true,
                }
,
                [6] = {
                    ["wallHp"] = 19,
                    ["wallDamagedHp"] = 11,
                    ["wallMaxHp"] = 124,
                    ["isWin"] = true,
                }
,
            }
,
        }
,
    }

local DRAGON_HEAD = {
    blueDragon = "Dragon_blue_113x128.png",
    redDragon = "redDragon.png",
    greenDragon = "greenDragon.png"
}
local isTroops = function(troops)
    assert(troops)
    return troops.IsTroops
end
function GameUIReplay:ctor()
    self.speed = 1
    self:BuildUI()
    self:Setup()
    self:Start()
end
function GameUIReplay:RefreshSpeed()
    for i,v in ipairs(self.attackTroops or {}) do
        v:RefreshSpeed()
    end
    for i,v in ipairs(self.defenceTroops or {}) do
        v:RefreshSpeed()
    end
    if self.attackDragon then
        self.attackDragon:RefreshSpeed()
    end
    if self.defenceDragon then
        self.defenceDragon:RefreshSpeed()
    end
end
function GameUIReplay:MovingTimeForAttack()
    return 2
end
function GameUIReplay:MoveSpeed()
    return 100
end
function GameUIReplay:WallPosition()
    return self:DefencePosition() + 200, display.cy
end
function GameUIReplay:AttackPosition()
    return 100
end
function GameUIReplay:DefencePosition()
    return 608 - 100
end
function GameUIReplay:TopPositionByRow(row)
    return display.height - 250 - (row-1) * 100
end
function GameUIReplay:Setup()
    self.isFightWall = false
    self.roundCount = 1
    self.dualCount = 1
    self.hurtCount = 0
    self.fightWallCount = 0

    self.ui_map.attackName:setString(report.attackPlayerData.name)
    self.ui_map.defenceName:setString(report.defencePlayerData.name)

    if type(report.attackPlayerData.fightWithDefenceTroop) == "table" then
        local attackDragonType = report.attackPlayerData.fightWithDefenceTroop.dragon.type
        self.attackDragon = UIKit:CreateSkillDragon(attackDragonType, 90, self)
        :addTo(self.ui_map.dragonBattleNode):pos(-400, display.cy)

        self.ui_map.attackDragonLabel:setString(Localize.dragon[attackDragonType])
        self.ui_map.attackDragonIcon:setTexture(DRAGON_HEAD[attackDragonType])
    end
    if type(report.defencePlayerData.dragon) == "table" then
        local defenceDragonType = report.defencePlayerData.dragon.type
        self.defenceDragon = UIKit:CreateSkillDragon(defenceDragonType, 360, self)
        :addTo(self.ui_map.dragonBattleNode):pos(display.width + 400, display.cy)

        self.ui_map.defenceDragonLabel:setString(Localize.dragon[defenceDragonType])
        self.ui_map.defenceDragonIcon:setTexture(DRAGON_HEAD[defenceDragonType])
    end


    local attackSoldiers = {}
    self.attackTroops = {}
    if type(report.attackPlayerData.fightWithDefenceTroop) == "table" then
        attackSoldiers = report.attackPlayerData.fightWithDefenceTroop.soldiers
    elseif type(report.attackPlayerData.fightWithDefenceWall.soldiers) == "table" then
        attackSoldiers = report.attackPlayerData.fightWithDefenceWall.soldiers
    end
    for i,v in ipairs(attackSoldiers) do
            self.attackTroops[i] = UIKit:CreateFightTroops(v.name, {isleft = true,},self)
            :addTo(self.ui_map.soldierBattleNode) 
        end
    for i,v in ipairs(self.attackTroops) do
        v:pos(self:AttackPosition(), self:TopPositionByRow(i)):FaceCorrect():Idle()
    end


    self.defenceTroops = {}
    if type(report.defencePlayerData.soldiers) == "table" then
        for i,v in ipairs(report.defencePlayerData.soldiers) do
            self.defenceTroops[i] = UIKit:CreateFightTroops(v.name, {isleft = false,},self)
            :addTo(self.ui_map.soldierBattleNode) 
        end
        for i,v in ipairs(self.defenceTroops) do
            v:pos(self:DefencePosition(), self:TopPositionByRow(i)):FaceCorrect():Idle()
        end
    else
        self.defenceTroops[1] = UIKit:CreateFightTroops("wall", {isleft = false,},self)
                                :addTo(self.ui_map.soldierBattleNode)
                                :pos(self:WallPosition()):FaceCorrect()
    end
end
function GameUIReplay:Start()
    if type(report.attackPlayerData.fightWithDefenceTroop) ~= "table" then
        self:OnStartRound()
        return
    end
	local attackLevel = report.attackPlayerData.fightWithDefenceTroop.dragon.level
	local attackRoundDragon = report.fightWithDefencePlayerReports.attackPlayerDragonFightData

	local defenceLevel = report.defencePlayerData.dragon.level
	local defenceRoundDragon = report.fightWithDefencePlayerReports.defencePlayerDragonFightData

    local dragonBattle = UIKit:CreateDragonBattle({
        isleft = true,
        dragonType = attackRoundDragon.type,
        level = attackLevel,
        hpMax = attackRoundDragon.hpMax,
        hp = attackRoundDragon.hp,
        hpDecreased = attackRoundDragon.hpDecreased,
        isWin = true,
        increase = 40,
    }, {
        isleft = false,
        dragonType = defenceRoundDragon.type,
        level = defenceLevel,
        hpMax = defenceRoundDragon.hpMax,
        hp = defenceRoundDragon.hp,
        hpDecreased = defenceRoundDragon.hpDecreased,
        isWin = false,
        increase = 12,
    }, self):addTo(self):pos(display.cx, display.height - 300)
    self.dragonBattle = dragonBattle

    local time_per_hundred_percent = 1 / 100

    local attackToPercent = (attackRoundDragon.hp - attackRoundDragon.hpDecreased) / attackRoundDragon.hpMax * 100
    local attackStepPercent = attackToPercent - dragonBattle:GetAttackDragon():GetPercent()

    local defenceToPercent = (attackRoundDragon.hp - attackRoundDragon.hpDecreased) / attackRoundDragon.hpMax * 100
    local defenceStepPercent = defenceToPercent - dragonBattle:GetDefenceDragon():GetPercent()

    promise.all(dragonBattle:PromsieOfFight(),dragonBattle:PromiseOfVictory())
    :next(function()
        return promise.all(
        	dragonBattle:GetAttackDragon()
        	:PromiseOfProgressTo(time_per_hundred_percent * attackStepPercent, attackToPercent), 
        	dragonBattle:GetDefenceDragon()
        	:PromiseOfProgressTo(time_per_hundred_percent * defenceStepPercent, defenceToPercent))
    end)
    :next(function()
    	return dragonBattle:PromiseOfShowBuff()
    end)
    :next(function()
    	return promise.all(dragonBattle:PromsieOfHide(),dragonBattle:PromiseOfVictoryHide())
    end)
    :next(function()
    	self:OnStartRound()
    end)
end
function GameUIReplay:OnStartRound()
    self.ui_map.roundLabel:setString(self.roundCount)
    if self.defenceTroops[1]:IsWall() then
        self:OnStartMoveToWall()
    else
        self:OnStartSoldierBattle()
    end
end
function GameUIReplay:OnFinishRound()
    self.roundCount = self.roundCount + 1
    
    local attackTroops = {}
    for _,v in ipairs(self.attackTroops) do
        if not v:isVisible() then
            v:removeFromParent()
        else 
            table.insert(attackTroops, v)
            v.effectsNode:removeAllChildren()
        end
    end
    self.attackTroops = attackTroops

    local defenceTroops = {}
    for i,v in ipairs(self.defenceTroops) do
        if not v:isVisible() then
            v:removeFromParent()
        else 
            table.insert(defenceTroops, v)
            v.effectsNode:removeAllChildren()
        end
    end
    self.defenceTroops = defenceTroops

    if #self.attackTroops > 0 and #self.defenceTroops > 0 then
        self:OnStartRound()
    elseif #self.attackTroops > 0 and not self.isFightWall
    and type(report.attackPlayerData.fightWithDefenceWall) == "table" then
        self.defenceTroops[1] = UIKit:CreateFightTroops("wall", {isleft = false,},self)
            :addTo(self.ui_map.soldierBattleNode)
            :pos(self:WallPosition())
            :FaceCorrect()
        self:OnStartMoveToWall()
    end
end
-- 打城墙
function GameUIReplay:OnStartMoveToWall()
    self.ui_map.roundLabel:setString(self.roundCount)

    local indexes = {1,2,3,4,5,6}
    local flip = false
    while(#indexes > #self.attackTroops) do
        if flip then
            table.remove(indexes, 1)
        else
            table.remove(indexes, #indexes)
        end
        flip = not flip
    end
    for i,v in pairs(self.attackTroops) do
        local tx, ty = self:AttackPosition(), self:TopPositionByRow(indexes[i])
        v:Move(tx, ty, self:MovingTimeForAttack()).effectsNode:removeAllChildren()
    end
    local wall = self.defenceTroops[1]
    local ox,oy = self:WallPosition()
    wall:Move(ox-120, oy, self:MovingTimeForAttack(), function(isend)
        if not isend then
            for i,v in pairs(self.attackTroops) do
                v:Idle()
            end
        else
            self:OnFinishMoveToWall()
        end
    end)
    local originx = self.ui_map.battleBg:getPositionX()
    wall:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
        local ox = self:WallPosition()
        local x  = wall:getPosition()
        self.ui_map.battleBg:setPositionX(originx + x - ox)
    end)
    wall:scheduleUpdate()
end
function GameUIReplay:OnFinishMoveToWall()
    self.isFightWall = true
    local wall = self.defenceTroops[1]
    local point = cc.p(wall:getPosition())
    local wp = wall:getParent():convertToWorldSpace(point)
    wp.x = wp.x - 100
    local move_count = 0
    local need_move = false
    local melee_count = 0
    for i,v in pairs(self.attackTroops) do
        if v:IsMelee() then
            melee_count = melee_count + 1
            need_move = true
            local np = v:getParent():convertToNodeSpace(wp)
            local attack_x, attack_y = v:getPosition()
            if np.x ~= attack_x then
                v:Move(np.x, attack_y, self:MovingTimeForAttack(), function(isend)
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
    for i,v in ipairs(self.attackTroops) do
        self:OnAttacking(v, self.defenceTroops[1])
    end
end
function GameUIReplay:OnStartSoldierBattle()
    -- 本轮是士兵对打
    self.dualCount = 1
    local need_move = false
    local need_move_count = 0
    local move_count = 0
    for i,v in ipairs(self.attackTroops) do
        local tx, ty = self:AttackPosition(), self:TopPositionByRow(i)
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
    for i,v in ipairs(self.defenceTroops) do
        local tx, ty = self:DefencePosition(), self:TopPositionByRow(i)
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
    if type(report.fightWithDefencePlayerReports.attackPlayerDragonFightData) == "table" then
        -- math.randomseed(tostring(os.time()):reverse():sub(1, 6))
        -- local select_action = math.random(3)
        -- if select_action == 1 then -- only left
        --     self:OnLeftDragonAttackTroops()
        -- elseif select_action == 2 then -- only right
        --     self:OnRightDragonAttackTroops()
        -- elseif select_action == 3 then -- both
        self:OnBothDragonAttackTroops()
        -- end
    else
        self:OnStartDual()
    end
end
function GameUIReplay:OnLeftDragonAttackTroops()
    self.attackDragon:pos(-400, display.cy)
        :Move(display.width + 400, display.cy, self:MovingTimeForAttack(), function(isend)
            if isend then
                self:OnStartDual()
            else
                self:OnDragonAttackTroops(self.attackDragon,self.defenceTroops)
            end
        end)
end
function GameUIReplay:OnRightDragonAttackTroops()
    self.defenceDragon:pos(display.width + 400, display.cy)
        :Move(-400, display.cy, self:MovingTimeForAttack(), function(isend)
            if isend then
                self:OnStartDual()
            else
                self:OnDragonAttackTroops(defenceDragon,self.attackTroops)
            end
        end)
end
function GameUIReplay:OnBothDragonAttackTroops()
    self.attackDragon:pos(-400, display.cy)
        :Move(display.width + 400, display.cy, self:MovingTimeForAttack(), function(isend)
            if isend then
                self.defenceDragon:pos(display.width + 400, display.cy)
                    :Move(-400, display.cy, self:MovingTimeForAttack(), function(isend)
                        if isend then
                            self:OnStartDual()
                        else
                            self:OnDragonAttackTroops(self.defenceDragon,self.attackTroops)
                        end
                    end)
            else
                self:OnDragonAttackTroops(self.attackDragon,self.defenceTroops)
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
function GameUIReplay:OnFinishDual()
    self.dualCount = self.dualCount + 1
    local attackResults = report.fightWithDefencePlayerReports.soldierRoundDatas[self.roundCount].attackResults
    local defenceResults = report.fightWithDefencePlayerReports.soldierRoundDatas[self.roundCount].defenceResults

    if self.dualCount <= #attackResults 
    and self.dualCount <= #defenceResults then
        self:OnStartDual()
    else
        self:OnFinishRound()
    end
end
function GameUIReplay:OnStartDual()
    self.hurtCount = 0
    local attackResults = report.fightWithDefencePlayerReports.soldierRoundDatas[self.roundCount].attackResults
    local defenceResults = report.fightWithDefencePlayerReports.soldierRoundDatas[self.roundCount].defenceResults
    if attackResults[self.dualCount].isWin then
        self:OnFight(self.defenceTroops[self.dualCount], self.attackTroops[self.dualCount])
    else
        self:OnFight(self.attackTroops[self.dualCount], self.defenceTroops[self.dualCount])
    end
end
function GameUIReplay:OnAttackFinished(attackTroops)
    attackTroops:Idle()
    assert(attackTroops.properties.target)
    local target = attackTroops.properties.target

    if self.isFightWall then
        self.fightWallCount = self.fightWallCount + 1
    end

    if isTroops(target) then
    	-- 攻打城墙这两个是必要条件
        if not self.isFightWall or self.fightWallCount == 1 then
            target:PromiseOfHurt():next(function()
            	self:OnHurtFinished(target)
            end)
        end
    else
        for _,v in pairs(target) do
            v:PromiseOfHurt():next(function()
            	self:OnHurtFinished(v)
            end)
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
                hurtTroops:Death()
                local x,y = self:GetOriginPoint(attackTroops)
                attackTroops:Return(x,y, self:MovingTimeForAttack(), function()
                    attackTroops:FaceCorrect()
                    self:OnFinishDual()
                end)
            else
                hurtTroops:Death(function()
                    self:OnFinishDual()
                end)
            end
            attackTroops.properties.target = nil
            hurtTroops.properties.target = nil
        end
    else
        if hurtTroops:IsWall() then
            self:OnAttacking(hurtTroops, self.attackTroops)
        end
        if self.hurtCount == #self.attackTroops then
            local attackPlayerWallRoundDatas = report.fightWithDefencePlayerReports.attackPlayerWallRoundDatas
            for i,v in pairs(self.attackTroops) do
                local roundData = attackPlayerWallRoundDatas[i]
                if roundData and roundData.soldierCount - roundData.soldierDamagedCount <= 0 then
                    v:Death()
                end
            end

            local wall = report.fightWithDefencePlayerReports.defencePlayerWallRoundDatas[1]
            local wallHp = wall.wallHp
            local wallMaxHp = wall.wallMaxHp
            local wallDamagedHp = 0,0,0
            for i,v in ipairs(report.fightWithDefencePlayerReports.defencePlayerWallRoundDatas) do
                wallDamagedHp = wallDamagedHp + v.wallDamagedHp
            end

            if wallHp - wallDamagedHp <= 0 then
                self.defenceTroops[1]:Death()
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
    attackTroops.properties.target = defenceTroops
    if isTroops(defenceTroops) then
        defenceTroops.properties.target = attackTroops
    else
        for _,v in pairs(defenceTroops) do
            v.properties.target = attackTroops
        end
    end
    attackTroops:PromiseOfAttack():next(function()
    	self:OnAttackFinished(attackTroops)
    end)
end
function GameUIReplay:IsMoved(troops)
    local tx,ty = self:GetOriginPoint(troops)
    local x,y = troops:getPosition()
    return x ~= tx or y ~= ty
end
function GameUIReplay:GetOriginPoint(troops)
    local pos_y = self:TopPositionByRow(self.dualCount)
    local x,y = troops:IsLeft() and self:AttackPosition() or self:DefencePosition(), pos_y
    return x, y
end
function GameUIReplay:Stop()

end
function GameUIReplay:CleanUp()

end
function GameUIReplay:Speed()
    return 4
end

function GameUIReplay:BuildUI()
    local ui_map = {}

    cc.LayerGradient:create(cc.c4b(0,255,0,255), cc.c4b(255,0,0,255), cc.p(1, 1)):addTo(self)
    local bg = WidgetUIBackGround.new({width = 608,height = 910},
                    WidgetUIBackGround.STYLE_TYPE.STYLE_1):addTo(self)
                    :align(display.TOP_CENTER, display.cx, display.height - 10)

    ui_map.soldierBattleNode = display.newClippingRegionNode(cc.rect(15, 85, 608-15*2, 910 - 85*2))
        :addTo(bg)
    ui_map.battleBg = display.newSprite("splash_beta_bg_3987x1136.jpg"):addTo(ui_map.soldierBattleNode):align(display.LEFT_CENTER, 0, display.cy)
    ui_map.dragonBattleNode = display.newNode():addTo(bg)
    
    display.newSprite("replay_title_bg.png"):addTo(self)
    :align(display.TOP_CENTER, display.cx, display.height - 10)
    
    display.newSprite("replay_round.png"):addTo(self)
    :pos(display.cx, display.height - 40)
    
    ui_map.roundLabel = UIKit:ttfLabel({
        text = 1,
        size = 36,
        color = 0xffde00,
    }):addTo(self)
    :align(display.CENTER, display.cx, display.height - 65)

    ui_map.attackName = UIKit:ttfLabel({
        text = "attackName",
        size = 22,
        color = 0xffedae,
    }):addTo(self)
    :align(display.CENTER, display.cx - 125, display.height - 35)

    ui_map.defenceName = UIKit:ttfLabel({
        text = "defenceName",
        size = 22,
        color = 0xffedae,
    }):addTo(self)
    :align(display.CENTER, display.cx + 125, display.height - 35)


    ui_map.attackDragonLabel = UIKit:ttfLabel({
        text = "红龙",
        size = 20,
        color = 0xffedae,
    }):addTo(self)
    :align(display.CENTER, display.cx - 125, display.height - 75)

    ui_map.defenceDragonLabel = UIKit:ttfLabel({
        text = "绿龙",
        size = 20,
        color = 0xffedae,
    }):addTo(self)
    :align(display.CENTER, display.cx + 125, display.height - 75)


    ui_map.attackDragonIcon = display.newSprite(DRAGON_HEAD.redDragon)
    :addTo(self):scale(0.8)
    :align(display.CENTER, display.cx - 256, display.height - 48)

    ui_map.defenceDragonIcon = display.newSprite(DRAGON_HEAD.redDragon)
    :addTo(self):scale(0.8)
    :align(display.CENTER, display.cx + 256, display.height - 48)
    ui_map.defenceDragonIcon:flipX(true)


    ui_map.speedup = cc.ui.UIPushButton.new(
        {normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"},
        {scale9 = false}
    ):setButtonLabel(
        UIKit:ttfLabel({
            text = _("加速"),
            color = 0xfff3c7,
            size = 24,
            shadow = true,
        })
    ):addTo(bg):align(display.CENTER, 110, 45)

    ui_map.close = cc.ui.UIPushButton.new(
        {normal = "red_btn_up_148x58.png",pressed = "red_btn_down_148x58.png"},
        {scale9 = false}
    ):setButtonLabel(
        UIKit:ttfLabel({
            text = _("关闭"),
            color = 0xfff3c7,
            size = 24,
            shadow = true,
        })
    ):addTo(bg):align(display.CENTER, 608 - 110, 45)



    ui_map.speedup:onButtonClicked(function()
        if self.speed == 1 then
            self.speed = 2
            ui_map.speedup:setButtonLabelString(_("x2"))
        elseif self.speed == 2 then
            self.speed = 4
            ui_map.speedup:setButtonLabelString(_("x4"))
        elseif self.speed == 4 then
            self.speed = 1
            ui_map.speedup:setButtonLabelString(_("加速"))
        end
        self:RefreshSpeed()
    end)

    self.ui_map = ui_map
end

return GameUIReplay



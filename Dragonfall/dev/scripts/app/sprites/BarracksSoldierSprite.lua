local UILib = import("..ui.UILib")
local Sprite = import(".Sprite")
local BarracksSoldierSprite = class("BarracksSoldierSprite", Sprite)
local min = math.min


local move_ani_map = {
    ranger = {
        "gongjianshou_1_45",
        "gongjianshou_2_45",
        "gongjianshou_3_45",
    },
    crossbowman = {
        "nugongshou_1_45",
        "nugongshou_2_45",
        "nugongshou_3_45",
    },
    catapult = {
        "toushiche_45",
        "toushiche_2_45",
        "toushiche_3_45",
    },
    ballista = {
        "nuche_1_45",
        "nuche_2_45",
        "nuche_3_45",
    },
    lancer = {
        "qibing_1_45",
        "qibing_2_45",
        "qibing_3_45",
    },
    horseArcher = {
        "youqibing_1_45",
        "youqibing_2_45",
        "youqibing_3_45",
    },
    swordsman = {
        "bubing_1_45",
        "bubing_2_45",
        "bubing_3_45",
    },
    sentinel = {
        "shaobing_1_45",
        "shaobing_2_45",
        "shaobing_3_45",
    },
    skeletonWarrior = {
        "kulouyongshi_45",
        "kulouyongshi_45",
        "kulouyongshi_45",
    },
    skeletonArcher = {
        "kulousheshou_45",
        "kulousheshou_45",
        "kulousheshou_45",
    },
    deathKnight = {
        "siwangqishi_45",
        "siwangqishi_45",
        "siwangqishi_45",
    },
    meatWagon = {
        "jiaorouche_45",
        "jiaorouche_45",
        "jiaorouche_45",
    },
}



function BarracksSoldierSprite:ctor(city_layer, soldier_type, star)
    self.soldier_type = soldier_type
    self.soldier_star = star
    self.path = {
        {x = 6, y = 27},
        {x = 9, y = 27},
        {x = 9, y = 9},
        {x = 4, y = 9},
        {x = 4, y = 10},
    }
    local start_point = table.remove(self.path, 1)
    BarracksSoldierSprite.super.ctor(self, city_layer, nil, city_layer:GetLogicMap():ConvertToMapPosition(start_point.x, start_point.y))
    self:setPosition(self:GetLogicMap():ConvertToMapPosition(start_point.x, start_point.y))
    self:UpdateVelocityByPoints(start_point, self.path[1])


    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
        dt = min(dt, 0.05)
        self:Update(dt)
    end)
    self:scheduleUpdate()

    -- self:CreateBase()
end
function BarracksSoldierSprite:CreateSprite()
    return ccs.Armature:create(self:GetAniName())
end
function BarracksSoldierSprite:TurnEast()
    self:SetupAniConfig("move_45", true)
end
function BarracksSoldierSprite:TurnSouth()
    self:SetupAniConfig("move_45")
end
function BarracksSoldierSprite:TurnWest()
    self:SetupAniConfig("move_-45")
end
function BarracksSoldierSprite:TurnNorth()
    self:SetupAniConfig("move_-45", true)
end
function BarracksSoldierSprite:SetupAniConfig(act, isFlip)
    local ap,flip,s,shadow = unpack(UIKit:GetSoldierMoveAniConfig(self:GetAniName(), act))
    s = s * 0.7
    local sprite = self:GetSprite()
    sprite:setScaleX(((not flip and isFlip) or (flip and not isFlip)) and -s or s)
    sprite:setScaleX(-self:GetSprite():getScaleX())
    sprite:setScaleY(s)
    sprite:setAnchorPoint(ap)
    sprite:getAnimation():play(act)
end
function BarracksSoldierSprite:GetAniName()
    return move_ani_map[self.soldier_type][self.soldier_star]
end
function BarracksSoldierSprite:GetSpriteOffset()
    return 0,0
end
function BarracksSoldierSprite:GetMidLogicPosition()
    return self:GetLogicMap():ConvertToLogicPosition(self:getPosition())
end
function BarracksSoldierSprite:CreateBase()
    self:GenerateBaseTiles(1, 1)
end
local function wrap_point_in_table(...)
    local arg = {...}
    return {x = arg[1], y = arg[2]}
end
local cc = cc
function BarracksSoldierSprite:UpdateVelocityByPoints(start_point, end_point)
    local speed = 150
    local logic_map = self:GetLogicMap()
    local spt = wrap_point_in_table(logic_map:ConvertToMapPosition(start_point.x, start_point.y))
    local ept = wrap_point_in_table(logic_map:ConvertToMapPosition(end_point.x, end_point.y))
    local dir = cc.pSub(ept, spt)
    local distance = cc.pGetLength(dir)
    self.speed = {x = speed * dir.x / distance, y = speed * dir.y / distance}
    local degree = math.deg(cc.pGetAngle(dir,cc.p(1,-1)))
    if degree > -15 and degree < 0 then
        self:TurnEast()
    elseif degree > -90 and degree < -50 then
        self:TurnNorth()
    elseif degree > 100 and degree < 120 then
        self:TurnSouth()
    else
        self:TurnWest()
    end
end
function BarracksSoldierSprite:Speed()
    return self.speed
end
function BarracksSoldierSprite:Update(dt)
    if #self.path == 0 then return end

    local x, y = self:getPosition()

    local speed = self:Speed()
    local nx, ny = x + speed.x * dt, y + speed.y * dt

    local point = self.path[1]
    local ex, ey = self:GetLogicMap():ConvertToMapPosition(point.x, point.y)

    if speed.x * (ex - nx) + speed.y * (ey - ny) < 0 then
        if #self.path <= 1 then
            self:unscheduleUpdate()
            self:runAction(
                transition.sequence{
                    cc.FadeOut:create(0.5),
                    cc.CallFunc:create(function()
                        self:GetMapLayer():RefreshMyCitySoldierCount()
                    end),
                    cc.RemoveSelf:create(),
                }
            )
            return
        end
        local path = self.path
        self:UpdateVelocityByPoints(path[1], path[2])
        nx, ny = ex, ey
        table.remove(path, 1)
    end
    self:setPosition(nx, ny)
end

return BarracksSoldierSprite













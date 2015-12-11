local Sprite = import(".Sprite")
local SoldierSprite = class("SoldierSprite", Sprite)

local normal = GameDatas.Soldiers.normal
local special = GameDatas.Soldiers.special

local soldier_config = {
    ----
    ["swordsman"] = {
        count = 4, 
        scale = 1,
        {"bubing_1", -10, 45, 0.8},
        {"bubing_2", -20, 40, 0.8},
        {"bubing_3", -15, 35, 0.8},
    },
    ["ranger"] = {
        count = 4,
        scale = 1,
        {"gongjianshou_1", 0, 45, 0.8},
        {"gongjianshou_2", 0, 45, 0.8},
        {"gongjianshou_3", 0, 45, 0.8},
    },
    ["lancer"] = {
        count = 2,
        scale = 1,
        {"qibing_1", -10, 50, 0.8},
        {"qibing_2", -10, 50, 0.8},
        {"qibing_3", -10, 50, 0.8},
    },
    ["catapult"] = {
        count = 1,
        scale = 1,
        {  "toushiche", 60, 25, 1},
        {"toushiche_2", 60, 25, 1},
        {"toushiche_3", 60, 25, 1},
    },

    -----
    ["sentinel"] = {
        count = 4,
        scale = 1,
        {"shaobing_1", 0, 55, 0.8},
        {"shaobing_2", 0, 55, 0.8},
        {"shaobing_3", 0, 55, 0.8},
    },
    ["crossbowman"] = {
        count = 4,
        scale = 1,
        {"nugongshou_1", 0, 45, 0.8},
        {"nugongshou_2", 0, 50, 0.8},
        {"nugongshou_3", 15, 45, 0.8},
    },
    ["horseArcher"] = {
        count = 2,
        scale = 1,
        {"youqibing_1", -15, 55, 0.8},
        {"youqibing_2", -15, 55, 0.8},
        {"youqibing_3", -15, 55, 0.8},
    },
    ["ballista"] = {
        count = 1,
        scale = 1,
        {"nuche_1", 0, 30, 1},
        {"nuche_2", 0, 30, 1},
        {"nuche_3", 0, 30, 1},
    },
    ----
    ["skeletonWarrior"] = {
        count = 4,
        scale = 0.6,
        {"kulouyongshi", 0, 40, 0.8},
        {"kulouyongshi", 0, 40, 0.8},
        {"kulouyongshi", 0, 40, 0.8},
    },
    ["skeletonArcher"] = {
        count = 4,
        scale = 0.6,
        {"kulousheshou", 25, 40, 0.8},
        {"kulousheshou", 25, 40, 0.8},
        {"kulousheshou", 25, 40, 0.8},
    },
    ["deathKnight"] = {
        count = 2,
        scale = 0.6,
        {"siwangqishi", -10, 50, 0.8},
        {"siwangqishi", -10, 50, 0.8},
        {"siwangqishi", -10, 50, 0.8},
    },
    ["meatWagon"] = {
        count = 1,
        scale = 0.6,
        {"jiaorouche", 60, 20, 0.8},
        {"jiaorouche", 60, 20, 0.8},
        {"jiaorouche", 60, 20, 0.8},
    },
}
local position_map = {
    [1] = {
        x = 0, 
        y = 31,
        {x = 0, y = 0},
    },
    [2] = {
        x = -15, 
        y = 45,
        {x = -5, y = -15},
        {x = 20, y = -30},
    },
    [4] = {
        x = 0, 
        y = 45,
        {x = 0, y = -5},
        {x = -25, y = -20},
        {x = 25, y = -20},
        {x = 0, y = -35},
    }
}
function SoldierSprite:ctor(city_layer, soldier_type, soldier_star, x, y)
    assert(soldier_type)
    self.soldier_type = soldier_type
    local config = special[soldier_type] or normal[soldier_type.."_"..soldier_star]
    self.soldier_star = soldier_star or config.star
    self.x, self.y = x, y
    SoldierSprite.super.ctor(self, city_layer, nil, city_layer:GetLogicMap():ConvertToMapPosition(x, y))


    self:CreateBase()
    -- ui.newTTFLabel({text = soldier_type, size = 20, x = 0, y = 100}):addTo(self, 10)
end
function SoldierSprite:CreateSprite()
    local node = display.newNode()
    local s = soldier_config[self.soldier_type].scale or 1
    for _,v in ipairs(position_map[soldier_config[self.soldier_type].count]) do
        UIKit:CreateSoldierIdle45Ani(self.soldier_type, self.soldier_star)
        :addTo(node):align(display.CENTER, v.x, v.y):scale(s)
    end
    return node
end
function SoldierSprite:GetLogicPosition()
    return self.x, self.y
end
function SoldierSprite:GetSpriteOffset()
    local config = position_map[soldier_config[self.soldier_type].count]
    return config.x, config.y
end
function SoldierSprite:CreateBase()
    self:GenerateBaseTiles(2, 2)
end
function SoldierSprite:GetSoldierTypeAndStar()
    return self.soldier_type, self.soldier_star
end
function SoldierSprite:SetPositionWithZOrder(x, y)
    self.x, self.y = self:GetLogicMap():ConvertToLogicPosition(x, y)
    SoldierSprite.super.SetPositionWithZOrder(self, x, y)
end
function SoldierSprite:GetMidLogicPosition()
    return self.x - 1, self.y - 1
end

return SoldierSprite















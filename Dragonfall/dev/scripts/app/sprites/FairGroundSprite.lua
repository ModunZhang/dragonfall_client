local Sprite = import(".Sprite")
local FairGroundSprite = class("FairGroundSprite", Sprite)

function FairGroundSprite:ctor(city_layer, x, y)
    FairGroundSprite.super.ctor(self, city_layer, nil, city_layer:GetLogicMap():ConvertToMapPosition(x, y))
    -- self:CreateBase()
    local turntable = display.newNode():addTo(self, 1):pos(-20, 85)
    display.newSprite("turntable_bg.png"):addTo(turntable)
    display.newSprite("turntable.png"):addTo(turntable):pos(0,5)
    :runAction(cc.RepeatForever:create(transition.sequence{cc.RotateBy:create(2, -360)}))
    display.newSprite("turntable_fg.png"):addTo(turntable)
end
function FairGroundSprite:IsContainPointWithFullCheck(x, y, world_x, world_y)
    return { logic_clicked = false, sprite_clicked = self:IsContainWorldPoint(world_x, world_y)}
end
function FairGroundSprite:GetEntity()
    return {
        GetType = function()
            return "FairGround"
        end,
        GetLogicPosition = function()
            return -1, -1
        end,
        IsHouse = function()
            return false
        end
    }
end
function FairGroundSprite:GetSpriteFile()
    return "Fairground.png"
end
function FairGroundSprite:GetSpriteOffset()
    return 0, 0
end
function FairGroundSprite:GetMidLogicPosition()
    return self:GetLogicMap():ConvertToLogicPosition(self:getPosition())
end
function FairGroundSprite:CreateBase()
    self:GenerateBaseTiles(6, 9)
end


return FairGroundSprite











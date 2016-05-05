local Sprite = import(".Sprite")
local FairGroundSprite = class("FairGroundSprite", Sprite)


local lastTime = 1
function FairGroundSprite:ctor(city_layer, x, y)
    FairGroundSprite.super.ctor(self, city_layer, nil, city_layer:GetLogicMap():ConvertToMapPosition(x, y))
    -- self:CreateBase()
    local turntable = display.newNode():addTo(self, 1):pos(-20, 85)
    display.newSprite("turntable_bg.png"):addTo(turntable)
    display.newSprite("turntable.png"):addTo(turntable):pos(0,5)
    :runAction(cc.RepeatForever:create(transition.sequence{cc.RotateBy:create(2, -360)}))
    display.newSprite("turntable_fg.png"):addTo(turntable)


    local user = city_layer.scene:GetCity():GetUser()
    if User:Id() == user:Id() then
        scheduleAt(self, function()
            if self:GetSprite():getFilter() then
                if user:GetOddFreeNormalGachaCount() <= 0 then
                    self:GetSprite():removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
                    self:GetSprite():unscheduleUpdate()
                    self:GetSprite():clearFilter()
                end
                return
            end
            self:GetSprite():removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
            self:GetSprite():unscheduleUpdate()
            if user:GetOddFreeNormalGachaCount() > 0 then
                self.time = 0
                local ratio = math.fmod(self.time, lastTime) / lastTime
                self:GetSprite():setFilter(filter.newFilter("CUSTOM", json.encode({
                    frag = "shaders/flash.fs",
                    shaderName = "flash1",
                    ratio = ratio,
                })))
                self:GetSprite():addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
                    self.time = self.time + dt
                    self:GetSprite():getFilter():getGLProgramState()
                    :setUniformFloat("ratio", math.fmod(self.time, lastTime) / lastTime)
                end)
                self:GetSprite():scheduleUpdate()
            end
        end)
    end
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











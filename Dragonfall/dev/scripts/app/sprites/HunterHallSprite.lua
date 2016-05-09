local FunctionUpgradingSprite = import(".FunctionUpgradingSprite")
local HunterHallSprite = class("HunterHallSprite", FunctionUpgradingSprite)

function HunterHallSprite:OnUserDataChanged_soldierStarEvents()
    self:DoAni()
end
function HunterHallSprite:OnUserDataChanged_militaryTechEvents()
    self:DoAni()
end

function HunterHallSprite:ctor(city_layer, entity, city)
    HunterHallSprite.super.ctor(self, city_layer, entity, city)
    local User = city:GetUser()
    User:AddListenOnType(self, "soldierStarEvents")
    User:AddListenOnType(self, "militaryTechEvents")
end
function HunterHallSprite:RefreshSprite()
    HunterHallSprite.super.RefreshSprite(self)
    self:DoAni()
end
function HunterHallSprite:DoAni()
    if self:GetEntity():IsUnlocked() then
        if self:GetEntity():BelongCity():GetUser():HasMilitaryTechEventBy("hunterHall") then
            self:RemoveEmtpyAnimation()
            self:PlayWorkAnimation()
        else
            self:PlayEmptyAnimation()
            self:RemoveWorkAnimation()
        end
    end
end
local WORK_TAG = 11201
function HunterHallSprite:PlayWorkAnimation()
    if not self:getChildByTag(WORK_TAG) then
        local x,y = self:GetSprite():getPosition()
        UIKit:Gear():addTo(self,1,WORK_TAG):pos(x,y)
    end
end
function HunterHallSprite:RemoveWorkAnimation()
    if self:getChildByTag(WORK_TAG) then
        self:removeChildByTag(WORK_TAG)
    end
end


local EMPTY_TAG = 11400
local zz = import("..particles.zz")
function HunterHallSprite:PlayEmptyAnimation()
    if not self:getChildByTag(EMPTY_TAG) then
        local x,y = self:GetSprite():getPosition()
        zz():addTo(self,1,EMPTY_TAG):pos(x + 50,y + 50)
    end
end
function HunterHallSprite:RemoveEmtpyAnimation()
    if self:getChildByTag(EMPTY_TAG) then
        self:removeChildByTag(EMPTY_TAG)
    end
end



return HunterHallSprite











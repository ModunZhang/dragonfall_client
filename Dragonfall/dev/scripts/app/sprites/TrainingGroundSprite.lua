local FunctionUpgradingSprite = import(".FunctionUpgradingSprite")
local TrainingGroundSprite = class("TrainingGroundSprite", FunctionUpgradingSprite)

function TrainingGroundSprite:OnUserDataChanged_soldierStarEvents()
    self:DoAni()
end
function TrainingGroundSprite:OnUserDataChanged_militaryTechEvents()
    self:DoAni()
end

function TrainingGroundSprite:ctor(city_layer, entity, city)
    TrainingGroundSprite.super.ctor(self, city_layer, entity, city)
    local User = city:GetUser()
    User:AddListenOnType(self, "soldierStarEvents")
    User:AddListenOnType(self, "militaryTechEvents")
end
function TrainingGroundSprite:RefreshSprite()
    TrainingGroundSprite.super.RefreshSprite(self)
    self:DoAni()
end
function TrainingGroundSprite:DoAni()
    if self:GetEntity():IsUnlocked() then
        if self:GetEntity():BelongCity():GetUser():HasMilitaryTechEventBy("trainingGround") then
            self:RemoveEmtpyAnimation()
            self:PlayWorkAnimation()
        else
            self:PlayEmptyAnimation()
            self:RemoveWorkAnimation()
        end
    end
end
local WORK_TAG = 11201
function TrainingGroundSprite:PlayWorkAnimation()
    if not self:getChildByTag(WORK_TAG) then
        local x,y = self:GetSprite():getPosition()
        UIKit:Gear():addTo(self,1,WORK_TAG):pos(x,y)
    end
end
function TrainingGroundSprite:RemoveWorkAnimation()
    if self:getChildByTag(WORK_TAG) then
        self:removeChildByTag(WORK_TAG)
    end
end

local EMPTY_TAG = 11400
local zz = import("..particles.zz")
function TrainingGroundSprite:PlayEmptyAnimation()
    if not self:getChildByTag(EMPTY_TAG) then
        local x,y = self:GetSprite():getPosition()
        zz():addTo(self,1,EMPTY_TAG):pos(x + 50,y + 50)
    end
end
function TrainingGroundSprite:RemoveEmtpyAnimation()
    if self:getChildByTag(EMPTY_TAG) then
        self:removeChildByTag(EMPTY_TAG)
    end
end





return TrainingGroundSprite











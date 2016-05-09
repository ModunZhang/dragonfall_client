local FunctionUpgradingSprite = import(".FunctionUpgradingSprite")
local WorkShopSprite = class("WorkShopSprite", FunctionUpgradingSprite)

function WorkShopSprite:OnUserDataChanged_soldierStarEvents()
    self:DoAni()
end
function WorkShopSprite:OnUserDataChanged_militaryTechEvents()
    self:DoAni()
end


function WorkShopSprite:ctor(city_layer, entity, city)
    WorkShopSprite.super.ctor(self, city_layer, entity, city)
    local User = city:GetUser()
    User:AddListenOnType(self, "soldierStarEvents")
    User:AddListenOnType(self, "militaryTechEvents")
end
function WorkShopSprite:RefreshSprite()
    WorkShopSprite.super.RefreshSprite(self)
    self:DoAni()
end
function WorkShopSprite:DoAni()
    if self:GetEntity():IsUnlocked() then
        if self:GetEntity():BelongCity():GetUser():HasMilitaryTechEventBy("workshop") then
            self:RemoveEmtpyAnimation()
            self:PlayWorkAnimation()
        else
            self:PlayEmptyAnimation()
            self:RemoveWorkAnimation()
        end
    end
end

local WORK_TAG = 11201
local smoke = import("..particles.smoke")
function WorkShopSprite:PlayWorkAnimation()
    if not self:getChildByTag(WORK_TAG) then
        local x,y = self:GetSprite():getPosition()
        local node = display.newNode():addTo(self,1,WORK_TAG)
        smoke():addTo(node):pos(x - 65,y + 80)
        UIKit:Gear():addTo(node):pos(x,y)
    end
end
function WorkShopSprite:RemoveWorkAnimation()
    if self:getChildByTag(WORK_TAG) then
        self:removeChildByTag(WORK_TAG)
    end
end


local EMPTY_TAG = 11400
local zz = import("..particles.zz")
function WorkShopSprite:PlayEmptyAnimation()
    if not self:getChildByTag(EMPTY_TAG) then
        local x,y = self:GetSprite():getPosition()
        zz():addTo(self,1,EMPTY_TAG):pos(x + 50,y + 50)
    end
end
function WorkShopSprite:RemoveEmtpyAnimation()
    if self:getChildByTag(EMPTY_TAG) then
        self:removeChildByTag(EMPTY_TAG)
    end
end



return WorkShopSprite











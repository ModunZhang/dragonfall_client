--
-- Author: dannyhe
-- Date: 2014-08-05 17:34:54
--
local LogoScene = class("LogoScene", function()
    return display.newScene("LogoScene")
end)
function LogoScene:ctor()
    self:loadSplashResources()
end

function LogoScene:onEnter()
    --关闭屏幕锁定定时器
    if ext.disableIdleTimer then
        ext.disableIdleTimer(true)
    end
    
    -- self.layer = cc.LayerColor:create(cc.c4b(255,255,255,255)):addTo(self)
    -- self.sprite = display.newSprite("batcat_logo_368x507.png", display.cx, display.cy):addTo(self.layer)
    -- self:performWithDelay(function() self:beginAnimate() end,0.5)


    display.newSprite("tmp_shrine_open_icon_96x96.png"):addTo(self):pos(display.cx, display.cy)

    UIKit:CreateSoldierMove45Ani("bubing_1_45"):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierMove45Ani("bubing_2_45"):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierMove45Ani("bubing_3_45"):addTo(self):pos(display.cx, display.cy)

    UIKit:CreateSoldierMove45Ani("gongjianshou_1_45"):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierMove45Ani("gongjianshou_2_45"):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierMove45Ani("gongjianshou_3_45"):addTo(self):pos(display.cx, display.cy)

    -- UIKit:CreateSoldierMoveNeg45Ani("bubing_2_45"):addTo(self):pos(display.cx, display.cy)

    -- UIKit:CreateSoldierIdle45Ani("swordsman", 1):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierIdle45Ani("swordsman", 2):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierIdle45Ani("swordsman", 3):addTo(self):pos(display.cx, display.cy)

    -- UIKit:CreateSoldierIdle45Ani("ranger", 1):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierIdle45Ani("ranger", 2):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierIdle45Ani("ranger", 3):addTo(self):pos(display.cx, display.cy)
    
    -- UIKit:CreateSoldierIdle45Ani("lancer", 1):addTo(self, 2):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierIdle45Ani("lancer", 2):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierIdle45Ani("lancer", 3):addTo(self):pos(display.cx, display.cy)

    -- UIKit:CreateSoldierIdle45Ani("catapult", 1):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierIdle45Ani("catapult", 2):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierIdle45Ani("catapult", 3):addTo(self):pos(display.cx, display.cy)

    -- UIKit:CreateSoldierIdle45Ani("sentinel", 1):addTo(self):pos(display.cx+50, display.cy)
    -- UIKit:CreateSoldierIdle45Ani("sentinel", 2):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierIdle45Ani("sentinel", 3):addTo(self):pos(display.cx, display.cy)

    -- UIKit:CreateSoldierIdle45Ani("crossbowman", 1):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierIdle45Ani("crossbowman", 2):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierIdle45Ani("crossbowman", 3):addTo(self):pos(display.cx, display.cy)

    -- UIKit:CreateSoldierIdle45Ani("horseArcher", 1):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierIdle45Ani("horseArcher", 2):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierIdle45Ani("horseArcher", 3):addTo(self):pos(display.cx, display.cy)

    -- UIKit:CreateSoldierIdle45Ani("ballista", 1):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierIdle45Ani("ballista", 2):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateSoldierIdle45Ani("ballista", 3):addTo(self):pos(display.cx, display.cy)

    -- UIKit:CreateSoldierIdle45Ani("skeletonWarrior", 1):addTo(self):pos(display.cx, display.cy):scale(0.5)
    -- UIKit:CreateSoldierIdle45Ani("skeletonArcher", 2):addTo(self):pos(display.cx, display.cy):scale(0.5)
    -- UIKit:CreateSoldierIdle45Ani("deathKnight", 3):addTo(self):pos(display.cx, display.cy):scale(0.7)
    -- UIKit:CreateSoldierIdle45Ani("meatWagon", 3):addTo(self):pos(display.cx, display.cy):scale(0.6)

    -- UIKit:CreateDragonByDegree(-190, 1.2, "redDragon"):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateDragonByDegree(90, 1.2, "redDragon"):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateDragonByDegree(0, 1.2, "blueDragon"):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateDragonByDegree(0, 1.2, "greenDragon"):addTo(self):pos(display.cx, display.cy)

    -- UIKit:CreateDragonByDegree(-10, 1.2, "redDragon"):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateDragonByDegree(-10, 1.2, "blueDragon"):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateDragonByDegree(-10, 1.2, "greenDragon"):addTo(self):pos(display.cx, display.cy)


    -- for i = 0, 360, 10 do
    --     UIKit:CreateDragonByDegree(i, 1.2, "redDragon"):addTo(self):pos(display.cx, display.cy)
    -- end

    -- UIKit:CreateMonster("crossbowman_2"):addTo(self):pos(display.cx, display.cy)


    -- ccs.Armature:create("blue_long_breath"):addTo(self)
    -- :pos(display.cx, display.cy):scale(0.3):getAnimation():playWithIndex(0)
    -- ccs.Armature:create("red_long_breath"):addTo(self)
    -- :pos(display.cx, display.cy):scale(0.3):getAnimation():playWithIndex(0)
    -- ccs.Armature:create("green_long_breath"):addTo(self)
    -- :pos(display.cx, display.cy):scale(0.3):getAnimation():playWithIndex(0)
    -- ccs.Armature:create("heilong_breath"):addTo(self)
    -- :pos(display.cx, display.cy):scale(0.3):getAnimation():playWithIndex(0)
    -- ccs.Armature:create("green_long_breath"):addTo(self)
    -- :pos(display.cx, display.cy):getAnimation():playWithIndex(0)

    -- UIKit:CreateDragonBreahAni("redDragon", true):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateDragonBreahAni("blueDragon", true):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateDragonBreahAni("greenDragon", true):addTo(self):pos(display.cx, display.cy)
    -- UIKit:CreateDragonBreahAni("blackDragon", true):addTo(self):pos(display.cx, display.cy)

    -- UIKit:newGameUI('GameUISelectTerrain'):AddToScene(self, true)
end

function LogoScene:beginAnimate()
    local action = cc.Spawn:create({cc.ScaleTo:create(checknumber(2),1.5),cca.fadeTo(1.5,255/2)})
    self.sprite:runAction(action)
    local sequence = transition.sequence({
        cc.FadeOut:create(1),
        cc.CallFunc:create(function()
            self:performWithDelay(function()
                self.sprite:removeFromParent(true)
                app:enterScene("MainScene")
            end, 0.5)
        end),
    })
    self.layer:runAction(sequence)
end
--预先加载登录界面使用的大图
function LogoScene:loadSplashResources()
    --加载splash界面使用的图片
    display.addImageAsync("splash_logo_515x92.png",function()
        display.addImageAsync("splash_beta_bg_3987x1136.jpg",function()end)
    end)
end

function LogoScene:onExit()
    cc.Director:getInstance():getTextureCache():removeTextureForKey("batcat_logo_368x507.png")
end

return LogoScene






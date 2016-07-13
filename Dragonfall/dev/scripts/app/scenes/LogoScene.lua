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
function createSoldier(name, x, y, s)
    display.newSprite("tmp_shrine_open_icon_96x96.png"):addTo(display.getRunningScene()):pos(x, y)
    UIKit:CreateSoldierIdle45Ani(name):scale(s or 1):addTo(display.getRunningScene()):pos(x, y)
end

function LogoScene:onEnter()
    --关闭屏幕锁定定时器
    if ext.disableIdleTimer then
        ext.disableIdleTimer(true)
    end
    
    self.layer = cc.LayerColor:create(cc.c4b(255,255,255,255)):addTo(self)
    if device.platform == 'ios' or device.platform == 'mac' then -- 兼容iOS线上版本
        self.sprite = display.newSprite("batcat_logo_368x472.png", display.cx, display.cy):addTo(self.layer)
    else
        self.sprite = display.newSprite("aiyingyong_512x512.png", display.cx, display.cy):addTo(self.layer):scale(display.height* 440/581632)
    end
    self:performWithDelay(function() self:beginAnimate() end,0.5)
end


function LogoScene:beginAnimate()
    if device.platform == 'ios' or device.platform == 'mac' then -- 兼容iOS线上版本
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
    else
        local sequence = transition.sequence({
            cc.FadeOut:create(0.5),
            cc.CallFunc:create(function()
                self.sprite:setTexture("batcat_logo_368x472.png")
            end),
            cc.FadeIn:create(0.4),
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(function()
                self.layer:runAction(cca.fadeOut(0.3))
            end),
            cc.FadeOut:create(0.4),
            cc.CallFunc:create(function()
                self.sprite:removeFromParent(true)
                app:enterScene("MainScene")
            end)
        })
        self.sprite:runAction(sequence)
    end
end

--预先加载登录界面使用的大图
function LogoScene:loadSplashResources()
    --加载splash界面使用的图片
    local imageName = ext.channelIsEqTo("gNetop") and "splash_logo_war_514x92.png" or "splash_logo_516x92.png"
    display.addImageAsync(imageName,function()
        display.addImageAsync("splash_beta_bg_3987x1136.jpg",function()end)
    end)
end

function LogoScene:onExit()
    removeImageByKey("aiyingyong_512x512.png")
    removeImageByKey("batcat_logo_368x472.png")
end

return LogoScene






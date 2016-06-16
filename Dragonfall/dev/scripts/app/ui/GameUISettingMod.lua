--
-- Author: Kenny Dai
-- Date: 2016-06-13 09:40:47
--
local GameUISettingMod = UIKit:createUIClass("GameUISettingMod","GameUIWithCommonHeader")
local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
function GameUISettingMod:ctor()
    GameUISettingMod.super.ctor(self,City, _("MOD职权说明"))
end
function GameUISettingMod:onEnter()
    GameUISettingMod.super.onEnter(self)
    self:BuildUI()
end
function GameUISettingMod:BuildUI()
    local address = GameUtils:getSupportEmailAddress()
    
    local button = WidgetPushButton.new({normal = "brown_btn_up_552x56.png",pressed = "brown_btn_down_552x56.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("成为MOD"),
            size = 20,
            color = 0xffedae,
            shadow = true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                local subject,body = GameUtils:getSupportMailFormat(_("成为MOD"))
                local canSendMail = ext.sysmail.sendMail(address,subject,body,function()end)
                if not canSendMail then
                    UIKit:showMessageDialog(_("错误"),_("您尚未设置邮件：请前往IOS系统“设置”-“邮件、通讯录、日历”-“添加账户”处设置"),function()end)
                end
            end
        end)
        :align(display.CENTER_TOP, window.cx, window.top_bottom)
        :addTo(self:GetView())

    display.newSprite("setting_mod_64x78.png"):addTo(button):pos(-240,-28):scale(36/64)
    local button = WidgetPushButton.new({normal = "brown_btn_up_552x56.png",pressed = "brown_btn_down_552x56.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("举报MOD"),
            size = 20,
            color = 0xe95d37,
            shadow = true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                local subject,body = GameUtils:getSupportMailFormat(_("举报MOD"))
                local canSendMail = ext.sysmail.sendMail(address,subject,body,function()end)
                if not canSendMail then
                    UIKit:showMessageDialog(_("错误"),_("您尚未设置邮件：请前往IOS系统“设置”-“邮件、通讯录、日历”-“添加账户”处设置"),function()end)
                end
            end
        end)
        :align(display.CENTER_TOP, window.cx, window.top_bottom - 70)
        :addTo(self:GetView())
    display.newSprite("mod_icon_1.png"):addTo(button):pos(-240,-28)
end
return GameUISettingMod





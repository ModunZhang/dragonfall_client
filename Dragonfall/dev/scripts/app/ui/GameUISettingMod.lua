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
                if User.gameInfo.modApplyEnabled then
                    local subject,body = GameUtils:getSupportMailFormat(_("成为MOD"))
                    local canSendMail = ext.sysmail.sendMail(address,subject,body,function()end)
                    if not canSendMail then
                        UIKit:showMessageDialog(_("错误"),_("您尚未设置邮件：请前往IOS系统“设置”-“邮件、通讯录、日历”-“添加账户”处设置"),function()end)
                    end
                else
                    UIKit:showMessageDialog(_("提示"),_("MOD申请通道已关闭，请关注官方公告"),function()end)
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

    local desc = UIKit:ttfLabel({
        text = _("为了能和领主更深入的交流，我们邀请了一部分热心领主来担任游戏中的MODs。这些领主在游戏中会维护世界聊天频道的和谐，拥有禁言不当言语玩家的权利，除此之外，MODs并无其他额外权利，如果你发现MODs不正当的使用他/她的权利，请向我们举报。当然MODs有时会忙不过来，如果您有对游戏的建议或需要一些帮助，您也可以通过游戏内的“联系我们”系统与官方联系，我们将会以最快的速度对您的问题进行相应。"),
        size = 22,
        color = 0x615b44,
        dimensions = cc.size(520,0)
    }):align(display.CENTER_TOP, window.cx, window.top_bottom - 140)
        :addTo(self:GetView())

    UIKit:ttfLabel({
        text = _("注意：MODs并非官方人员，请勿告诉他们你的个人账号信息。"),
        size = 22,
        color = 0x615b44,
        dimensions = cc.size(520,0)
    }):align(display.CENTER_TOP, window.cx, desc:getPositionY() - desc:getContentSize().height - 50)
        :addTo(self:GetView())

end
return GameUISettingMod








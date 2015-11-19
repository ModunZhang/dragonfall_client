--
-- Author: Danny He
-- Date: 2015-03-28 16:57:58
--
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local Localize = import("..utils.Localize")
local GameUISettingAccount = class("GameUISettingAccount", WidgetPopDialog)


function GameUISettingAccount:ctor()
    GameUISettingAccount.super.ctor(self,722,_("账号绑定"),display.top-120)
end

function GameUISettingAccount:onEnter()
    GameUISettingAccount.super.onEnter(self)
    self:CheckGameCenter()

end
function GameUISettingAccount:CheckGameCenter()
    if ext.gamecenter.isAuthenticated() then
        local __,gcId = ext.gamecenter.getPlayerNameAndId()
        NetManager:getGcBindStatusPromise(gcId):done(function(response)
            ext.gamecenter.gc_bind = response.msg.isBind
            if not User:IsBindGameCenter() and not response.msg.isBind then
                NetManager:getBindGcIdPromise(gcId):done(function()
                    app:EndCheckGameCenterIf()
                end)
            end
            self:CreateUI()
            self:RefreshUI()
        end)
    else
        self:CreateUI()
        self:RefreshUI()
    end
end

function GameUISettingAccount:CreateUI()
    self:CreateAccountPanel()
    self:CreateGameCenterPanel()
    self:CreateFacebookPanel()

    -- 切换账号按钮
    cc.ui.UIPushButton.new({
        normal = "red_btn_up_186x66.png",
        pressed="red_btn_down_186x66.png"
    })
        :align(display.BOTTOM_CENTER, self:GetBody():getContentSize().width/2,  20)
        :addTo(self:GetBody())
        :setButtonLabel("normal", UIKit:commonButtonLable({
            text = _("切换账号")
        })):onButtonClicked(function()
        end)
end

function GameUISettingAccount:CreateGameCenterPanel()
    local bg_width,bg_height = 568,122
    self.gamecenter_panel = WidgetUIBackGround.new({width = bg_width,height=bg_height},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
        :align(display.TOP_CENTER, 304, self.account_panel:getPositionY() - 212)
        :addTo(self:GetBody())
    display.newSprite("icon_gameCenter_104x104.png"):align(display.LEFT_CENTER, 12, bg_height/2)
        :addTo(self.gamecenter_panel)
    self.gamecenter_bind_state_label = UIKit:ttfLabel({
        text = "gameCenter 名字（已绑定）gameCenter 名字（已绑定）gameCenter 名字（已绑定）gameCenter 名字（已绑定）",
        size = 20,
        color= 0x403c2f,
        dimensions = cc.size(260,0)
    }):align(display.LEFT_CENTER, 130, bg_height/2):addTo(self.gamecenter_panel)
    self.gamecenter_bind_button = cc.ui.UIPushButton.new({
        normal = "yellow_btn_up_148x58.png",
        pressed="yellow_btn_down_148x58.png"
    })
        :align(display.RIGHT_CENTER, bg_width - 10,  bg_height/2)
        :addTo(self.gamecenter_panel)
        :setButtonLabel("normal", UIKit:commonButtonLable({
            text = _("绑定")
        })):onButtonClicked(function()
        -- TODO
        end)
end
function GameUISettingAccount:CreateFacebookPanel()
    local bg_width,bg_height = 568,122
    self.facebook_panel = WidgetUIBackGround.new({width = bg_width,height=bg_height},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
        :align(display.TOP_CENTER, 304, self.gamecenter_panel:getPositionY() - 130)
        :addTo(self:GetBody())
    display.newSprite("icon_facebook_104x104.png"):align(display.LEFT_CENTER, 12, bg_height/2)
        :addTo(self.facebook_panel)
    self.facebook_bind_state_label = UIKit:ttfLabel({
        text = "gameCenter 名字（已绑定）gameCenter 名字（已绑定）gameCenter 名字（已绑定）gameCenter 名字（已绑定）",
        size = 20,
        color= 0x403c2f,
        dimensions = cc.size(260,0)
    }):align(display.LEFT_CENTER, 130, bg_height/2):addTo(self.facebook_panel)
    self.facebook_bind_button = cc.ui.UIPushButton.new({
        normal = "yellow_btn_up_148x58.png",
        pressed="yellow_btn_down_148x58.png"
    })
        :align(display.RIGHT_CENTER, bg_width - 10,  bg_height/2)
        :addTo(self.facebook_panel)
        :setButtonLabel("normal", UIKit:commonButtonLable({
            text = _("绑定")
        })):onButtonClicked(function()
        -- TODO
        end)
end
function GameUISettingAccount:CreateAccountPanel()
    local bg_width = 568
    local bg_height = 148
    self.account_panel = WidgetUIBackGround.new({width = bg_width,height=bg_height},WidgetUIBackGround.STYLE_TYPE.STYLE_6)
        :align(display.TOP_CENTER, 304, 680)
        :addTo(self:GetBody())
    local bg = display.newScale9Sprite("back_ground_548x40_1.png"):size(548,42):align(display.TOP_CENTER, bg_width/2, bg_height - 10):addTo(self.account_panel)
    UIKit:ttfLabel({
        text = _("当前账号"),
        size = 20,
        color = 0x615b44,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(bg):align(display.LEFT_CENTER,14,20)
    UIKit:ttfLabel({
        text = User.basicInfo.name.."(Lv"..User:GetLevel()..")",
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_RIGHT,
        color = 0x403c2f,
    }):addTo(bg):align(display.RIGHT_CENTER, 548 - 14, 20)

    local bg = display.newScale9Sprite("back_ground_548x40_2.png"):size(548,42):align(display.TOP_CENTER, bg_width/2, bg_height - 52):addTo(self.account_panel)
    UIKit:ttfLabel({
        text = _("状态"),
        size = 20,
        color = 0x615b44,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(bg):align(display.LEFT_CENTER,14,20)
    self.account_state_label = UIKit:ttfLabel({
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_RIGHT,
        color = 0x403c2f,
    }):addTo(bg):align(display.RIGHT_CENTER, 548 - 14, 20)

    local bg = display.newScale9Sprite("back_ground_548x40_1.png"):size(548,42):align(display.TOP_CENTER, bg_width/2, bg_height - 94):addTo(self.account_panel)
    UIKit:ttfLabel({
        text = _("所在服务器"),
        size = 20,
        color = 0x615b44,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(bg):align(display.LEFT_CENTER,14,20)

    UIKit:ttfLabel({
        text = string.format(_("World %s"),string.sub(User.serverId,-1,-1)),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_RIGHT,
        color = 0x403c2f,
    }):addTo(bg):align(display.RIGHT_CENTER, 548 - 14, 20)

    self.account_warn_label =  UIKit:ttfLabel({
        text = "",
        size = 20,
        color= 0x7e0000,
        dimensions = cc.size(500, 0)
    }):align(display.TOP_CENTER, 276, -26):addTo(self.account_panel)
end

function GameUISettingAccount:RefreshUI()
    if User:IsBindGameCenter() then
        self.account_state_label:setString(_("已绑定"))
        self.account_warn_label:setString(_("你的账号已经和GameCenter绑定"))
        self.account_warn_label:setColor(UIKit:hex2c3b(0x008b0a))
        if ext.gamecenter.isAuthenticated() then
            if ext.gamecenter.gc_bind == true then
                local playerName,gcId = ext.gamecenter.getPlayerNameAndId()
                self.gamecenter_bind_state_label:setString(string.format(_("%s(已绑定)"),playerName))
                self.gamecenter_bind_button:hide()
                if gcId == User.gcId then
                else
                end
            else -- 创建新账号
                self.gamecenter_bind_state_label:setString(_("与当前的Game Center账号进行绑定"))
            end
        else
            self.gamecenter_bind_state_label:setString(_("与当前的Game Center账号进行绑定"))
        end
    else -- 当前账号未绑定gc
        self.account_state_label:setString(_("未绑定"))
        self.account_warn_label:setString(_("你的账号尚未进行绑定，存在丢失风险"))
        self.account_warn_label:setColor(UIKit:hex2c3b(0x7e0000))
        if ext.gamecenter.isAuthenticated() then
            if ext.gamecenter.gc_bind == true then -- 当前登录的gc已绑定
            else
            end
        else
        end
    end
end

function GameUISettingAccount:ChangeAccountForceButtonClicked(button)
    if button.tips then
        UIKit:showMessageDialog(_("提示"), button.tips, function()
            local __,gcId = ext.gamecenter.getPlayerNameAndId()
            NetManager:getForceSwitchGcIdPromise(gcId)
        end,function()end)
    else
        local __,gcId = ext.gamecenter.getPlayerNameAndId()
        NetManager:getForceSwitchGcIdPromise(gcId)
    end
end

function GameUISettingAccount:CreateOrChangeAccountButtonClicked(button)
    if button.tips then
        UIKit:showMessageDialog(_("提示"), button.tips, function()
            local __,gcId = ext.gamecenter.getPlayerNameAndId()
            NetManager:getSwitchGcIdPromise(gcId)
        end,function()end)
    else
        local __,gcId = ext.gamecenter.getPlayerNameAndId()
        NetManager:getSwitchGcIdPromise(gcId)
    end

end

function GameUISettingAccount:GameCenterButtonClicked()
    UIKit:showMessageDialog(_("提示"), _("确定绑定GameCenter账号?"), function()
        ext.gamecenter.authenticate(true)
    end, function()end)
end

return GameUISettingAccount



--
-- Author: Kenny Dai
-- Date: 2016-06-13 15:23:18
--
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetDropItem = import("..widget.WidgetDropItem")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local GameUIModMute = class("GameUIModMute",WidgetPopDialog)


function GameUIModMute:ctor(chat)
    GameUIModMute.super.ctor(self,692,_("禁言"))
    self:DisableAutoClose()
    local targetPlayerId = chat.id
    -- bg
    local write_mail = self.body
    local r_size = write_mail:getContentSize()

    local titles_times = {
        _("5分钟"),
        _("30分钟"),
        _("1小时"),
        _("6小时"),
    }
    self.time_select = 1
    local ban_time = WidgetDropItem.new({title= string.format(_("禁言时间:%s"),titles_times[self.time_select])}, function(drop_item, ani)
        local is_open_with_ani = drop_item and ani
        if drop_item then
            drop_item:CreateSelectPanel(titles_times,self.time_select,function (select)
                local isChange = select ~= self.time_select
                self.time_select = select
                drop_item:SetTitle(string.format(_("禁言时间:%s"),titles_times[select]))
                if isChange then
                    scheduler.performWithDelayGlobal(function ()
                        if not tolua.isnull(drop_item) then
                            drop_item:OnClose()
                        end
                    end, 0.2)
                end
            end)
            drop_item:GetContent():setTouchEnabled(true)
            if self.ban_op:GetState() == WidgetDropItem.STATE.open then
                self.ban_op:OnClose()
            end
        end
    end):align(display.CENTER,r_size.width/2,r_size.height-60):addTo(write_mail,3)
    local titles_op = {
        _("辱骂玩家"),
        _("不当言语"),
        _("刷屏"),
        _("发广告"),
    }
    self.op_select = 1
    local ban_op = WidgetDropItem.new({title=string.format(_("禁言原因:%s"),titles_op[self.op_select])}, function(drop_item, ani)
        local is_open_with_ani = drop_item and ani
        if drop_item then
            drop_item:CreateSelectPanel(titles_op,self.op_select,function (select)
                local changed = select ~= self.op_select
                self.op_select = select
                drop_item:SetTitle(string.format(_("禁言原因:%s"),titles_op[select]))
                if changed then
                    scheduler.performWithDelayGlobal(function ()
                        if not tolua.isnull(drop_item) then
                            drop_item:OnClose()
                        end
                    end, 0.2)
                end
            end)
            drop_item:GetContent():setTouchEnabled(true)
        end
    end):align(display.CENTER,r_size.width/2,r_size.height-130):addTo(write_mail,2)
    self.ban_op = ban_op
    -- 分割线
    display.newScale9Sprite("dividing_line.png",r_size.width/2, r_size.height-180,cc.size(594,2),cc.rect(10,2,382,2)):addTo(write_mail)
    -- 内容
    UIKit:ttfLabel(
        {
            text = _("内容："),
            size = 20,
            color = 0x615b44
        }):align(display.LEFT_CENTER,20,r_size.height-210)
        :addTo(write_mail)
    -- 回复的邮件内容
    self.textView = ccui.UITextView:create(cc.size(580,362),display.newScale9Sprite("background_88x42.png"))
    local textView = self.textView
    textView:addTo(write_mail):align(display.CENTER_BOTTOM,r_size.width/2,90)
    textView:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    textView:setFont(UIKit:getEditBoxFont(), 24)
    textView:setMaxLength(1000)

    textView:setFontColor(cc.c3b(0,0,0))
    textView:registerScriptTextViewHandler(function(event,textView)
        if ban_time:GetState() == WidgetDropItem.STATE.open then
            ban_time:OnClose()
        end
        if ban_op:GetState() == WidgetDropItem.STATE.open then
            ban_op:OnClose()
        end
    end)

    -- 发送按钮
    local send_label = UIKit:ttfLabel({
        text = _("确认"),
        size = 20,
        color = 0xfff3c7,
        shadow = true})

    self.send_button = WidgetPushButton.new(
        {normal = "yellow_btn_up_148x58.png", pressed = "yellow_btn_down_148x58.png"},
        {scale9 = false}
    ):setButtonLabel(send_label)
        :addTo(write_mail):align(display.CENTER, r_size.width/2, 50)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                local mute_minutes = {5,30,60,360}
                NetManager:getMutePlayerPromise(targetPlayerId,mute_minutes[self.time_select],titles_op[self.op_select]..(self.textView:getText() == "" and "" or ", "..self.textView:getText())):done(function ()
                    GameGlobalUI:showTips(_("提示"),_("禁言成功"))
                    self:LeftButtonClicked()
                end)
            end
        end)
    textView:setRectTrackedNode(self.send_button)

end

return GameUIModMute








   













--
-- Author: Kenny Dai
-- Date: 2016-06-14 14:17:42
--
local GameUIChatChannel = import(".GameUIChatChannel")
local WidgetBackGroundTabButtons = import("..widget.WidgetBackGroundTabButtons")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetChatSendPushButton = import("..widget.WidgetChatSendPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local UIListView = import(".UIListView")
local window = import("..utils.window")
local LISTVIEW_WIDTH    = 556
local GameUIModChatChannel = class("GameUIModChatChannel", GameUIChatChannel)
function GameUIModChatChannel:ctor()
    GameUIModChatChannel.super.ctor(self,"global",_("MOD 聊天"))
end

function GameUIModChatChannel:CreateTabButtons()
    local tab_buttons = WidgetBackGroundTabButtons.new({
        {
            label = _("世界"),
            tag = "global",
            default = self.default_tag == "global",
        },
        {
            label = _("已禁言玩家"),
            tag = "mutePlayer",
            default = self.default_tag == "mutePlayer",
        },
    },
    function(tag)
        self._channelType = tag
        self:ShowTipsIf()
        self:RefreshListView()
        if self.tab_buttons then
            self.tab_buttons:SetGreenTipsShow(tag,false)
        end
        if tag == "global" then
            app:GetChatManager():setChannelReadStatus(tag,false)
            app:GetGameDefautlt():setStringForKey("LAST_CHAT_CHANNEL","1")
            display.getRunningScene():GetHomePage():ChangeChatChannel(1)
        end
        if tag == "mutePlayer" then
            self:ListMutePlayer()
        end
    end):addTo(self:GetView()):pos(window.cx, window.bottom + 34)
    local channelReadStatus = app:GetChatManager():getAllChannelReadStatus()
    for k,v in pairs(channelReadStatus) do
        if k ~= self.default_tag then
            tab_buttons:SetGreenTipsShow(k,v)
        end
    end
    self.tab_buttons = tab_buttons
end
function GameUIModChatChannel:RefreshListView()
    if not self._channelType then
        self._channelType = 'global'
    end
    if self._channelType == 'global' then
        self.listView:show()
        self.emojiButton:show()
        self.editbox:show()
        self.sendChatButton:show()
        self.list_end_1:show()
        self.list_end_2:show()
        self.dataSource_ = clone(self:FetchCurrentChannelMessages())
        self.listView:reload()
        if self.mute_node then
            self.mute_node:hide()
        end
    else
        self.listView:hide()
        self.emojiButton:hide()
        self.editbox:hide()
        self.sendChatButton:hide()
        self.list_end_1:hide()
        self.list_end_2:hide()
        if self.mute_node then
            self.mute_node:show()
        end
    end
end
function GameUIModChatChannel:CreateTextFieldBody()
    local emojiButton = WidgetPushButton.new({
        normal = "chat_button_n_68x50.png",
        pressed= "chat_button_h_68x50.png",
    }):onButtonClicked(function(event)
        self:CreateEmojiPanel()
    end):addTo(self:GetView()):align(display.LEFT_TOP, window.left+40, window.top - 90)
    display.newSprite("chat_emoji_37x37.png"):addTo(emojiButton):pos(34,-25)
    self.emojiButton = emojiButton
    local function onEdit(event, editbox)
        if event == "return" then
            if not self.sendChatButton:CanSendChat() then
                GameGlobalUI:showTips(_("提示"),_("对不起你的聊天频率太频繁"))
                return
            end
            local msg = editbox:getText()
            if not msg or string.len(string.trim(msg)) == 0 then
                GameGlobalUI:showTips(_("错误"), _("聊天内容不能为空"))
                return
            end
            editbox:setText('')
            self:GetChatManager():SendModChat(msg,function()
                if self.sendChatButton then
                    self.sendChatButton:StartTimer()
                end
            end)
        elseif event == "changed" then
            local noemoj = string.trimEmoj(editbox:getText())
            if noemoj ~= editbox:getText() then
                editbox:setText(noemoj)
            end
        end
    end

    local editbox = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "input_box.png",
        size = cc.size(417,51),
        listener = onEdit,
    })
    editbox:setPlaceHolder(string.format(_("最多可输入%d字符"),140))
    editbox:setMaxLength(140)
    editbox:setFont(UIKit:getEditBoxFont(),22)
    editbox:setFontColor(cc.c3b(0,0,0))
    editbox:setPlaceholderFontColor(cc.c3b(204,196,158))
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    editbox:align(display.LEFT_TOP,emojiButton:getPositionX() + 73,window.top - 90):addTo(self:GetView())
    self.editbox = editbox

    local sendChatButton = WidgetChatSendPushButton.new():align(display.LEFT_TOP, editbox:getPositionX() + 422, window.top - 90):addTo(self:GetView())
    sendChatButton:onButtonClicked(function()
        local msg = editbox:getText()
        if not msg or string.len(string.trim(msg)) == 0 then
            GameGlobalUI:showTips(_("错误"), _("聊天内容不能为空"))
            return
        end
        editbox:setText('')
        self:GetChatManager():SendModChat(msg,function()
            if sendChatButton and sendChatButton.StartTimer then
                sendChatButton:StartTimer()
            end
        end)
    end)
    self.sendChatButton = sendChatButton
end
function GameUIModChatChannel:CreateListView()
    self.list_end_1 = display.newSprite("listview_edging.png"):align(display.BOTTOM_CENTER, window.cx, window.bottom + 794):addTo(self:GetView())
    self.listView = UIListView.new {
        viewRect = cc.rect(window.left + (window.width - LISTVIEW_WIDTH)/2, window.bottom+100, LISTVIEW_WIDTH, 700),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        alignment = cc.ui.UIListView.ALIGNMENT_LEFT,
        async = true
    }:onTouch(handler(self, self.listviewListener)):addTo(self:GetView())
    self.listView:setDelegate(handler(self, self.sourceDelegate))
    self.list_end_2 = display.newSprite("listview_edging.png"):align(display.BOTTOM_CENTER, window.cx, window.bottom + 89):addTo(self:GetView()):flipY(true)
end
function GameUIModChatChannel:ListMutePlayer()
    if not self.mute_listview then
        local list,list_node = UIKit:commonListView({
            async = true, --异步加载
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            viewRect = cc.rect(41, window.bottom_top,568 , window.betweenHeaderAndTab - 20),
        },false,true)
        list:setDelegate(handler(self, self.Delegate))
        list_node:addTo(self:GetView()):align(display.BOTTOM_CENTER, window.cx,window.bottom_top+20)

        self.mute_listview = list
        self.mute_node = list_node
    end
    self.mute_listview:removeAllItems()
    NetManager:getMutedPlayerListPromise():done(function (response)
        LuaUtils:outputTable("response",response)
        self.source_data = response.msg.datas
        self.mute_listview:reload()
    end)
end
function GameUIModChatChannel:Delegate( listView, tag, idx )
    if cc.ui.UIListView.COUNT_TAG == tag then
        return self.source_data and #self.source_data or 0
    elseif cc.ui.UIListView.CELL_TAG == tag then
        local item
        local content
        item = listView:dequeueItem()
        if not item then
            item = listView:newItem()
            content = self:CreateMutePlayerItem()
            item:addContent(content)
        else
            content = item:getContent()
        end
        content:SetData(idx)
        local size = content:getContentSize()
        item:setItemSize(size.width, size.height)
        return item
    end
end
function GameUIModChatChannel:CreateMutePlayerItem()
    local item_width,item_height = 568, 124
    local content = WidgetUIBackGround.new({width = item_width,height = item_height},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
    local player_icon = UIKit:GetPlayerCommonIcon(1):addTo(content):align(display.LEFT_CENTER,10,item_height/2)
    content.player_icon = player_icon
    local title_bg = display.newScale9Sprite("title_blue_430x30.png",0,0, cc.size(432,30), cc.rect(10,10,410,10))
        :align(display.TOP_LEFT,player_icon:getPositionX() + player_icon:getContentSize().width + 10,item_height - 15)
        :addTo(content)
    local button = WidgetPushButton.new()
        :addTo(content):align(display.LEFT_CENTER,10,item_height/2)
    button:setContentSize(player_icon:getContentSize())
    local name = UIKit:ttfLabel({
        text = "",
        size = 22,
        color = 0xffedae
    }):align(display.LEFT_CENTER, 10, title_bg:getContentSize().height/2)
        :addTo(title_bg)
    local time = UIKit:ttfLabel({
        text = "",
        size = 20,
        color = 0x7e0000
    }):align(display.LEFT_CENTER, title_bg:getPositionX() + 10, 35)
        :addTo(content)

    local endPre = UIKit:ttfLabel({
        text = _("后解除禁言"),
        size = 20,
        color = 0x403c2f
    }):align(display.LEFT_CENTER, time:getPositionX() + time:getContentSize().width + 10, 35)
        :addTo(content)
    local unMute = WidgetPushButton.new({normal = "red_btn_up_148x58.png",pressed = "red_btn_down_148x58.png"}):setButtonLabel(UIKit:commonButtonLable({
        color = 0xfff3c7,
        text  = _("立即解除")
    })):align(display.RIGHT_BOTTOM,item_width - 20, 10):addTo(content)
    local parent = self
    function content:SetData(idx)
        local data = parent.source_data[idx]
        name:setString(data.name)
        if self.player_icon then
            self.player_icon:removeFromParent()
        end
        self.player_icon = UIKit:GetPlayerCommonIcon(data.icon):addTo(self):align(display.LEFT_CENTER,10,item_height/2)
        unMute:removeEventListenersByEvent("CLICKED_EVENT")
        unMute:onButtonClicked(function(event)
            NetManager:getUnMutePlayerPromise(data._id):done(function ()
                GameGlobalUI:showTips(_("提示"), _("解除禁言成功"))
                parent:ListMutePlayer()
            end)
        end)
        button:removeEventListenersByEvent("CLICKED_EVENT")
        button:onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI("GameUIAllianceMemberInfo",false,data._id,nil,data.serverId):AddToCurrentScene(true)
            end
        end)
        scheduleAt(self, function()
            if data.finishTime/1000 - app.timer:GetServerTime() <= 0 then
                parent:ListMutePlayer()
            else
                time:setString(GameUtils:formatTimeStyle1(data.finishTime/1000 - app.timer:GetServerTime()))
            end
        end)
        endPre:setPositionX(time:getPositionX() + time:getContentSize().width + 10)
    end
    return content
end
return GameUIModChatChannel








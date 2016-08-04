--
-- Author: Kenny Dai
-- Date: 2016-04-21 10:25:33
--
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local window = import("..utils.window")
local RichText = import("..widget.RichText")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local UIListView = import(".UIListView")
local NetService = import('..service.NetService')
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetChatSendPushButton = import("..widget.WidgetChatSendPushButton")

local LISTVIEW_WIDTH    = 536
local PLAYERMENU_ZORDER = 201
local BASE_CELL_HEIGHT  = 82
local CELL_FIX_WIDTH    = 464
local NAME_COLOR_SYSTEM = UIKit:hex2c3b(0x245f00)
local NAME_COLOR_NORMAL = UIKit:hex2c3b(0x005e6c)
local GameUIGMChat = class("GameUIGMChat", WidgetPopDialog)

function GameUIGMChat:ctor()
    GameUIGMChat.super.ctor(self,514,_("GM聊天"),window.top - 170)
    self.chatManager = app:GetChatManager()
end
function GameUIGMChat:GetChatManager()
    return self.chatManager
end
function GameUIGMChat:onEnter()
    GameUIGMChat.super.onEnter(self)
    self:CreateChatList()
    self:CreateTextFieldBody()
    self:DisableAutoClose(true)
    self.close_btn:removeAllEventListeners()
    self.close_btn:onButtonClicked(function (event)
        if event.name == "CLICKED_EVENT" then
            app:GetAudioManager():PlayeEffectSoundWithKey("NORMAL_DOWN")
            UIKit:showMessageDialog(_("提示"),
                _("关闭该窗口后将无法继续与GM聊天，确认关闭吗？"),
                function ()
                    self:LeftButtonClicked()
                end,function ()
                end)
        end
    end)
end
function GameUIGMChat:CreateChatList()
    local body = self.body
    local b_size = body:getContentSize()
    local list_bg = WidgetUIBackGround.new({width = 572 , height = 382},WidgetUIBackGround.STYLE_TYPE.STYLE_3)
        :align(display.TOP_CENTER, b_size.width/2, b_size.height - 40)
        :addTo(body)
    local record_list = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(14,10, 544,362),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        async = true, --异步加载
    }:addTo(list_bg)
    record_list:setDelegate(handler(self, self.DelegateChatRecord))
    self.record_list = record_list
    local chat_record = self:GetAllListData()
    if chat_record and type(chat_record) == "table" then
        self.record_list:reloadSyn()
    else
        NetManager:getAllGMChatPromise():done(function(response)
            dump(response)
            LuaUtils:outputTable("getAllGMChatPromise",response)
            for i,chat in ipairs(response.msg.chats) do
                self:GetChatManager():AddGMChatRecord(chat)
            end
            self.record_list:reloadSyn()
        end)
    end
end
function GameUIGMChat:DelegateChatRecord( listView, tag, idx )
    if cc.ui.UIListView.COUNT_TAG == tag then
        return self:GetAllListData() and #self:GetAllListData() or 0
    elseif cc.ui.UIListView.CELL_TAG == tag then
        local item
        local content
        local data = self:GetAllListData()[idx]
        item = listView:dequeueItem()
        if not item then
            item = listView:newItem()
            content = self:GetChatItemCell()
            item:addContent(content)
        else
            content = item:getContent()
        end
        local height = self:HandleCellUIData(content,data)
        item:setItemSize(LISTVIEW_WIDTH,BASE_CELL_HEIGHT + height)
        return item
    end
end
-- 收到新消息
function GameUIGMChat:OnNewChatComing()
    self.record_list:reloadSyn()
end
function GameUIGMChat:GetAllListData()
    return self:GetChatManager():GetAllGMChat()
end

function GameUIGMChat:GetChatItemCell()
    local content = display.newNode()
    local other_content = display.newNode()
    local bottom = display.newScale9Sprite("chat_bubble_bottom_484x14.png",
        nil,nil,cc.size(464,14),centerRect(464,14))
        :addTo(other_content):align(display.RIGHT_BOTTOM,LISTVIEW_WIDTH, 0)
    local middle = display.newScale9Sprite("chat_bubble_middle_484x20.png",
        nil,nil,cc.size(464,20),centerRect(464,20))
        :addTo(other_content):align(display.RIGHT_BOTTOM, LISTVIEW_WIDTH, 12)
    local header = display.newScale9Sprite("chat_bubble_header_484x38.png",
        nil,nil,cc.size(464,38),centerRect(464,38)):addTo(other_content):align(display.RIGHT_BOTTOM, LISTVIEW_WIDTH,32)
    local chat_icon = self:GetChatIcon():addTo(other_content):align(display.LEFT_TOP, 3, 72)
    local system_label = UIKit:ttfLabel({
        text = _("官方"),
        size = 14,
        color= 0xe2d9b8,
        align = cc.TEXT_ALIGNMENT_CENTER,
    })
    local system_flag = display.newScale9Sprite("chat_system_flag_42x20.png",nil,nil,cc.size(system_label:getContentSize().width + 12,20),cc.rect(6,6,30,8))
        :align(display.LEFT_BOTTOM, 7, 15):addTo(header)
    system_label:addTo(system_flag):align(display.CENTER, system_flag:getContentSize().width/2,10)
    local from_label = UIKit:ttfLabel({
        text = "[ P/L ] SkinnMart",
        size = 18,
        color= 0x005e6c,
        align = cc.TEXT_ALIGNMENT_LEFT,
    }):align(display.LEFT_BOTTOM, 7, 15):addTo(header)

    local vip_label =  UIKit:ttfLabel({
        text = "VIP 99",
        size = 14,
        color= 0xdd7f00,
        align = cc.TEXT_ALIGNMENT_LEFT,
    }):align(display.LEFT_BOTTOM, 22 + from_label:getContentSize().width, 17):addTo(header)

    local time_label =  UIKit:ttfLabel({
        text = "4 secs ago",
        size = 14,
        color= 0x403c2f,
        align = cc.TEXT_ALIGNMENT_RIGHT,
    }):align(display.BOTTOM_RIGHT, 440, 16):addTo(header)

    local content_label = RichText.new({width = 420,size = 22,color = 0x403c2f})
    content_label:Text("")
    content_label:align(display.LEFT_BOTTOM, 10, 0):addTo(middle)

    -- set var
    other_content.system_flag = system_flag
    other_content.system_flag_with = system_flag:getContentSize().width
    other_content.content_label = content_label
    other_content.time_label = time_label
    other_content.translation_sp = translation_sp
    other_content.vip_label = vip_label
    other_content.from_label = from_label
    other_content.chat_icon = chat_icon
    other_content.header = header
    other_content.middle = middle
    other_content.bottom = bottom
    other_content:size(LISTVIEW_WIDTH,BASE_CELL_HEIGHT)
    content:addChild(other_content)
    content.other_content = other_content
    -- end of other_content
    -- mine
    local mine_content = display.newNode()
    local bottom = display.newScale9Sprite("chat_bubble_bottom_484x14.png",
        nil,nil,cc.size(464,14),centerRect(464,14))
        :addTo(mine_content):align(display.LEFT_BOTTOM, 0, 0)
    local middle = display.newScale9Sprite("chat_bubble_middle_484x20.png",
        nil,nil,cc.size(464,20),centerRect(464,20))
        :addTo(mine_content):align(display.LEFT_BOTTOM, 0, 12)
    local header = display.newScale9Sprite("chat_bubble_header_484x38.png",
        nil,nil,cc.size(464,38),centerRect(464,38)):addTo(mine_content):align(display.LEFT_BOTTOM, 0, 32)
    local chat_icon = self:GetChatIcon():addTo(mine_content):align(display.RIGHT_TOP, LISTVIEW_WIDTH - 3, 72)

    local from_label = UIKit:ttfLabel({
        text = "[ P/L ] SkinnMart",
        size = 18,
        color= 0x005e6c,
        align = cc.TEXT_ALIGNMENT_LEFT,
    }):align(display.LEFT_BOTTOM, 7, 15):addTo(header)

    local vip_label =  UIKit:ttfLabel({
        text = "VIP 99",
        size = 14,
        color= 0xdd7f00,
        align = cc.TEXT_ALIGNMENT_LEFT,
    }):align(display.LEFT_BOTTOM, 22 + from_label:getContentSize().width, 17):addTo(header)

    local time_label =  UIKit:ttfLabel({
        text = "4 secs ago",
        size = 14,
        color= 0x403c2f,
        align = cc.TEXT_ALIGNMENT_RIGHT,
    }):align(display.BOTTOM_RIGHT, 458, 16):addTo(header)


    local content_label = RichText.new({width = 420,size = 22,color = 0x403c2f})
    content_label:Text("")
    content_label:align(display.LEFT_BOTTOM, 10, 0):addTo(middle)

    --set var
    mine_content.content_label = content_label
    mine_content.bottom = bottom
    mine_content.middle = middle
    mine_content.header = header
    mine_content.chat_icon = chat_icon
    mine_content.from_label = from_label
    mine_content.vip_label = vip_label
    mine_content.time_label = time_label

    mine_content:size(LISTVIEW_WIDTH,BASE_CELL_HEIGHT)
    content:addChild(mine_content)
    content.mine_content = mine_content
    --all end
    content:size(LISTVIEW_WIDTH,BASE_CELL_HEIGHT)
    return content
end

function GameUIGMChat:HandleCellUIData(mainContent,chat,update_time)
    if not chat then return end
    if type(update_time) ~= 'boolean' then
        update_time = true
    end
    local isSelf = User:Id() == chat.id
    local isVip = chat.vip and chat.vip > 0
    local currentContent = nil
    if isSelf then
        mainContent.other_content:hide()
        currentContent = mainContent.mine_content
    else
        mainContent.mine_content:hide()
        currentContent = mainContent.other_content
    end
    currentContent:show()

    local bottom = currentContent.bottom
    local middle = currentContent.middle
    local header = currentContent.header

    --header node
    local timeLabel = currentContent.time_label
    local titleLabel = currentContent.from_label
    local vipLabel = currentContent.vip_label
    local name_title = chat.allianceTag == "" and chat.name or string.format("[ %s ] %s",chat.allianceTag,chat.name)
    titleLabel:setString(name_title)
    if not isSelf then
        local system_flag = currentContent.system_flag
        if string.lower(chat.id) == 'system' and system_flag then
            system_flag:show()
            titleLabel:pos(17 + currentContent.system_flag_with, 15)
            titleLabel:setColor(NAME_COLOR_SYSTEM)
        else
            system_flag:hide()
            titleLabel:setColor(NAME_COLOR_NORMAL)
            titleLabel:pos(7, 15)
        end
    end
    if chat.vipActive then
        vipLabel:setString('VIP ' .. DataUtils:getPlayerVIPLevel(chat.vip))
        vipLabel:setPositionX(titleLabel:getPositionX() + titleLabel:getContentSize().width + 15)
        vipLabel:show()
    else
        vipLabel:hide()
    end
    if update_time or not chat.timeStr then
        chat.timeStr = NetService:formatTimeAsTimeAgoStyleByServerTime(chat.time)
    end
    timeLabel:setString(chat.timeStr)

    local palyerIcon = currentContent.chat_icon -- TODO:
    palyerIcon.icon:setTexture(UIKit:GetPlayerIconImage(chat.icon))
    local content_label = currentContent.content_label
    local labelText = chat.text
    if chat._translate_ and chat._translateMode_ then
        labelText = chat._translate_
    end
    if string.lower(chat.id) == 'system' then
        labelText = self:GetChatManager():GetEmojiUtil():FormatSystemChat(labelText)
        content_label:Text(labelText) -- 聊天信息
    else
        labelText = self:GetChatManager():GetEmojiUtil():ConvertEmojiToRichText(labelText)
        if string.find(labelText,"\"url\":\"report:") then
            content_label:Text(labelText,nil,function ( url )
                local info = string.split(url,":")
                NetManager:getReportDetailPromise(info[2],info[3]):done(function ( response )
                    local report = Report:DecodeFromJsonData(clone(response.msg.report))
                    report:SetPlayerId(info[2])
                    if report:Type() == "strikeCity" or report:Type()== "cityBeStriked"
                        or report:Type() == "villageBeStriked" or report:Type()== "strikeVillage" then
                        UIKit:newGameUI("GameUIStrikeReport", report):AddToCurrentScene(true)
                    elseif report:Type() == "attackCity" or report:Type() == "attackVillage" then
                        UIKit:newGameUI("GameUIWarReport", report):AddToCurrentScene(true)
                    elseif report:Type() == "collectResource" then
                        UIKit:newGameUI("GameUICollectReport", report):AddToCurrentScene(true)
                    elseif report:Type() == "attackMonster" then
                        UIKit:newGameUI("GameUIMonsterReport", report):AddToCurrentScene(true)
                    elseif report:Type() == "attackShrine" then
                        UIKit:newGameUI("GameUIShrineReportInMail", report):AddToCurrentScene(true)
                    end
                    app:GetAudioManager():PlayeEffectSoundWithKey("OPEN_MAIL")
                end)
            end)
        else
            content_label:Text(labelText) -- 聊天信息
        end
    end
    content_label:align(display.LEFT_BOTTOM, 10, 0)
    if not isSelf then
        --重新布局
        local adjustFunc = function()
            local height = content_label:getCascadeBoundingBox().height or 0
            height = math.max(height,20)
            middle:setContentSize(cc.size(CELL_FIX_WIDTH,height))
            header:align(display.RIGHT_BOTTOM, LISTVIEW_WIDTH, bottom:getContentSize().height+middle:getContentSize().height - 2)
            local fix_height = height - 20
            palyerIcon:align(display.LEFT_TOP,3, bottom:getContentSize().height+middle:getContentSize().height + header:getContentSize().height)
            local final_height = BASE_CELL_HEIGHT + fix_height
            mainContent.other_content:size(LISTVIEW_WIDTH,final_height)
            mainContent.mine_content:size(LISTVIEW_WIDTH,final_height)
            mainContent:size(LISTVIEW_WIDTH,final_height)
            return fix_height
        end
        mainContent.adjustFunc = adjustFunc
        return adjustFunc()
    else
        local height = content_label:getCascadeBoundingBox().height or 0
        height = math.max(height,20)
        local fix_height = height - 20
        middle:setContentSize(cc.size(CELL_FIX_WIDTH,height))
        header:align(display.LEFT_BOTTOM, 0, bottom:getContentSize().height+middle:getContentSize().height - 2)
        palyerIcon:align(display.RIGHT_TOP,LISTVIEW_WIDTH - 3,bottom:getContentSize().height+middle:getContentSize().height + header:getContentSize().height)
        local final_height = BASE_CELL_HEIGHT + fix_height
        mainContent.other_content:size(LISTVIEW_WIDTH,final_height)
        mainContent.mine_content:size(LISTVIEW_WIDTH,final_height)
        mainContent:size(LISTVIEW_WIDTH,final_height)
        return fix_height
    end
end
function GameUIGMChat:GetChatIcon(icon)
    local bg = display.newSprite("box_102x102.png", nil, nil, {class=cc.FilteredSpriteWithOne}):scale(0.5)
    local icon = display.newSprite(UIKit:GetPlayerIconImage(1), nil, nil, {class=cc.FilteredSpriteWithOne}):addTo(bg):align(display.CENTER,51,51)
        :scale(0.75)
    bg.icon = icon
    return bg
end
function GameUIGMChat:CreateTextFieldBody()
    local body = self.body
    local b_size = body:getContentSize()
    local emojiButton = WidgetPushButton.new({
        normal = "chat_button_n_68x50.png",
        pressed= "chat_button_h_68x50.png",
    }):onButtonClicked(function(event)
        self:CreateEmojiPanel()
    end):addTo(body):align(display.LEFT_TOP, 24,  70)
    display.newSprite("chat_emoji_37x37.png"):addTo(emojiButton):pos(34,-25)

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
            self:GetChatManager():SendGMChat(msg,function(response)
                dump(response)
                self:AddSelfChat(msg)
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
    editbox:align(display.LEFT_TOP,emojiButton:getPositionX() + 73,70):addTo(body)
    self.editbox = editbox

    local sendChatButton = WidgetChatSendPushButton.new():align(display.LEFT_TOP, editbox:getPositionX() + 422, 70):addTo(body)
    sendChatButton:onButtonClicked(function()
        local msg = editbox:getText()
        if not msg or string.len(string.trim(msg)) == 0 then
            GameGlobalUI:showTips(_("错误"), _("聊天内容不能为空"))
            return
        end
        editbox:setText('')
        self:GetChatManager():SendGMChat(msg,function(response)
            self:AddSelfChat(msg)
            dump(response)
            if sendChatButton and sendChatButton.StartTimer then
                sendChatButton:StartTimer()
            end
        end)
    end)
    self.sendChatButton = sendChatButton
end
-- 自己发出的消息添加到本地缓存
function GameUIGMChat:AddSelfChat(msg)
    local chat_record = {
        ["id"] = User._id,
        ["text"] = msg,
        ["vipActive"] = UtilsForVip:IsVipActived(User),
        ["allianceTag"] = Alliance_Manager:GetMyAlliance():IsDefault() and "" or Alliance_Manager:GetMyAlliance().basicInfo.tag,
        ["serverId"] = User.serverId,
        ["name"] = User.basicInfo.name,
        ["time"] = app.timer:GetServerTime()*1000,
        ["allianceId"] = Alliance_Manager:GetMyAlliance():IsDefault() and "" or Alliance_Manager:GetMyAlliance()._id,
        ["icon"] = User.basicInfo.icon,
        ["vip"] = User.basicInfo.vipExp,}

    self:GetChatManager():AddGMChatRecord(chat_record)
    self:OnNewChatComing()
end
function GameUIGMChat:CreateEmojiPanel()
    local UIEmojiSelect = UIKit:newGameUI("GameUIEmojiSelect",function(code)
        local text = self.editbox:getText()
        self.editbox:setText(string.trim(text) .. code)
    end):AddToCurrentScene(true)
    UIEmojiSelect:getChildByTag(2101):setPositionY(window.bottom+400)
end
return GameUIGMChat





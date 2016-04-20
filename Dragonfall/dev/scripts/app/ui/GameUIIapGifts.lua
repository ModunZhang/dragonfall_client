--
-- Author: Kenny Dai
-- Date: 2016-04-19 17:14:52
--
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local window = import("..utils.window")
local RichText = import("..widget.RichText")
local WidgetPushButton = import("..widget.WidgetPushButton")

local GameUIIapGifts = class("GameUIIapGifts", WidgetPopDialog)

function GameUIIapGifts:ctor()
    GameUIIapGifts.super.ctor(self,764,_("联盟礼包"),window.top - 140)
end
function GameUIIapGifts:onEnter()
    GameUIIapGifts.super.onEnter(self)
    local body = self.body
    local b_size = body:getContentSize()
    local list,list_node = UIKit:commonListView({
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(0,0,556,700),
        async = true,
    })
    list_node:addTo(body):pos(25,28)
    self.award_list = list
    self.award_list_view = list_node
    self.award_list:setDelegate(handler(self, self.sourceDelegateAwardList))
    User:AddListenOnType(self, "iapGifts")
    self:RefreshAwardList()
end

function GameUIIapGifts:RefreshAwardList()
    self:RefreshAwardListDataSource()
    self.award_list:reload()
    self.award_list:stopAllActions()
    scheduleAt(self,function()
        for k,v in pairs(User.iapGifts) do
            self:OnIapGiftTimer(v)
        end
    end)
end

function GameUIIapGifts:RefreshAwardListDataSource()
    self.award_dataSource = {}
    self.award_logic_index_map = {}
    local data = {}
    for __,v in pairs(User.iapGifts) do
        table.insert(data,v)
    end

    table.sort( data,function(a,b)
        return User:GetIapGiftTime(a) > User:GetIapGiftTime(b)
    end)
    for index,v in ipairs(data) do
        self.award_logic_index_map[v.id] = index
        table.insert(self.award_dataSource,v)
    end
end

function GameUIIapGifts:OnIapGiftTimer(iapGift)
    if not self.award_logic_index_map then return end
    local index = self.award_logic_index_map[iapGift.id]
    local item = self.award_list:getItemWithLogicIndex(index)
    if not item then return end
    local content = item:getContent()
    local time = User:GetIapGiftTime(iapGift) - app.timer:GetServerTime()
    if time >= 0 then
        content.time_out_label:hide()
        if content.red_btn then
            content.red_btn:hide()
        end
        content.time_label:setString(GameUtils:formatTimeStyle1(time))
        content.time_label:show()
        content.time_desc_label:show()
        if content.yellow_btn then
            content.yellow_btn:show()
        end

    else
        content.time_label:hide()
        content.time_desc_label:hide()
        if content.yellow_btn then
            content.yellow_btn:hide()
        end
        content.time_out_label:show()
        if content.red_btn then
            content.red_btn:show()
        end
        self.award_logic_index_map[index] = nil -- remove refresh item event
    end
end

function GameUIIapGifts:sourceDelegateAwardList(listView, tag, idx)
    if cc.ui.UIListView.COUNT_TAG == tag then
        return #self.award_dataSource
    elseif cc.ui.UIListView.CELL_TAG == tag then
        local item
        local content
        local data = self.award_dataSource[idx]
        item = self.award_list:dequeueItem()
        if not item then
            item = self.award_list:newItem()
            content = self:GetAwardListContent()
            item:addContent(content)
        else
            content = item:getContent()
        end
        self:FillAwardItemContent(content,data,idx)
        item:setItemSize(556,164)
        return item
    else
    end
end

function GameUIIapGifts:GetAwardListContent()
    local content = WidgetUIBackGround.new({width = 556,height = 149},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
    local title_bg = display.newSprite("activity_title_552x42.png"):align(display.TOP_CENTER,288,145):addTo(content)
    local title_label = UIKit:ttfLabel({
        text = "",
        size = 22,
        color= 0xfed36c
    }):align(display.CENTER,276, 21):addTo(title_bg)
    display.newSprite("activity_box_552x112.png"):align(display.CENTER_BOTTOM,288, 10):addTo(content,2)
    local icon_bg = display.newSprite("activity_icon_box_78x78.png"):align(display.LEFT_BOTTOM, 20, 20):addTo(content)
    local reward_icon = display.newSprite("activity_icon_box_78x78.png", 39, 39):addTo(icon_bg)
    local contenet_label = RichText.new({width = 400,size = 20,color = 0x403c2f})
    local str = "[{\"type\":\"text\", \"value\":\"%s\"},{\"type\":\"text\", \"value\":\"%s\"}]"
    str = string.format(str,_("盟友"),_("赠送!"))
    contenet_label:Text(str):align(display.LEFT_BOTTOM,115,67):addTo(content)

    local time_out_label = UIKit:ttfLabel({
        text = _("已过期。请每日登陆关注"),
        color= 0x943a09,
        size = 20
    }):align(display.LEFT_BOTTOM,115,31):addTo(content)


    local time_label = UIKit:ttfLabel({
        text = "00:00:00",
        color= 0x008b0a,
        size = 20
    }):align(display.LEFT_BOTTOM,115,31):addTo(content)
    local time_desc_label =  UIKit:ttfLabel({
        text = _("到期,请尽快领取"),
        color= 0x403c2f,
        size = 20
    }):align(display.LEFT_BOTTOM,time_label:getPositionX()+time_label:getContentSize().width,31):addTo(content)

    content.title_label = title_label
    content.reward_icon = reward_icon
    content.contenet_label = contenet_label
    content.time_out_label = time_out_label
    content.time_label = time_label
    content.time_desc_label = time_desc_label
    content.yellow_btn = yellow_btn
    content.red_btn = red_btn
    content:size(556,164)
    return content
end

function GameUIIapGifts:FillAwardItemContent(content,data,idx)
    content.idx = idx
    content.reward_icon:setTexture(UILib.item[data.name])
    content.reward_icon:scale(0.6)
    content.title_label:setString(string.format(_("获得%s"),Localize_item.item_name[data.name]))
    local str = "[{\"type\":\"text\", \"value\":\"%s\"},{\"type\":\"text\", \"value\":\"%s\"}]"
    str = string.format(str,_("盟友"),_("赠送!"))
    content.contenet_label:Text(str):align(display.LEFT_BOTTOM,115,67)
    local time = User:GetIapGiftTime(data) - app.timer:GetServerTime()
    content.time_label:setString(GameUtils:formatTimeStyle1(time))
    if content.yellow_btn then
        content.yellow_btn:removeSelf()
    end
    if content.red_btn then
        content.red_btn:removeSelf()
    end
    if time < 0 then
        content.time_label:hide()
        content.time_desc_label:hide()
        content.time_out_label:show()
        local red_btn = WidgetPushButton.new({
            normal = "red_btn_up_148x58.png",
            pressed= "red_btn_down_148x58.png"
        })
            :align(display.BOTTOM_RIGHT, 556, 18)
            :addTo(content)
            :setButtonLabel("normal", UIKit:commonButtonLable({
                text = _("移除"),
            }))
            :onButtonClicked(function()
                self:OnAwardButtonClicked(content.idx)
            end)
        content.red_btn = red_btn
    else
        content.time_label:show()
        content.time_desc_label:show()
        content.time_out_label:hide()
        local yellow_btn = WidgetPushButton.new({
            normal = "yellow_btn_up_148x58.png",
            pressed= "yellow_btn_down_148x58.png"
        })
            :align(display.BOTTOM_RIGHT, 556, 18)
            :addTo(content)
            :setButtonLabel("normal", UIKit:commonButtonLable({
                text = _("领取"),
            }))
            :onButtonClicked(function()
                self:OnAwardButtonClicked(content.idx)
            end)
        content.yellow_btn = yellow_btn
    end

end

function GameUIIapGifts:OnAwardButtonClicked(idx)
    local data = self.award_dataSource[idx]
    if data then
        NetManager:getIapGiftPromise(data.id):done(function()
            if User:GetIapGiftTime(data) > 0 then
                GameGlobalUI:showTips(_("提示"),Localize_item.item_name[data.name] .. " x" .. data.count)
                app:GetAudioManager():PlayeEffectSoundWithKey("BUY_ITEM")
            end
        end)
    end
end

function GameUIIapGifts:OnUserDataChanged_iapGifts(changed_map)
    if self.award_list then
        self:RefreshAwardList()
    end
end
return GameUIIapGifts


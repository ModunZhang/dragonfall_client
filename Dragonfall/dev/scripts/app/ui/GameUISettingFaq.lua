--
-- Author: Danny He
-- Date: 2015-02-24 18:14:14
--
local GameUISettingFaq = UIKit:createUIClass("GameUISettingFaq")
local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local UIScrollView = import(".UIScrollView")
local FAQ = GameDatas.ClientInitGame.FAQ

function GameUISettingFaq:onEnter()
	GameUISettingFaq.super.onEnter(self)
	self:CreateBackGround()
    self:CreateTitle(_("遇到问题"))
    self.home_btn = self:CreateHomeButton()
    local gem_button = cc.ui.UIPushButton.new({
    	normal = "contact_n_148x60.png", pressed = "contact_h_148x60.png"
    }):onButtonClicked(function(event)
       	UIKit:newGameUI("GameUISettingContactUs"):AddToCurrentScene(true)
    end):addTo(self):setButtonLabel("normal", UIKit:commonButtonLable({
    	text = _("联系我们"),
    }))
    gem_button:align(display.RIGHT_TOP, window.cx+314, window.top-5)
    self:BuildUI()
end

function GameUISettingFaq:BuildUI()
    local list,list_node = UIKit:commonListView({
        async = true, --异步加载
        direction = UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(0, 0,562,840),
    },false)
    list:setDelegate(handler(self, self.DelegateFaq))
    list_node:addTo(self):pos(window.left + 40,window.bottom+30)
    self.list_view = list
    list:onTouch(handler(self, self.listviewListener))
    self.list_data = self:GetAllListData()
    self:RefreshListView()
end
function GameUISettingFaq:DelegateFaq( listView, tag, idx )
    if cc.ui.UIListView.COUNT_TAG == tag then
        return #self:GetAllListData()
    elseif cc.ui.UIListView.CELL_TAG == tag then
        local item
        local content
        item = listView:dequeueItem()
        if not item then
            item = listView:newItem()
            content = self:GetItem(self:GetAllListData()[idx])
            item:addContent(content)
            item:setItemSize(562,84)
        else
            content = item:getContent()
        end
        self:FillContent(content,idx)
        return item
    end
end
function GameUISettingFaq:GetAllListData(filter)
    return FAQ
end

function GameUISettingFaq:RefreshListView()
    self.list_view:reload()
end

function GameUISettingFaq:listviewListener(event)
    if "clicked" == event.name then
        local data = self.list_data[event.itemPos]
        if not data then return end
        UIKit:newGameUI("GameUISettingFaqDetail", data):AddToCurrentScene(true)
    end
end
function GameUISettingFaq:GetItem(data)
    local content = display.newScale9Sprite("back_ground_568x110.png"):size(562,84)
    local box = display.newSprite("faq_item_box_548x72.png"):addTo(content):align(display.LEFT_BOTTOM, 8, 5)
    local title = UIKit:ttfLabel({
        text = data.title,
        size = 20,
        color= 0x403c2f
    }):align(display.LEFT_CENTER,22,36):addTo(box)
    display.newSprite("next_32x38.png"):align(display.RIGHT_CENTER, 524, 36):addTo(box)
    content.title = title
    return content
end
function GameUISettingFaq:FillContent(content,idx)
    local data = self:GetAllListData()[idx]
    content.title:setString(data.title)
end
return GameUISettingFaq
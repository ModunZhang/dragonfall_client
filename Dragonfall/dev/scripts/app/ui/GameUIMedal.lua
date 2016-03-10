--
-- Author: Kenny Dai
-- Date: 2016-01-25 15:47:31
--
local GameUIMedal = UIKit:createUIClass("GameUIMedal","GameUIWithCommonHeader")
local window = import("..utils.window")
local UIListView = import(".UIListView")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")

function GameUIMedal:ctor(city)
    GameUIMedal.super.ctor(self,city, _("头衔"))
end

function GameUIMedal:onEnter()
    GameUIMedal.super.onEnter(self)
    local view = self:GetView()
    local  listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(window.left + 36,window.bottom + 20, 568, 860),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(view)
    self.medal_list = listview
   	listview:addItem(self:GetMedalItem()) 
    listview:reload()
    
    listview:onTouch(handler(self, self.listviewListener))

end
function GameUIMedal:onExit()
    GameUIMedal.super.onExit(self)
end
function GameUIMedal:GetMedalItem()
	local item = self.medal_list:newItem()
    local content = WidgetUIBackGround.new({width = 568,height= 154},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
    local b_size = content:getContentSize()
    local icon_bg = display.newSprite("box_136x136.png"):addTo(content):pos(72,b_size.height/2)
    local title_bg = display.newScale9Sprite("title_blue_430x30.png",0,0, cc.size(412,30), cc.rect(10,10,410,10)):addTo(content):align(display.LEFT_CENTER,140 , b_size.height-28)

    UIKit:ttfLabel({
        text = "战争修士",
        size = 22,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, 15, title_bg:getContentSize().height/2)
        :addTo(title_bg)
    UIKit:ttfLabel({
        text = "未颁发",
        size = 20,
        color = 0x7e0000,
    }):align(display.LEFT_CENTER, icon_bg:getPositionX() + icon_bg:getContentSize().width/2 + 16, 90)
        :addTo(content)
    UIKit:ttfLabel({
        text = "所有部队的生命值+15%。维护费-5%所有部队的生命值+15%。维护费-5%",
        size = 20,
        color = 0x403c2f,
        dimensions = cc.size(370,0)
    }):align(display.LEFT_TOP, icon_bg:getPositionX() + icon_bg:getContentSize().width/2 + 16, 70)
        :addTo(content)
    display.newSprite("next_32x38.png"):align(display.RIGHT_CENTER, 568, 154/2 - 10):addTo(content)

    item:addContent(content)
    item:setItemSize(568,154)
    return item
end
function GameUIMedal:listviewListener(event)
    local listView = event.listView
    if "clicked" == event.name then
        local pos = event.itemPos
        if not pos then
            return
        end
        app:GetAudioManager():PlayeEffectSoundWithKey("NORMAL_DOWN")
    end
end
return GameUIMedal





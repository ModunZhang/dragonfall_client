--
-- Author: Kenny Dai
-- Date: 2016-05-23 13:45:39
--
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local GameUISeasonRank = class("GameUISeasonRank", WidgetPopDialog)
local window = import("..utils.window")
local UIListView = import(".UIListView")
local WidgetAllianceHelper = import("..widget.WidgetAllianceHelper")
local ui_helper = WidgetAllianceHelper.new()
local NORMAL_COLOR = UIKit:hex2c3b(0x403c2f)
local MINE_COLOR = UIKit:hex2c3b(0xffedae)
local function rank_filter(response)
    local data = response.msg
    local is_not_nil = data.myData ~= json.null and data.myData.index ~= json.null
    if is_not_nil then
        data.myData.index = data.myData.index + 1
    end
    return response
end
local function load_more(rank_list, new_datas)
    for i,v in ipairs(new_datas) do
        table.insert(rank_list, v)
    end
end
function GameUISeasonRank:ctor(activity_data)
    GameUISeasonRank.super.ctor(self,680,_("排行榜"),window.top_bottom)
    self.activity_data = activity_data
    self.activity_type = activity_data.activity.type
end

function GameUISeasonRank:onEnter()
    GameUISeasonRank.super.onEnter(self)
    local body = self:GetBody()
    local size = body:getContentSize()
    local bg = display.newScale9Sprite("back_ground_166x84.png", 0,0,cc.size(548,52),cc.rect(15,10,136,64)):addTo(body)
        :align(display.TOP_CENTER, size.width / 2, size.height - 30)
    local activity_data = self.activity_data
    local activity_type = activity_data.activity.type
    local isAlliance = activity_data.isAlliance
    local myRank = isAlliance and ActivityManager:GetMyAllianceRank(activity_type) or ActivityManager:GetMyRank(activity_type)
    self.my_ranking =UIKit:ttfLabel({
        text = myRank and string.format(_("我的排名：%d"),myRank) or _("暂无排名"),
        size = 22,
        color = 0x403c2f,
    }):align(display.CENTER, bg:getContentSize().width/2, bg:getContentSize().height/2)
        :addTo(bg)

    WidgetUIBackGround.new({width = 568,height = 518},WidgetUIBackGround.STYLE_TYPE.STYLE_6)
        :addTo(body):align(display.BOTTOM_CENTER, size.width / 2, 62)
    local t_bg = display.newScale9Sprite("back_ground_blue_254x42.png", 0, 0,cc.size(546,44),cc.rect(10,10,234,22))
        :align(display.CENTER_TOP,size.width / 2, size.height - 110)
        :addTo(body)
    UIKit:ttfLabel({
        text = _("排名"),
        size = 20,
        color = 0xffedae,
    }):align(display.LEFT_CENTER,10,22)
        :addTo(t_bg)
    UIKit:ttfLabel({
        text = _("分数"),
        size = 20,
        color = 0xffedae,
    }):align(display.RIGHT_CENTER,536,22)
        :addTo(t_bg)
    local list = UIListView.new({
        async = true, --异步加载
        -- bgColor = UIKit:hex2c4b(0x7a10ff00),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(30,74,550,450),
    }):onTouch(handler(self, self.touchListener)):addTo(body)
    self.listview = list
    self.listview:setRedundancyViewVal(self.listview:getViewRect().height + 76 * 2)
    self.listview:setDelegate(handler(self, self.sourceDelegate))
    if isAlliance then
        NetManager:getAllianceTotalActivityRankPromise(self.activity_type):done(function(response)
            self:ReloadRank(rank_filter(response).msg)
        end)
    else
        NetManager:getPlayerTotalActivityRankPromise(self.activity_type):done(function(response)
            self:ReloadRank(rank_filter(response).msg)
        end)
    end

    UIKit:ttfLabel({
        text = _("排行榜信息10分钟刷新一次"),
        size = 20,
        color = 0x403c2f,
    }):align(display.CENTER,size.width / 2,38)
        :addTo(body)
    ActivityManager:AddListenOnType(self,ActivityManager.LISTEN_TYPE.ACTIVITY_CHANGED)
end
function GameUISeasonRank:onExit()
    GameUISeasonRank.super.onExit(self)
    ActivityManager:RemoveListenerOnType(self,ActivityManager.LISTEN_TYPE.ACTIVITY_CHANGED)
end
function GameUISeasonRank:OnActivitiesChanged()
    self:LeftButtonClicked()
end
function GameUISeasonRank:sourceDelegate(listView, tag, idx)
    if cc.ui.UIListView.COUNT_TAG == tag then
        if self.current_rank then
            return #self.current_rank.datas
        end
        return 0
    elseif cc.ui.UIListView.CELL_TAG == tag then
        if #self.current_rank.datas % 20 == 0 and #self.current_rank.datas - idx < 5 then
            self:LoadMore()
        end
        local item
        local content
        item = self.listview:dequeueItem()
        if not item then
            item = self.listview:newItem()
            content = self:CreatePlayerContentByIndex(idx)
            item:addContent(content)
        else
            content = item:getContent()
            content:SetIndex(idx)
        end
        content:SetData(self.current_rank.datas[idx])
        local size = content:getContentSize()
        item:setItemSize(size.width, size.height)
        return item
    else
    end
end
function GameUISeasonRank:CreatePlayerContentByIndex(idx)
    local item = display.newSprite("background2_548x76.png")
    local size = item:getContentSize()
    item.bg2 = display.newSprite("background1_548x76.png"):addTo(item)
        :pos(size.width/2, size.height/2)
    item.bg3 = display.newSprite("background3_548x76.png"):addTo(item)
        :pos(size.width/2, size.height/2)
    local bg = display.newSprite("box_102x102.png"):addTo(item):pos(120, 40):scale(0.6)
    local point = bg:getAnchorPointInPoints()
    local player_head_icon = UIKit:GetPlayerIconOnly():addTo(bg)
        :scale(0.72):pos(point.x, point.y)

    item.player_icon = player_head_icon
    item.rank = UIKit:ttfLabel({
        text = "",
        size = 22,
        color = 0x403c2f,
    }):align(display.CENTER, 50, 40):addTo(item)

    item.name = UIKit:ttfLabel({
        text = "",
        size = 22,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER, 160, 40):addTo(item)

    item.value = UIKit:ttfLabel({
        text = "",
        size = 22,
        color = 0x403c2f,
    }):align(display.RIGHT_CENTER, 520, 40):addTo(item)

    local parent = self
    function item:SetData(data)
        self.name:setString(data.name)
        self.value:setString(string.formatnumberthousands(data.score))

        if parent.activity_data.isAlliance then
            if data.flag then
                bg:hide()
                if self.flag then
                    self.flag:SetFlag(data.flag)
                else
                    self.flag = ui_helper:CreateFlagContentSprite(data.flag)
                        :addTo(self):align(display.CENTER, 80, 7):scale(0.45)
                end
            else
                if self.flag then
                    self.flag:hide()
                end
                bg:show()
            end
        else
            if self.flag then
                self.flag:hide()
            end
            bg:show()
            item.player_icon:setTexture(UIKit:GetPlayerIconImage(data.icon))
        end
        return self
    end
    local ranklist = self
    function item:SetIndex(index)
        local is_mine = ranklist.current_rank.myData.index == index
        self.bg2:setVisible(index % 2 == 0 and not is_mine)
        self.bg3:setVisible(is_mine)

        local c = is_mine and MINE_COLOR or NORMAL_COLOR
        self.rank:setColor(c)
        self.name:setColor(c)
        self.value:setColor(c)
        self.rank:show():setString(index)
        return self
    end
    return item:SetIndex(idx)
end
function GameUISeasonRank:LoadMore()
    if self.is_loading or #self.current_rank.datas >= 100 then return end
    self.is_loading = true
    local cur_datas = self.current_rank.datas
    local isAlliance = self.activity_data.isAlliance

    if isAlliance then
        NetManager:getAllianceTotalActivityRankPromise(self.activity_type,#cur_datas):done(function(response)
            load_more(cur_datas, rank_filter(response).msg.datas)
        end):always(function()
            self.is_loading = false
        end)
    else
        NetManager:getPlayerTotalActivityRankPromise(self.activity_type,#cur_datas):done(function(response)
            load_more(cur_datas, rank_filter(response).msg.datas)
        end):always(function()
            self.is_loading = false
        end)
    end
end
function GameUISeasonRank:ReloadRank(rank)
    if rank.myData == json.null or rank.myData.index == json.null then
        self.my_ranking:setString(_("暂无排名"))
    else
        self.my_ranking:setString(string.format(_("我的排名：%d"), rank.myData.index))
    end
    self.current_rank = rank
    dump(rank)
    self.listview:releaseAllFreeItems_()
    self.listview:reload()
end
function GameUISeasonRank:touchListener(event)
    local listView = event.listView
    if "clicked" == event.name then
        if not self.current_rank.datas[event.itemPos] then
            return
        end
        local id = self.current_rank.datas[event.itemPos].id
        app:GetAudioManager():PlayeEffectSoundWithKey("NORMAL_DOWN")
        if self.activity_data.isAlliance then
            UIKit:newGameUI("GameUIAllianceInfo", id, nil, DataManager:getUserData().serverId):AddToCurrentScene(true)
        else
            UIKit:newGameUI("GameUIAllianceMemberInfo",false,id,nil,DataManager:getUserData().serverId):AddToCurrentScene(true)
        end

    end
end
return GameUISeasonRank



























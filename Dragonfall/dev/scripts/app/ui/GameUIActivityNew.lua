--
-- Author: Danny He
-- Date: 2015-05-12 10:52:45
--
local GameUIActivityNew = UIKit:createUIClass("GameUIActivityNew","GameUIWithCommonHeader")
local GameUtils = GameUtils
local UILib = import(".UILib")
local Enum = import("..utils.Enum")
local window = import("..utils.window")
local RichText = import("..widget.RichText")
local UIListView = import(".UIListView")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local User = User
local config_day14 = GameDatas.Activities.day14
local config_levelup = GameDatas.Activities.levelup
local config_intInit = GameDatas.PlayerInitData.intInit
local GameUIActivityRewardNew = import(".GameUIActivityRewardNew")
local WidgetPushButton = import("..widget.WidgetPushButton")
local Localize_item = import("..utils.Localize_item")
--异步列表按钮事件修复
GameUIActivityNew.ITEMS_TYPE = Enum("EVERY_DAY_LOGIN","CONTINUITY","FIRST_IN_PURGURE","PLAYER_LEVEL_UP")
--赛季列表条类型
GameUIActivityNew.SEASON_ITEMS_TYPE = Enum("HAVE_IN_HAND","OVERDUE","COMING")

local titles = {
    EVERY_DAY_LOGIN = _("每日登陆奖励"),
    CONTINUITY = _("王城援军"),
    FIRST_IN_PURGURE = _("首次充值奖励"),
    PLAYER_LEVEL_UP = _("新手冲级奖励"),
}

function GameUIActivityNew:ctor(city)
    GameUIActivityNew.super.ctor(self,city, _("活动"))
    ActivityManager:GetActivitiesFromServer()
    local countInfo = User.countInfo
    self.player_level_up_time = countInfo.registerTime/1000 + config_intInit.playerLevelupRewardsHours.value * 60 * 60 -- 单位秒

    scheduleAt(self, function()
        local current_time = app.timer:GetServerTime()
        if self.activity_list_view and self.tab_buttons:GetSelectedButtonTag() == 'activity' then
            local count = #self.activity_list_view:getItems()
            local item = self.activity_list_view:getItems()[count]
            if item.item_type ~= self.ITEMS_TYPE.PLAYER_LEVEL_UP then return end
            if current_time <= self.player_level_up_time and item then
                if not item.time_label then return end
                self.player_level_up_time_residue = self.player_level_up_time - current_time
                if self.player_level_up_time_residue > 0 then
                    item.time_label:setString(GameUtils:formatTimeStyle1(self.player_level_up_time_residue))
                else
                    self.activity_list_view:removeItem(item)
                end
            end
        end
        if self.season_list_view and self.tab_buttons:GetSelectedButtonTag() == 'season' then
            for i,item in ipairs(self.season_list_view:getItems()) do
                local content = item:getContent()
                if content.finish_time_label then
                    content.finish_time_label:setString(string.format(_("结束时间：%s"),GameUtils:formatTimeStyle1(content.activity.finishTime/1000 - app.timer:GetServerTime())))
                elseif content.coming_time_label then
                    content.coming_time_label:setString(string.format(_("距离开始还有：%s"),GameUtils:formatTimeStyle1(activity.startTime/1000 - app.timer:GetServerTime())))
                end
            end
        end
    end)
end


function GameUIActivityNew:onCleanup()
    User:RemoveListenerOnType(self, "countInfo")
    -- User:RemoveListenerOnType(self, "iapGifts")
    User:RemoveListenerOnType(self, "buildings")
    NewsManager:RemoveListenerOnType(self,NewsManager.LISTEN_TYPE.NEWS_CHANGED)
    GameUIActivityNew.super.onCleanup(self)
end

function GameUIActivityNew:OnMoveInStage()
    GameUIActivityNew.super.OnMoveInStage(self)
    self.tab_buttons = self:CreateTabButtons(
        {
            {
                label = _("赛季"),
                tag = "season",
                default = true,
            },
            {
                label = _("活动"),
                tag = "activity",
            },
            {
                label = _("新闻"),
                tag = "news",
            }
        },
        function(tag)
            self:OnTabButtonClicked(tag)
        end
    ):pos(window.cx, window.bottom + 34)
    self:RefreshNewsCountTips()
    self:RefreshActivityCountTips()
end


function GameUIActivityNew:OnTabButtonClicked(tag)
    local method_name = "CreateTabIf_" .. tag
    if self[method_name] then
        if self.current_content then self.current_content:hide() end
        self.current_content = self[method_name](self)
        self.current_content:show()
    end
end
function GameUIActivityNew:CreateTabIf_season()
    local list = UIListView.new({
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(window.left+(window.width - 612)/2,window.bottom_top + 20,612,785),
    }):addTo(self:GetView())
    list:onTouch(handler(self, self.OnSeasonListViewTouch))
    self.season_list_view = list
    self:RefreshSeasonList()
    return self.season_list_view
end
function GameUIActivityNew:OnSeasonListViewTouch(event)
    if event.name == "clicked" and event.item and event.item:getContent().activity then
        UIKit:newGameUI("GameUISeasonDetails",event.item:getContent()):AddToCurrentScene()
    end
end
function GameUIActivityNew:RefreshSeasonList()
    local list = self.season_list_view
    local activities = ActivityManager:GetLocalActivities()
    -- 进行中的赛季
    if #activities.on > 0 then
        self:GetSeasonTitleItem(_("进行中"))
        ActivityManager:IteratorActivityOn(function (i,activity)
            self:GetSeasonItem(self.SEASON_ITEMS_TYPE.HAVE_IN_HAND,activity)
        end)
    end
    -- 过期的赛季
    if #activities.expired > 0 then
        self:GetSeasonTitleItem(_("已过期"))
        ActivityManager:IteratorActivityExpired(function (i,activity)
            self:GetSeasonItem(self.SEASON_ITEMS_TYPE.OVERDUE,activity)
        end)
    end
    -- 即将来临的赛季
    if #activities.next > 0 then
        self:GetSeasonTitleItem(_("即将来临"))
        ActivityManager:IteratorActivityNext(function (i,activity)
            self:GetSeasonItem(self.SEASON_ITEMS_TYPE.COMING,activity)
        end)
    end
    list:reload()
end
function GameUIActivityNew:GetSeasonTitleItem(title)
    local list = self.season_list_view
    local item = list:newItem()
    local item_width,item_height = 568, 40
    item:setItemSize(item_width,item_height)
    local content = display.newNode()
    content:setContentSize(cc.size(item_width,item_height))
    display.newSprite("line_116x16.png"):align(display.RIGHT_CENTER, item_width, item_height/2):addTo(content)
    display.newSprite("line_116x16.png"):align(display.LEFT_CENTER, 0, item_height/2):addTo(content):flipX(true)
    UIKit:ttfLabel({
        text = title,
        size = 20,
        color = 0x403c2f
    }):addTo(content):align(display.CENTER,284,item_height/2)
    item:addContent(content)
    list:addItem(item)
end
function GameUIActivityNew:GetSeasonItem(season_type,activity)
    local list = self.season_list_view
    local item = list:newItem()
    local content
    local item_width,item_height
    if season_type == self.SEASON_ITEMS_TYPE.HAVE_IN_HAND then
        item_width,item_height = 568, 138
        item:setItemSize(item_width,item_height)
        content = WidgetUIBackGround.new({width = item_width,height = item_height},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
        content.activity = activity
        content.status = "on"
        local title_bg = display.newSprite("title_blue_522x54.png"):align(display.LEFT_CENTER, - 2, item_height - 40):addTo(content)
        local title_label = UIKit:ttfLabel({
            text = ActivityManager:GetActivityLocalize(activity.type),
            size = 20,
            color = 0xffcb4e,
            shadow = true
        }):addTo(title_bg):align(display.LEFT_CENTER,146,title_bg:getContentSize().height/2 + 4)

        content.finish_time_label = UIKit:ttfLabel({
            text = string.format(_("结束时间：%s"),GameUtils:formatTimeStyle1(activity.finishTime/1000 - app.timer:GetServerTime())),
            size = 18,
            color = 0x7e0000
        }):addTo(content):align(display.LEFT_CENTER,144,item_height/2 - 10)
        local season_desc_label = UIKit:ttfLabel({
            text = ActivityManager:GetActivityLocalize(activity.type),
            size = 18,
            color = 0x403c2f
        }):addTo(content):align(display.LEFT_CENTER,144,item_height/2 - 40)

        local season_icon = display.newSprite(UILib.actvities[activity.type]):align(display.LEFT_CENTER, 10, item_height/2):addTo(content)
        local hot_icon = display.newSprite("icon_hot_64x76.png"):align(display.RIGHT_TOP, item_width, item_height + 2):addTo(content)
    elseif season_type == self.SEASON_ITEMS_TYPE.OVERDUE then
        item_width,item_height = 568, 128
        item:setItemSize(item_width, item_height)
        content = WidgetUIBackGround.new({width = item_width,height = item_height},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
        content.activity = activity
        content.status = "expired"
        local title_bg = display.newSprite("title_red_522x54.png"):align(display.LEFT_CENTER, -2, item_height - 40):addTo(content)
        local title_label = UIKit:ttfLabel({
            text = ActivityManager:GetActivityLocalize(activity.type),
            size = 20,
            color = 0xffcb4e,
            shadow = true
        }):addTo(title_bg):align(display.LEFT_CENTER,30,title_bg:getContentSize().height/2 + 4)
        content.over_time_label = UIKit:ttfLabel({
            text = string.format(_("%s已过期"),GameUtils:formatTimeAsTimeAgoStyle(app.timer:GetServerTime() - activity.removeTime/1000)),
            size = 18,
            color = 0x7e0000
        }):addTo(content):align(display.LEFT_CENTER,28,item_height/2 - 24)
        if ActivityManager:GetActivityRankReward(activity.type) then
            UIKit:ttfLabel({
                text = _("有奖励可领取"),
                size = 20,
                color = 0x007c23
            }):addTo(content):align(display.RIGHT_CENTER,item_width - 60,item_height/2 - 24)
        else
            UIKit:ttfLabel({
                text = _("无奖励可领取"),
                size = 20,
                color = 0x615b44
            }):addTo(content):align(display.RIGHT_CENTER,item_width - 60,item_height/2 - 24)
        end
    elseif season_type == self.SEASON_ITEMS_TYPE.COMING then
        item_width,item_height = 568, 128
        item:setItemSize(item_width, item_height)
        content = WidgetUIBackGround.new({width = item_width,height = item_height},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
        content.activity = activity
        content.status = "next"
        local title_bg = display.newSprite("title_blue_522x54.png"):align(display.LEFT_CENTER, -2, item_height - 40):addTo(content)
        local title_label = UIKit:ttfLabel({
            text = ActivityManager:GetActivityLocalize(activity.type),
            size = 20,
            color = 0xffcb4e,
            shadow = true
        }):addTo(title_bg):align(display.LEFT_CENTER,30,title_bg:getContentSize().height/2 + 4)
        content.coming_time_label = UIKit:ttfLabel({
            text = string.format(_("距离开始还有：%s"),GameUtils:formatTimeStyle1(activity.startTime/1000 - app.timer:GetServerTime())),
            size = 18,
            color = 0x007c23
        }):addTo(content):align(display.LEFT_CENTER,28,item_height/2 - 12)
        local season_desc_label = UIKit:ttfLabel({
            text = ActivityManager:GetActivityLocalize(activity.type),
            size = 18,
            color = 0x403c2f
        }):addTo(content):align(display.LEFT_CENTER,28,item_height/2 - 40)
    end
    display.newSprite("next_32x38.png"):align(display.RIGHT_CENTER, 560, item_height/2 - 10):addTo(content)
        :runAction(
            cc.RepeatForever:create(transition.sequence{cc.ScaleTo:create(1/2, 1.3),
                cc.ScaleTo:create(1/2, 1.0),})
        )
    item:addContent(content)
    list:addItem(item)
end
function GameUIActivityNew:CreateTabIf_activity()
    self.player_level_up_time_residue = self.player_level_up_time - app.timer:GetServerTime()
    if not self.activity_list_view then
        local list = UIListView.new({
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            viewRect = cc.rect(window.left+(window.width - 612)/2,window.bottom_top + 20,612,785),
        }):addTo(self:GetView())
        list:onTouch(handler(self, self.OnActivityListViewTouch))
        self.activity_list_view = list
        self:RefreshActivityListView()
        User:AddListenOnType(self, "countInfo")
        User:AddListenOnType(self, "buildings")
    end
    self:RefreshActivityListView()
    return self.activity_list_view
end

function GameUIActivityNew:RefreshActivityListView()
    self.activity_list_view:removeAllItems()
    local countInfo = User.countInfo
    local item = self:GetActivityItem(self.ITEMS_TYPE.EVERY_DAY_LOGIN)
    self.activity_list_view:addItem(item)
    --
    if countInfo.day14RewardsCount < #config_day14 then
        item = self:GetActivityItem(self.ITEMS_TYPE.CONTINUITY)
        self.activity_list_view:addItem(item)
    end
    if not countInfo.isFirstIAPRewardsGeted then
        item = self:GetActivityItem(self.ITEMS_TYPE.FIRST_IN_PURGURE)
        self.activity_list_view:addItem(item)
    end
    if self.player_level_up_time - app.timer:GetServerTime() > 0 and not self:CheckFinishAllLevelUpActiIf() then
        item = self:GetActivityItem(self.ITEMS_TYPE.PLAYER_LEVEL_UP)
        self.activity_list_view:addItem(item)
    end
    self.activity_list_view:reload()
end

function GameUIActivityNew:CheckFinishAllLevelUpActiIf()
    local checkLevelInUserCountInfoRewards = function(level)
        local countInfo = User.countInfo
        for __,v in ipairs(countInfo.levelupRewards) do
            if v == level then
                return true
            end
        end
        return false
    end
    for __,v in ipairs(config_levelup) do
        if not checkLevelInUserCountInfoRewards(v.level) then
            return false

        end
    end
    return true
end
function GameUIActivityNew:OnUserDataChanged_countInfo()
    self:RefreshActivityListView()
    self:RefreshActivityCountTips()
end

function GameUIActivityNew:OnActivityListViewTouch(event)
    if event.name == "clicked" and event.item then
        self:OnSelectActivityAtItem(event.item.item_type)
    end
end

function GameUIActivityNew:OnSelectActivityAtItem(item_type)
    app:GetAudioManager():PlayeEffectSoundWithKey("NORMAL_DOWN")
    UIKit:newGameUI("GameUIActivityRewardNew",GameUIActivityRewardNew.REWARD_TYPE[self.ITEMS_TYPE[item_type]]):AddToCurrentScene(true)
end

function GameUIActivityNew:GetFirstPurgureTips()
    local str = _("首次充值%s金额")
    local s,e = string.find(str,"%%s")
    return string.format("[{\"type\":\"text\", \"value\":\"%s\"},{\"type\":\"text\",\"color\":0xa2ff00,\"size\":22,\"value\":\"%s\"},{\"type\":\"text\", \"value\":\"%s\"}]",
        string.sub(str,1,s - 1).." ",_("任意"),string.sub(str,e+1))
end

function GameUIActivityNew:GetActivityItem(item_type)
    local countInfo = User.countInfo
    local item = self.activity_list_view:newItem()
    item.item_type = item_type
    local bg = display.newSprite("activity_bg_612x198.png")
    local title_txt = titles[self.ITEMS_TYPE[item_type]]
    UIKit:ttfLabel({
        text = title_txt,
        size = 22,
        color= 0xfed36c
    }):align(display.CENTER_TOP,306, 188):addTo(bg)
    local content = display.newSprite(UILib.activity_image_config[self.ITEMS_TYPE[item_type]]):align(display.CENTER_BOTTOM,306, 12):addTo(bg)
    local size = content:getContentSize()
    if item_type ~= self.ITEMS_TYPE.EVERY_DAY_LOGIN then
        display.newSprite("activity_layer_blue_586x114.png"):align(display.RIGHT_CENTER, size.width,size.height/2+2):addTo(content)
    end
    display.newSprite("next_32x38.png"):align(display.LEFT_CENTER, 566, 80):addTo(bg)

    if item_type == self.ITEMS_TYPE.EVERY_DAY_LOGIN then
        local title_label = UIKit:ttfLabel({
            text = _("免费领取海量道具"),
            size = 20,
            color= 0xffedae,
            align = cc.TEXT_ALIGNMENT_LEFT,
            shadow= true
        }):align(display.LEFT_BOTTOM,208,92):addTo(bg)
        local sign_str,sign_color = _("已签到"),0xa2ff00
        if countInfo.day60 > countInfo.day60RewardsCount then
            sign_str = _("未签到")
            sign_color = 0xff4e00
        end
        local sign_bg = display.newSprite("activity_day_bg_104x34.png")
            :align(display.LEFT_BOTTOM,441,50)
            :addTo(bg)
        local today_label = UIKit:ttfLabel({
            text = _("今日"),
            size = 20,
            color= 0xffedae,
            align = cc.TEXT_ALIGNMENT_LEFT,
            shadow= true
        }):align(display.LEFT_BOTTOM,208,54):addTo(bg)
        local content_label = UIKit:ttfLabel({
            text = sign_str,
            size = 20,
            color= sign_color
        }):align(display.CENTER, 52, 17):addTo(sign_bg)
    elseif item_type == self.ITEMS_TYPE.CONTINUITY then
        local title_label = UIKit:ttfLabel({
            text = _("连续登陆，来自王城的援军"),
            size = 20,
            color= 0xffedae,
            align = cc.TEXT_ALIGNMENT_LEFT,
            shadow= true
        }):align(display.LEFT_BOTTOM,208,90):addTo(bg)

        local day_label = UIKit:ttfLabel({
            text = string.format("%d/%d",countInfo.day14,#config_day14),
            size = 20,
            color= 0xa2ff00,
            shadow= true,
            align = cc.TEXT_ALIGNMENT_LEFT,
        }):addTo(bg):align(display.LEFT_BOTTOM, 208, 46)
        local day_label2 = UIKit:ttfLabel({
            text = _("天"),
            size = 20,
            color= 0xffedae,
            shadow= true,
            align = cc.TEXT_ALIGNMENT_LEFT,
        }):align(display.LEFT_BOTTOM, day_label:getPositionX()+day_label:getContentSize().width+4, 46):addTo(bg)
        local today_label = UIKit:ttfLabel({
            text = _("今日"),
            size = 20,
            color= 0xffedae,
            align = cc.TEXT_ALIGNMENT_LEFT,
            shadow= true
        }):align(display.LEFT_BOTTOM,day_label2:getPositionX()+day_label2:getContentSize().width + 15,46):addTo(bg)
        local got_bg = display.newSprite("activity_day_bg_104x34.png")
            :align(display.LEFT_BOTTOM,441,42)
            :addTo(bg)
        local str,color = _("已领取"),0xa2ff00
        if countInfo.day14 > countInfo.day14RewardsCount then
            str = _("未领取")
            color= 0xff4e00
        end
        local content_label = UIKit:ttfLabel({
            text = str,
            size = 20,
            color= color,
            align = cc.TEXT_ALIGNMENT_CENTER,
            shadow= true
        }):align(display.CENTER,52,17):addTo(got_bg)
    elseif item_type == self.ITEMS_TYPE.FIRST_IN_PURGURE then
        local title_label = RichText.new({width = 400,size = 20,color = 0xffedae,shadow = true})
        local str = self:GetFirstPurgureTips()
        title_label:Text(str):align(display.LEFT_BOTTOM,208,82):addTo(bg)
        --
        local content_label = UIKit:ttfLabel({
            text = _("永久获得第二条建筑队列"),
            size = 20,
            color= 0xffedae,
            align = cc.TEXT_ALIGNMENT_LEFT,
            shadow= true
        }):align(display.LEFT_CENTER,208,62):addTo(bg)
    elseif item_type == self.ITEMS_TYPE.PLAYER_LEVEL_UP then
        local title_label = UIKit:ttfLabel({
            text = _("活动时间类，升级智慧中心，获得丰厚奖励"),
            size = 20,
            color= 0xffedae,
            align = cc.TEXT_ALIGNMENT_LEFT,
            shadow= true,
            dimensions = cc.size(272, 0)
        }):align(display.LEFT_TOP,218,126):addTo(bg)

        local time_desc_label = UIKit:ttfLabel({
            text = _("倒计时:"),
            size = 20,
            color= 0xffedae,
            align = cc.TEXT_ALIGNMENT_LEFT,
            shadow= true
        }):align(display.LEFT_BOTTOM,208,40):addTo(bg)
        local time_label = UIKit:ttfLabel({
            text = GameUtils:formatTimeStyle1(self.player_level_up_time_residue),
            size = 20,
            color= 0xa2ff00,
            align = cc.TEXT_ALIGNMENT_LEFT,
            shadow= true
        }):align(display.LEFT_BOTTOM,208 + time_desc_label:getContentSize().width + 10,40):addTo(bg)

        local countInfo = User.countInfo
        local current_level = City:GetFirstBuildingByType('keep'):GetLevel()
        local flag = false
        for __,v in ipairs(config_levelup) do
            if app.timer:GetServerTime() > countInfo.registerTime/1000 + config_intInit.playerLevelupRewardsHours.value * 60 * 60 then
                break
            else
                if  v.level <= current_level then
                    flag = self:CheckCanGetLevelUpReward(v.index)
                    if flag then
                        break
                    end
                end
            end
        end
        local sign_str,sign_color = _("已领取"),0xa2ff00
        if flag then
            sign_str = _("未领取")
            sign_color = 0xff4e00
        end
        local sign_bg = display.newSprite("activity_day_bg_104x34.png")
            :align(display.LEFT_BOTTOM,441,time_label:getPositionY())
            :addTo(bg)
        local content_label = UIKit:ttfLabel({
            text = sign_str,
            size = 20,
            color= sign_color
        }):align(display.CENTER, 52, 17):addTo(sign_bg)
        item.time_label = time_label
    end
    -- bg:size(576,190)
    item:addContent(bg)
    item:setMargin({left = 0, right = 0, top = 0, bottom = 5})
    item:setItemSize(612, 190,false)
    return item
end
function GameUIActivityNew:CheckCanGetLevelUpReward(level)
    local countInfo = User.countInfo
    for __,v in ipairs(countInfo.levelupRewards) do
        if v == level then
            return false
        end
    end
    return true
end
-- 新闻
function GameUIActivityNew:CreateTabIf_news()
    if not self.news_list_view then
        local list,list_node = UIKit:commonListView({
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            viewRect = cc.rect(0,0,556,782),
            async = true,
        },false)
        list_node:addTo(self:GetView()):align(display.BOTTOM_CENTER,window.cx,window.bottom_top + 20)
        self.news_list = list
        self.news_list_view = list_node
        self.news_list:onTouch(handler(self, self.listviewListener))
        self.news_list:setDelegate(handler(self, self.sourceDelegateNewsList))
    end
    self:ShowNews()
    NewsManager:AddListenOnType(self,NewsManager.LISTEN_TYPE.NEWS_CHANGED)
    return self.news_list_view
end
function GameUIActivityNew:sourceDelegateNewsList(listView, tag, idx)
    if cc.ui.UIListView.COUNT_TAG == tag then
        return #self.newsData
    elseif cc.ui.UIListView.CELL_TAG == tag then
        local item
        local content
        local data = self.newsData[idx]
        item = self.news_list:dequeueItem()
        if not item then
            item = self.news_list:newItem()
            content = self:GetNewsListContent()
            item:addContent(content)
        else
            content = item:getContent()
        end
        self:FillNewsItemContent(content,data,idx)
        item:setItemSize(556,110)
        return item
    else
    end
end
function GameUIActivityNew:listviewListener(event)
    local listView = event.listView
    if "clicked" == event.name then
        if event.item then
            local content = event.item:getContent()
            local data = self.newsData[content.idx]
            self:OpenNewsDetails(data,content)
        end
    end
end
function GameUIActivityNew:ShowNews()
    self.newsData = clone(NewsManager:GetNewsData())
    table.sort( self.newsData, function ( a,b )
        return a.time > b.time
    end )
    self.news_list:reload()
end
function GameUIActivityNew:ReloadNews()
    self:ShowNews()
    self:RefreshNewsCountTips()
end
function GameUIActivityNew:GetNewsListContent()
    local content = WidgetUIBackGround.new({width = 556,height = 102},WidgetUIBackGround.STYLE_TYPE.STYLE_9)
    display.newSprite("line_550x8.png"):align(display.TOP_CENTER, content:getContentSize().width/2, content:getContentSize().height - 4):addTo(content)
    display.newSprite("line_550x8.png"):align(display.BOTTOM_CENTER, content:getContentSize().width/2, 3):addTo(content)
    local icon_bg = display.newSprite("box_136x136.png"):addTo(content):pos(54,51):scale(100/136)
    local icon = display.newSprite("troopSizeBonus_128x128.png", nil, nil, {class=cc.FilteredSpriteWithOne}):addTo(content):pos(56,51):scale(94/128)
    local news_name = UIKit:ttfLabel({
        text = "",
        size = 22,
        color = 0x403c2f
    }):addTo(content):align(display.LEFT_CENTER,126,65)
    local news_time = UIKit:ttfLabel({
        text = "",
        size = 20,
        color = 0x2b8a3f
    }):addTo(content):align(display.LEFT_CENTER,126,30)
    display.newSprite("next_32x38.png"):align(display.CENTER, 520, 51):addTo(content)
    content.news_name = news_name
    content.news_time = news_time
    content.icon = icon
    content.idx = nil
    content.isRead = false
    return content
end
function GameUIActivityNew:FillNewsItemContent(content,data,idx)
    content.news_name:setString(data.title)
    content.news_time:setString(GameUtils:formatTimeStyle2(data.time/1000))
    content.idx = idx
    content.isRead = false
    content.news_time:setColor(UIKit:hex2c4b(0x2b8a3f))
    content.icon:clearFilter()
    if app:GetGameDefautlt():IsReadNews(data.id) then
        content.icon:setFilter(filter.newFilter("GRAY", {0.2, 0.3, 0.5, 0.1}))
        content.news_time:setColor(UIKit:hex2c4b(0x403c2f))
        content.isRead = true
    end
end
function GameUIActivityNew:OpenNewsDetails(data,content)
    app:GetAudioManager():PlayeEffectSoundWithKey("OPEN_MAIL")
    if not content.isRead then
        NewsManager:ReadNews(data.id)
        content.icon:setFilter(filter.newFilter("GRAY", {0.2, 0.3, 0.5, 0.1}))
        content.news_time:setColor(UIKit:hex2c4b(0x403c2f))
        content.isRead = true
        self:RefreshNewsCountTips()
    end

    local dialog = UIKit:newWidgetUI("WidgetPopDialog",772,_("新闻详情"), window.top-130,"title_red_634x134.png"):AddToCurrentScene()
    dialog.title_sprite:setPositionY(772):zorder(20)
    dialog.title_label:setPositionY(dialog.title_sprite:getContentSize().height - 35)
    dialog.close_btn:setPosition(dialog.title_sprite:getContentSize().width - 25,dialog.title_sprite:getContentSize().height/2+16)
    local body = dialog:GetBody()
    local size = body:getContentSize()
    UIKit:ttfLabel({
        text = data.title,
        size = 22,
        color = 0x403c2f
    }):addTo(body):align(display.CENTER,size.width/2,size.height- 60)
    display.newSprite("line_514x22.png"):align(display.CENTER, size.width/2,size.height- 90):addTo(body)
    UIKit:ttfLabel({
        text = GameUtils:formatTimeStyle2(data.time/1000),
        size = 20,
        color = 0x2b8a3f
    }):addTo(body):align(display.CENTER,size.width/2,size.height- 120)
    local content_bg = WidgetUIBackGround.new({width = 556,height = 526},WidgetUIBackGround.STYLE_TYPE.STYLE_5)
        :addTo(body):align(display.TOP_CENTER,size.width/2,size.height- 140)
    local message_label = UIKit:ttfLabel({
        text = data.content,
        size = 20,
        color = 0x403c2f,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER,
        dimensions = cc.size(480, 0),
    })
    local w,h =  message_label:getContentSize().width,message_label:getContentSize().height
    -- 提示内容
    local listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(14,10, 528, 506),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(content_bg)
    local item = listview:newItem()
    item:setItemSize(500,message_label:getContentSize().height)
    item:addContent(message_label)
    listview:addItem(item)
    listview:reload()
    local active_button = WidgetPushButton.new(
        {normal = "yellow_btn_up_186x66.png", pressed = "yellow_btn_down_186x66.png"}
    ):setButtonLabel(UIKit:ttfLabel({
        text = _("我知道了"),
        size = 20,
        color = 0xfff3c7,
        shadow = true
    })):addTo(body):align(display.CENTER, size.width/2, 60)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                dialog:LeftButtonClicked()
            end
        end)
end
function GameUIActivityNew:OnNewsChanged()
    self:ReloadNews()
end
function GameUIActivityNew:CreateTabIf_award()
    if not self.award_list_view then
        local list,list_node = UIKit:commonListView({
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            viewRect = cc.rect(0,0,576,772),
            async = true,

        })
        list_node:addTo(self:GetView()):pos(window.left + 35,window.bottom_top + 20)
        self.award_list = list
        self.award_list_view = list_node
        self.award_list:setDelegate(handler(self, self.sourceDelegateAwardList))
        User:AddListenOnType(self, "iapGifts")
    end
    self:RefreshAwardList()
    return self.award_list_view
end

function GameUIActivityNew:RefreshAwardList()
    self:RefreshAwardListDataSource()
    self.award_list:reload()
    self.award_list:stopAllActions()
    scheduleAt(self,function()
        for k,v in pairs(User.iapGifts) do
            self:OnIapGiftTimer(v)
        end
    end)
end

function GameUIActivityNew:RefreshAwardListDataSource()
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

function GameUIActivityNew:RefreshNewsCountTips()
    if self.tab_buttons then
        self.tab_buttons:SetButtonTipNumber('news', NewsManager:GetUnreadCount())
    end
end
function GameUIActivityNew:RefreshActivityCountTips()
    if self.tab_buttons then
        local award_num = 0
        if User:HaveEveryDayLoginReward() then
            award_num = award_num + 1
        end
        if User:HaveContinutyReward() then
            award_num = award_num + 1
        end
        if User:HavePlayerLevelUpReward() then
            award_num = award_num + 1
        end
        self.tab_buttons:SetButtonTipNumber('activity', award_num)
    end
end

function GameUIActivityNew:OnUserDataChanged_buildings(userData, deltaData)
    if deltaData("buildings.location_1") then
        self:RefreshActivityCountTips()
    end
end
function GameUIActivityNew:OnIapGiftTimer(iapGift)
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

function GameUIActivityNew:sourceDelegateAwardList(listView, tag, idx)
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
        item:setItemSize(576,164)
        return item
    else
    end
end

function GameUIActivityNew:GetAwardListContent()
    local content = WidgetUIBackGround.new({width = 576,height = 149},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
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
    content:size(576,164)
    return content
end

function GameUIActivityNew:FillAwardItemContent(content,data,idx)
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


function GameUIActivityNew:OnAwardButtonClicked(idx)
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

return GameUIActivityNew























--
-- Author: Danny He
-- Date: 2015-05-12 16:38:51
--
local GameUIActivityRewardNew = UIKit:createUIClass("GameUIActivityRewardNew","UIAutoClose")
local Enum = import("..utils.Enum")
local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local UIListView = import(".UIListView")
local SpriteConfig = import("..sprites.SpriteConfig")
local config_day60 = GameDatas.Activities.day60
local config_online = GameDatas.Activities.online
local config_day14 = GameDatas.Activities.day14
local GameUtils = GameUtils
local config_stringInit = GameDatas.PlayerInitData.stringInit
local config_intInit = GameDatas.PlayerInitData.intInit
local config_levelup = GameDatas.Activities.levelup
local Localize_item = import("..utils.Localize_item")
local Localize = import("..utils.Localize")
local UILib = import(".UILib")
local Localize_item = import("..utils.Localize_item")
local lights = import("..particles.lights")
local light_gem = import("..particles.light_gem")
local RichText = import("..widget.RichText")

local height_config = {
    EVERY_DAY_LOGIN = 850,
    CONTINUITY = 762,
    ONLINE = 762,
    FIRST_IN_PURGURE = 720,
    PLAYER_LEVEL_UP = 762,
    MONTH_CARD = 602,
    IAP_REWARD = 850,
}
local y_offset = {
    EVERY_DAY_LOGIN = 60,
    CONTINUITY = 0,
    ONLINE = 0,
    FIRST_IN_PURGURE = 0,
    PLAYER_LEVEL_UP = 0,
    MONTH_CARD = -60,
    IAP_REWARD = 20,
}
local ui_titles = {
    EVERY_DAY_LOGIN = _("每日登陆奖励"),
    ONLINE = _("在线奖励"),
    CONTINUITY = _("第二条行军队列"),
    FIRST_IN_PURGURE = _("首次充值奖励"),
    PLAYER_LEVEL_UP = _("新手冲级奖励"),
    MONTH_CARD = _("月卡"),
    IAP_REWARD = _("活动"),
}

GameUIActivityRewardNew.REWARD_TYPE = Enum("EVERY_DAY_LOGIN","ONLINE","CONTINUITY","FIRST_IN_PURGURE","PLAYER_LEVEL_UP","MONTH_CARD","IAP_REWARD")

function GameUIActivityRewardNew:ctor(reward_type)
    GameUIActivityRewardNew.super.ctor(self)
    self.reward_type = reward_type
    if self:GetRewardType() == self.REWARD_TYPE.PLAYER_LEVEL_UP or self:GetRewardType() == self.REWARD_TYPE.ONLINE then
        local countInfo = User.countInfo
        self.player_level_up_time = countInfo.registerTime/1000 + config_intInit.playerLevelupRewardsHours.value * 60 * 60 -- 单位秒
        self.player_level_up_time_residue = self.player_level_up_time - app.timer:GetServerTime()
        scheduleAt(self, function()
            local current_time = app.timer:GetServerTime()
            if self.online_time_label and self.online_time then
                local time = self.online_time + current_time
                self.online_time_label:setString(GameUtils:formatTimeStyle1(time))
                --item update
                for k,v in pairs(self.need_update_online_item) do
                    local diff_time = config_online[k].onLineMinutes * 60 - time
                    if diff_time > 0 then
                        v.time_label:setString(GameUtils:formatTimeStyle1(diff_time))
                    else
                        self:RefreshOnLineList(false)
                        break
                    end
                end
            end
            if self.level_up_time_label then
                self.player_level_up_time_residue = self.player_level_up_time - current_time
                if self.player_level_up_time_residue > 0 then
                    self.level_up_time_label:setString(GameUtils:formatTimeStyle1(self.player_level_up_time_residue))
                else
                    self.level_up_time_label:hide()
                    self.level_up_time_desc_label:hide()
                    self.level_up_state_label:show()
                end
            end
        end)
    end
end

function GameUIActivityRewardNew:GetRewardType()
    return self.reward_type or self.REWARD_TYPE.EVERY_DAY_LOGIN
end

function GameUIActivityRewardNew:onEnter()
    GameUIActivityRewardNew.super.onEnter(self)
    self:BuildUI()
    User:AddListenOnType(self, "countInfo")
end

function GameUIActivityRewardNew:onExit()
    User:RemoveListenerOnType(self, "countInfo")
    removeImageByKey("background_608x678.png")
    GameUIActivityRewardNew.super.onExit(self)
end

function GameUIActivityRewardNew:onCleanup()
    GameUIActivityRewardNew.super.onCleanup(self)
end

function GameUIActivityRewardNew:OnUserDataChanged_countInfo()
    self:RefreshUI()
    if self.march_queue_text then
        self.march_queue_text:setString(User.countInfo.day14 > 7 and 7 or User.countInfo.day14)
    end
end

function GameUIActivityRewardNew:RefreshUI()
    if self:GetRewardType() == self.REWARD_TYPE.EVERY_DAY_LOGIN then
        local countInfo = User.countInfo
        local flag = countInfo.day60 % 30 == 0 and 30 or countInfo.day60 % 30
        local geted = countInfo.day60RewardsCount % 30 == 0 and 30 or countInfo.day60RewardsCount % 30 -- <= geted
        for i,button in ipairs(self.rewards_buttons) do
            if i > flag then -- other day
                button.check_bg:hide()
                button.icon:clearFilter()
            else
                if flag == i then
                    if flag > geted then -- can
                        button.check_bg:hide()
                        button.icon:clearFilter()
                    else
                        button.check_bg:show()
                        if not button.icon:getFilter() then
                            button.icon:setFilter(filter.newFilter("CUSTOM", json.encode({frag = "shaders/ps_discoloration.fs",shaderName = "ps_discoloration"})))
                        end
                    end
                else
                    button.check_bg:show()
                    if not button.icon:getFilter() then
                        button.icon:setFilter(filter.newFilter("CUSTOM", json.encode({frag = "shaders/ps_discoloration.fs",shaderName = "ps_discoloration"})))
                    end
                end
            end
        end
    elseif self:GetRewardType() == self.REWARD_TYPE.CONTINUITY then
        self:RefreshContinutyList(false)
    elseif self:GetRewardType() == self.REWARD_TYPE.FIRST_IN_PURGURE then
        local countInfo = User.countInfo
        if countInfo.iapCount > 0 and not countInfo.isFirstIAPRewardsGeted then
            self.purgure_get_button:show()
            self.go_store_button:hide()
        end
        if countInfo.iapCount <= 0 then
            self.purgure_get_button:hide()
            self.go_store_button:show()
        end
    elseif self:GetRewardType() == self.REWARD_TYPE.PLAYER_LEVEL_UP then
        self:RefreshLevelUpListView(false)
    elseif self:GetRewardType() == self.REWARD_TYPE.ONLINE then
        self:RefreshOnLineList(false)
    end
end


function GameUIActivityRewardNew:BuildUI()
    local height = height_config[self.REWARD_TYPE[self:GetRewardType()]]
    self.height = height
    local bg = WidgetUIBackGround.new({height=height})
    self:addTouchAbleChild(bg)
    self.bg = bg
    bg:pos(((display.width - bg:getContentSize().width)/2),window.bottom_top - y_offset[self.REWARD_TYPE[self:GetRewardType()]])
    local is_first_in_purgure = self:GetRewardType() == self.REWARD_TYPE.FIRST_IN_PURGURE
    local titleBar = display.newSprite(is_first_in_purgure and "title_red_634x134.png" or "title_blue_600x56.png")
        :align(display.LEFT_BOTTOM,is_first_in_purgure and -13 or 3,is_first_in_purgure and height - 80 or height - 15):addTo(bg):zorder(2)
    local closeButton = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"}, {scale9 = false})
        :addTo(titleBar)
        :align(display.BOTTOM_RIGHT,titleBar:getContentSize().width,self:GetRewardType() == self.REWARD_TYPE.FIRST_IN_PURGURE and 40 or 0)
        :onButtonClicked(function ()
            self:LeftButtonClicked()
        end)
    UIKit:ttfLabel({
        text = ui_titles[self.REWARD_TYPE[self:GetRewardType()]],
        size = 22,
        shadow = true,
        color = 0xffedae
    }):addTo(titleBar):align(display.CENTER,titleBar:getContentSize().width/2,is_first_in_purgure and 96 or 28)
    if self['ui_' .. self.REWARD_TYPE[self:GetRewardType()]] then
        self['ui_' .. self.REWARD_TYPE[self:GetRewardType()]](self)
    end
end

function GameUIActivityRewardNew:GetPageOfDay60()
    local countInfo = User.countInfo
    if  countInfo.day60RewardsCount >= 30 then return 2 else return 1 end
end

function GameUIActivityRewardNew:GetDay60Reward()
    local config_data
    if self:GetPageOfDay60() == 2 then
        config_data = LuaUtils:table_slice(config_day60,31,60)
    else
        config_data =  LuaUtils:table_slice(config_day60,1,30)
    end
    local final_data = LuaUtils:table_map(config_data,function(k,v)
        local __,reward,count = unpack(string.split(v.rewards,":"))
        return k,{reward = reward,count = count}
    end)
    return final_data
end

function GameUIActivityRewardNew:ui_EVERY_DAY_LOGIN()
    self.rewards_buttons = {}
    local rewards = self:GetDay60Reward()
    local flag = User.countInfo.day60 % 30 == 0 and 30 or User.countInfo.day60 % 30
    local geted = User.countInfo.day60RewardsCount % 30 == 0 and 30 or User.countInfo.day60RewardsCount % 30  -- <= geted
    local auto_get_reward = 0
    self.every_day_bg = display.newNode():addTo(self.bg):size(self.bg:getContentSize())
    UIKit:ttfLabel({
        text = _("领取30日奖励后，刷新奖励列表"),
        size = 20,
        color= 0x403c2f
    }):align(display.CENTER_TOP,304,self.height - 20):addTo(self.every_day_bg)
    local content_bg = UIKit:CreateBoxPanelWithBorder({
        width = 556,
        height= 786
    }):align(display.CENTER_BOTTOM, 304, 16):addTo(self.every_day_bg)
    local x,y = 3,786 - 10
    for i=1,30 do
        local button = display.newSprite('box_118x118.png')
            :align(display.LEFT_TOP, x, y)
            :addTo(content_bg)
            :scale(110/118)
        UIKit:addTipsToNode(button,Localize_item.item_name[rewards[i].reward],self,nil,56,-59)
        table.insert(self.rewards_buttons,button)
        local enable = display.newSprite(UILib.item[rewards[i].reward], 59, -59 + 118, {class=cc.FilteredSpriteWithOne}):addTo(button)
        local size = enable:getContentSize()
        enable:scale(90/math.max(size.width,size.height))
        local check_bg = display.newSprite("activity_check_bg_55x51.png"):align(display.RIGHT_BOTTOM,105,-105 + 118):addTo(button,2):scale(34/55)
        button.icon = enable
        button.check_bg = check_bg
        display.newSprite("activity_check_body_55x51.png"):addTo(check_bg):pos(27,17)
        if i > flag then -- other day
            check_bg:hide()
            enable:clearFilter()
        else
            if flag == i then
                if flag > geted or (geted == 30 and flag == 1) then -- can
                    check_bg:hide()
                    enable:clearFilter()
                    auto_get_reward = i
                else
                    check_bg:show()
                    if not enable:getFilter() then
                        enable:setFilter(filter.newFilter("CUSTOM", json.encode({frag = "shaders/ps_discoloration.fs",shaderName = "ps_discoloration"})))
                    end
                end

                display.newSprite("icon_daily_box_118x118.png"):align(display.LEFT_TOP,0, 118):addTo(button,2)
                local reward_info = display.newNode()
                reward_info:setContentSize(cc.size(536,118))
                reward_info:align(display.LEFT_TOP, 0, y)
                    :addTo(content_bg)
                local get_btn = WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png",disabled = "grey_btn_148x58.png"})
                    :setButtonLabel(UIKit:commonButtonLable({
                        text = _("领取"),
                        color = 0xfff3c7
                    })):align(display.RIGHT_CENTER,540, -59):onButtonClicked(function(event)
                    self:On_EVERY_DAY_LOGIN_GetReward(auto_get_reward,rewards[auto_get_reward])
                    end):addTo(reward_info)
                get_btn:setVisible(auto_get_reward ~= 0)
                if auto_get_reward == 0 then
                    UIKit:ttfLabel({
                        text = _("已领取"),
                        size = 22,
                        color= 0x403c2f
                    }):align(display.RIGHT_CENTER,520, -59):addTo(reward_info)
                end
                UIKit:ttfLabel({
                    text = Localize_item.item_name[rewards[i].reward],
                    size = 22,
                    color= 0x403c2f
                }):align(display.LEFT_CENTER, 14, -20):addTo(reward_info)
                UIKit:ttfLabel({
                    text = Localize_item.item_desc[rewards[i].reward],
                    size = 20,
                    color= 0x615b44,
                    dimensions = cc.size(380,0)
                }):align(display.LEFT_TOP, 14, -40):addTo(reward_info)
            else
                check_bg:show()
                if not enable:getFilter() then
                    enable:setFilter(filter.newFilter("CUSTOM", json.encode({frag = "shaders/ps_discoloration.fs",shaderName = "ps_discoloration"})))
                end
            end
        end

        local num_bg = display.newSprite("activity_num_bg_28x28.png",20,-18 + 118):addTo(button)
        UIKit:ttfLabel({
            text = i,
            size = 15,
            color= 0xfff9e4
        }):align(display.CENTER, 14, 14):addTo(num_bg)
        x = x + 110
        if i % 5 == 0 then
            x = 3
            if i - flag < 5 and i - flag >= 0 then
                y = y - 222
            else
                y = y - 108
            end
        end

    end
end


function GameUIActivityRewardNew:On_EVERY_DAY_LOGIN_GetReward(index,reward)
    local countInfo = User.countInfo
    local real_index = countInfo.day60 % 30 == 0 and 30 or countInfo.day60 % 30
    if (countInfo.day60 > countInfo.day60RewardsCount and real_index == index) or (countInfo.day60RewardsCount > countInfo.day60 and real_index == index) then
        NetManager:getDay60RewardPromise():done(function()
            dump(reward,"reward")
            GameGlobalUI:showTips(_("提示"),string.format(_("恭喜您获得 %s x %d"),Localize_item.item_name[reward.reward],reward.count))
            app:GetAudioManager():PlayeEffectSoundWithKey("BUY_ITEM")
            self.every_day_bg:removeAllChildren()
            self:ui_EVERY_DAY_LOGIN()
            -- self:LeftButtonClicked()
        end)
    else
        if index > real_index then
        else
            GameGlobalUI:showTips(_("提示"),string.format(_("你已领取%s"),Localize_item.item_name[reward.reward]))
        end
    end
end

----------------------
function GameUIActivityRewardNew:ui_CONTINUITY()
    local march_queue_bg = display.newSprite("gem_logo_592x139_3.png"):align(display.LEFT_TOP,30,self.height - 20):addTo(self.bg):scale(554/592)
    display.newScale9Sprite("box_50x50.png",0,0, cc.size(554,130), cc.rect(20,20,10,10)):align(display.LEFT_TOP,30,self.height - 20):addTo(self.bg)
    display.newSprite("activity_layer_blue_586x114.png"):align(display.LEFT_TOP,-4,self.height - 28):addTo(self.bg)

    local text_1 = UIKit:ttfLabel({
        text = User.countInfo.day14 > 3 and 3 or User.countInfo.day14,
        size = 22,
        color= 0x238700,
    }):align(display.LEFT_CENTER,514,self.height - 55):addTo(self.bg)
    self.march_queue_text = text_1
    UIKit:ttfLabel({
        text = "/3",
        size = 22,
        color= 0x238700,
    }):align(display.LEFT_CENTER,text_1:getPositionX()+text_1:getContentSize().width,self.height - 55):addTo(self.bg)
    UIKit:ttfLabel({
        text = _("三天后可激活"),
        size = 20,
        color= 0xffedae,
    }):align(display.RIGHT_CENTER,text_1:getPositionX() - text_1:getContentSize().width - 10,self.height - 55):addTo(self.bg)
    local button = WidgetPushButton.new({normal = 'yellow_btn_up_148x58.png',pressed = 'yellow_btn_down_148x58.png',disabled = 'gray_btn_148x58.png'})
        :setButtonLabel("normal", UIKit:commonButtonLable({
            text = _("领取")
        }))
        :addTo(self.bg)
        :align(display.RIGHT_CENTER,550,self.height - 105)
        :onButtonClicked(function()
            NetManager:getUnlockPlayerSecondMarchQueuePromise():done(function (response)
                GameGlobalUI:showTips(_("提示"),_("永久行军队列+1"))
                self:LeftButtonClicked()
                return response
            end)
        end)
        :setButtonEnabled(User.countInfo.day14 >= 3)
    if User.basicInfo.marchQueue == 2 then
        button:setVisible(false)
        local title_label = UIKit:ttfLabel({
            text = _("已领取"),
            size = 22,
            color= 0x514d3e
        }):addTo(self.bg)
            :align(display.RIGHT_CENTER,550,self.height - 105)
    end
    self.list_view = UIListView.new{
        viewRect = cc.rect(26,20,556,584),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(self.bg)
    self:RefreshContinutyList(true)
end


function GameUIActivityRewardNew:RefreshContinutyList(needClean)
    if needClean then
        self.list_view:removeAllItems()
        local data = self:GetContinutyListData()
        -- 定位到第一个可以领取的位置
        local item_pos
        for i,v in ipairs(data) do
            local reward_type,item_key,time_str,rewards_str,flag = unpack(v)
            local item = self:GetContinutyListItem(reward_type,item_key,time_str,rewards_str,flag)
            if not item_pos and flag ~= 1 then
                item_pos = i
            end
            self.list_view:addItem(item)
        end
        self.list_view:reload()
        if item_pos then
            self.list_view:showItemWithPos(item_pos)
        end
    else
        local items = self.list_view:getItems()
        if #items == 0 then return end
        local data = self:GetContinutyListData()
        for index,v in ipairs(data) do
            local reward_type,item_key,time_str,rewards_str,flag = unpack(v)
            local item = items[index]
            if flag == 1 then
                item.sp.check_bg:show()
                item.title_label:show()
                item.button:hide()
                item.title_label:setString(_("已领取"))
                if not item.sp:getFilter() then
                    item.sp:setFilter(filter.newFilter("CUSTOM", json.encode({frag = "shaders/ps_discoloration.fs",shaderName = "ps_discoloration"})))
                end
            elseif flag == 3 then
                item.sp.check_bg:hide()
                item.title_label:show()
                item.button:hide()
                item.title_label:setString(_("明天领取"))
            elseif flag == 2 then
                item.sp.check_bg:hide()
                item.title_label:hide()
                item.button:show()
                if item.sp:getFilter() then
                    item.sp:clearFilter()
                end
            else
                item.sp.check_bg:hide()
                item.title_label:hide()
                item.button:hide()
            end
        end
    end
end


function GameUIActivityRewardNew:GetContinutyListItem(reward_type,item_key,time_str,rewards_str,flag,current_str)
    local item = self.list_view:newItem()
    local content = UIKit:CreateBoxPanelWithBorder({
        width = 556,
        height= 116
    })
    local item_bg,corlor_bg
    if reward_type == "soldiers" then
        corlor_bg = display.newSprite(UILib.soldier_color_bg_images[item_key], 59,59, {class=cc.FilteredSpriteWithOne}):align(display.LEFT_CENTER, 15, 58):addTo(content):scale(85/128)
        item_bg = display.newSprite("box_soldier_128x128.png"):align(display.CENTER, 64, 64):addTo(corlor_bg)
    elseif reward_type == "basicInfo" then
        item_bg = display.newSprite("box_118x118.png"):align(display.LEFT_CENTER, 13, 58):addTo(content):scale(92/118)
    end
    local sp = display.newSprite(UIKit:GetItemImage(reward_type,item_key), 63,62, {class=cc.FilteredSpriteWithOne}):addTo(item_bg)
    local size = sp:getContentSize()
    if reward_type == "soldiers" then
        sp:scale(0.9)
    else
        sp:scale(90/math.max(size.width,size.height))
    end
    local check_bg = display.newSprite("activity_check_bg_55x51.png"):align(display.RIGHT_BOTTOM,110,0):addTo(item_bg):scale(34/55)
    display.newSprite("activity_check_body_55x51.png"):addTo(check_bg):pos(27,17)
    sp.check_bg = check_bg
    if flag == 1 then
        sp:setFilter(filter.newFilter("CUSTOM", json.encode({frag = "shaders/ps_discoloration.fs",shaderName = "ps_discoloration"})))
        if corlor_bg then
            corlor_bg:setFilter(filter.newFilter("CUSTOM", json.encode({frag = "shaders/ps_discoloration.fs",shaderName = "ps_discoloration"})))
        end
    end
    item.sp = sp
    UIKit:addTipsToNode(sp,rewards_str,self)
    if reward_type == "basicInfo" then
        display.newScale9Sprite("title_blue_430x30.png",0,0, cc.size(428,30), cc.rect(10,10,410,10))
            :addTo(content)
            :align(display.LEFT_TOP, 110, 105)
    end
    local time_label = UIKit:ttfLabel({
        text = time_str,
        size = 22,
        color= reward_type == "basicInfo" and 0xffedae or 0x514d3e
    }):align(display.LEFT_TOP, 120, 105):addTo(content)

    local desc_label = UIKit:ttfLabel({
        text = rewards_str,
        size = 20,
        color= 0x615b44
    }):align(display.LEFT_CENTER, 120, 38):addTo(content)

    local title_label = UIKit:ttfLabel({
        text = flag == 1 and _("已领取") or _("明天领取"),
        size = 22,
        color= 0x514d3e
    }):align(display.RIGHT_CENTER,518, 35):addTo(content)
    local button = WidgetPushButton.new({normal = 'yellow_btn_up_148x58.png',pressed = 'yellow_btn_down_148x58.png',disabled = 'gray_btn_148x58.png'})
        :setButtonLabel("normal", UIKit:commonButtonLable({
            text = _("领取")
        }))
        :addTo(content)
        :pos(473,41)
        :onButtonClicked(function()
            NetManager:getDay14RewardPromise():done(function()
                GameGlobalUI:showTips(_("提示"),rewards_str)
                app:GetAudioManager():PlayeEffectSoundWithKey("BUY_ITEM")
            end)
        end)
    item.title_label = title_label
    item.button = button
    if flag == 1 then
        check_bg:show()
        button:hide()
        check_bg:hide()
    elseif flag == 3 then
        title_label:show()
        button:hide()
        check_bg:hide()
    elseif flag == 2 then
        check_bg:hide()
        title_label:hide()
        button:show()
    else
        check_bg:hide()
        button:hide()
        title_label:hide()
    end
    item:addContent(content)
    item:setMargin({left = 0, right = 0, top = 0, bottom = 5})
    item:setItemSize(556, 116,false)
    return item
end

-- flag 1.已领取 2.可领取 3.明天领取 0 未来的
function GameUIActivityRewardNew:GetContinutyListData()
    local r = {}
    local countInfo = User.countInfo
    dump(countInfo,"countInfo")
    for i,v in ipairs(config_day14) do
        local config_rewards = string.split(v.rewards,",")
        if #config_rewards == 1 then
            local reward_type,item_key,count = unpack(string.split(v.rewards,":"))
            local flag = 0
            if v.day <= countInfo.day14RewardsCount then
                flag = 1
            elseif v.day == countInfo.day14 and countInfo.day14 > countInfo.day14RewardsCount then
                flag = 2
            elseif v.day == countInfo.day14 + 1  then
                flag = 3
            end
            local name = self:GetRewardName(reward_type, item_key)
            table.insert(r,{reward_type,item_key,string.format(_("第%s天"),v.day), name .. "x" .. count,flag})
        else
            if string.find(v.rewards,"marchQueue") then
                local final_rewards = {}
                local has_queue = false
                for __,one_reward in ipairs(config_rewards) do
                    local reward_type,item_key,count = unpack(string.split(one_reward,":"))
                    local str = string.format("%s x%d",self:GetRewardName(reward_type, item_key),count)
                    table.insert(final_rewards, 1,str)
                    if reward_type == 'basicInfo' then
                        has_queue = true
                    end
                end
                local final_rewards_str = table.concat(final_rewards, ",")

                for __,one_reward in ipairs(config_rewards) do
                    local reward_type,item_key,count = unpack(string.split(one_reward,":"))
                    local flag = 0
                    if v.day <= countInfo.day14RewardsCount then
                        flag = 1
                    elseif v.day == countInfo.day14 and countInfo.day14 > countInfo.day14RewardsCount then
                        flag = 2
                    elseif v.day == countInfo.day14 + 1  then
                        flag = 3
                    end
                    if has_queue then
                        if reward_type == 'basicInfo' then
                            local str = string.format("%s x%d",self:GetRewardName(reward_type, item_key),count)
                            table.insert(r,{reward_type,item_key,string.format(_("第%s天"),v.day),final_rewards_str,flag})
                        end
                    else
                        if reward_type == 'soldiers' then
                            local str = string.format("%s x%d",self:GetRewardName(reward_type, item_key),count)
                            table.insert(r,{reward_type,item_key,string.format(_("第%s天"),v.day),final_rewards_str,flag})
                        end
                    end
                end
            end
        end
    end
    return r
end


function GameUIActivityRewardNew:GetRewardName(reward_type,reward_key)
    if reward_type == 'resource'
        or reward_type == 'items'
        or reward_type == 'special'
        or reward_type == 'speedup'
        or reward_type == 'buff'
        or reward_type == 'buff'then
        return Localize_item.item_name[reward_key]
    elseif reward_type == 'soldiers' then
        return Localize.soldier_name[reward_key]
    elseif reward_type == 'basicInfo' then
        local localize_basicInfo = {
            marchQueue = _("行军队列"),
            buildQueue = _("建筑队列")
        }
        return localize_basicInfo[reward_key]
    end
end
-----------------------
function GameUIActivityRewardNew:ui_FIRST_IN_PURGURE()
    local bar = display.newSprite("background_608x678.png"):align(display.TOP_CENTER, 288,self.height - 20):addTo(self.bg)
    -- lights():addTo(bar):pos(100, 100)
    display.newSprite("icon_hammer.png"):align(display.CENTER, 126,585):addTo(bar)
    -- :runAction(
    --     cc.RepeatForever:create(transition.sequence{
    --         cc.RotateBy:create(0.2, 60),
    --         cc.RotateBy:create(0.2, -60)
    --         })
    -- )

    self:runAction(cc.CallFunc:create(function()
        local emitter = lights()
        emitter:setSpeed(3)
        emitter:setLife(math.random(1) + 1)
        emitter:setEmissionRate(1)
        emitter:addTo(bar):pos(126,585)
        emitter:update(0.01)
    end))


    UIKit:ttfLabel({
        text = _("首充后永久获得"),
        size = 30,
        color = 0xfed36c,
        shadow = true
    }):addTo(bar):align(display.CENTER,410,608)
    UIKit:ttfLabel({
        text = _("第二条建筑队列"),
        size = 36,
        color = 0xfed36c,
        align = cc.ui.TEXT_ALIGN_CENTER,
        valign = cc.ui.TEXT_VALIGN_CENTER,
        -- dimensions = cc.size(300,0),
        shadow = true
    }):addTo(bar):align(display.CENTER,410,555)
    UIKit:ttfLabel({
        text = _("领取下列丰厚奖励"),
        size = 22,
        color = 0xffedae,
    }):addTo(bar):align(display.CENTER,440,468)
    local countInfo = User.countInfo
    local rewards = self:GetFirstPurgureRewards()
    local x,y = 310,438
    self.purgure_get_button = WidgetPushButton.new({normal = 'tmp_button_battle_up_234x82.png',pressed = 'tmp_button_battle_down_234x82.png'},{scale9 = true})
        :setButtonLabel("normal", UIKit:commonButtonLable({
            text = _("领取")
        }))
        :addTo(bar,1)
        :pos(430,58)
        :setButtonSize(190,66)
    self.go_store_button = WidgetPushButton.new({normal = 'tmp_button_battle_up_234x82.png',pressed = 'tmp_button_battle_down_234x82.png'},{scale9 = true})
        :setButtonLabel("normal", UIKit:commonButtonLable({
            text = _("前往充值")
        }))
        :addTo(bar,1)
        :pos(430,58)
        :onButtonClicked(function()
            UIKit:newGameUI("GameUIStore"):AddToCurrentScene(true)
        end)
        :setButtonSize(190,66)
    local tips_list = {}
    local acts = {}
    for index,reward in ipairs(rewards) do
        if index <= 6 then
            local reward_type,reward_name,count = unpack(reward)
            local tips = Localize_item.item_name[reward_name] .. " x" .. count
            table.insert(tips_list, tips)
            local item_bg = display.newSprite("box_118x118.png"):align(display.LEFT_TOP, x, y):addTo(bar):scale(50/118)
            local sp = display.newSprite(UIKit:GetItemImage(reward_type,reward_name),59,59):addTo(item_bg)
            local size = sp:getContentSize()
            sp:scale(90/math.max(size.width,size.height))
            UIKit:ttfLabel({
                text = Localize_item.item_name[reward_name],
                size = 18,
                color = 0xfed36c,
                shadow = true
            }):addTo(bar):align(display.LEFT_CENTER,x + 60,y - 24)
            UIKit:ttfLabel({
                text = "X " .. count,
                size = 18,
                color = 0xfed36c,
                shadow = true
            }):addTo(bar):align(display.RIGHT_CENTER,x + 270,y - 24)
            -- table.insert(acts, cc.CallFunc:create(function()
            --     local emitter = lights()
            --     emitter:setSpeed(3)
            --     emitter:setLife(math.random(1) + 1)
            --     emitter:setEmissionRate(1)
            --     emitter:addTo(sp):pos(size.width/2,size.height/2)
            --     for i = 1, index * 25 do
            --         emitter:update(0.01)
            --     end
            -- end))
            -- UIKit:addTipsToNode(sp,Localize_item.item_name[reward_name] .. " x" .. count,self)
            -- x = x  + 110 + 35
            -- if index % 2 == 0 then
            --     x = 300
            y = y - 56
            -- end
        end
    end
    -- self:runAction(transition.sequence(acts))
    local tips_str = table.concat(tips_list, ",")
    self.purgure_get_button:onButtonClicked(function()
        NetManager:getFirstIAPRewardsPromise():done(function()
            if iskindof(display.getRunningScene(), "MyCityScene") then
                local home_page = display.getRunningScene():GetHomePage()
                if home_page and home_page.event_tab then
                    home_page.event_tab:RefreshBuildQueueByType("build")
                end
            end

            GameGlobalUI:showTips(_("提示"),tips_str)
            app:GetAudioManager():PlayeEffectSoundWithKey("BUY_ITEM")
            self:LeftButtonClicked()
        end)
    end)
    if countInfo.iapCount > 0 and not countInfo.isFirstIAPRewardsGeted then
        self.purgure_get_button:show()
        self.go_store_button:hide()
    end
    if countInfo.iapCount <= 0 then
        self.purgure_get_button:hide()
        self.go_store_button:show()
    end
end

function GameUIActivityRewardNew:GetFirstPurgureRewards()
    local config = config_stringInit.firstIAPRewards.value
    local r = {}
    local rewards = string.split(config, ',')
    for __,v in ipairs(rewards) do
        local reward_type,reward_name,count = unpack(string.split(v, ':'))
        table.insert(r,{reward_type,reward_name,count})
    end
    return r
end

-----------------------------------

function GameUIActivityRewardNew:ui_PLAYER_LEVEL_UP()
    local box = display.newSprite("alliance_item_flag_box_126X126.png"):align(display.LEFT_TOP, 20,self.height - 30):addTo(self.bg)
    local keep_img = SpriteConfig["keep"]:GetConfigByLevel(City:GetFirstBuildingByType("keep"):GetLevel()).png
    display.newSprite(keep_img,70,63):addTo(box):scale(120/420)
    local title_bg = display.newScale9Sprite("title_blue_430x30.png",0,0, cc.size(390,30), cc.rect(10,10,410,10))
        :align(display.LEFT_TOP, 180, self.height - 30):addTo(self.bg)
    UIKit:ttfLabel({
        text = string.format(_("当前等级：LV %s"),City:GetFirstBuildingByType('keep'):GetLevel()),
        size = 22,
        color= 0xffedae
    }):align(display.LEFT_CENTER, 14, 15):addTo(title_bg)
    local level_up_time_desc_label = UIKit:ttfLabel({
        text = _("倒计时:"),
        size = 20,
        color= 0x403c2f
    }):align(display.LEFT_TOP, 190, title_bg:getPositionY() -  50):addTo(self.bg)
    local level_up_time_label = UIKit:ttfLabel({
        text = GameUtils:formatTimeStyle1(self.player_level_up_time_residue),
        size = 20,
        color= 0x489200
    }):align(display.LEFT_TOP,level_up_time_desc_label:getPositionX()+level_up_time_desc_label:getContentSize().width,level_up_time_desc_label:getPositionY())
        :addTo(self.bg)
    local level_up_state_label = UIKit:ttfLabel({
        text = _("已失效"),
        size = 20,
        color= 0x403c2f
    }):align(display.LEFT_TOP,190,title_bg:getPositionY() -  50):addTo(self.bg)
    self.level_up_time_label = level_up_time_label
    self.level_up_time_desc_label = level_up_time_desc_label
    self.level_up_state_label = level_up_state_label
    if self.player_level_up_time_residue > 0 then
        level_up_state_label:hide()
    else
        level_up_time_desc_label:hide()
        level_up_time_label:hide()
    end
    local activity_desc_label = UIKit:ttfLabel({
        text = _("活动期间，升级城堡获得丰厚奖励"),
        size = 20,
        color= 0x403c2f,
        dimensions = cc.size(400,0)
    }):align(display.LEFT_CENTER, 190, level_up_state_label:getPositionY() - level_up_state_label:getContentSize().height - 30):addTo(self.bg)

    local list_bg = display.newScale9Sprite("background_568x120.png", 0,0,cc.size(568,544),cc.rect(15,10,538,100))
        :align(display.BOTTOM_CENTER, 304, 30):addTo(self.bg)
    self.list_view = UIListView.new{
        viewRect = cc.rect(13,10,542,524),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(list_bg)
    self:RefreshLevelUpListView(true)
end

function GameUIActivityRewardNew:RefreshLevelUpListView(needClean)
    if needClean then
        self.list_view:removeAllItems()
        -- 定位到第一个可以领取的位置
        local item_pos
        local data = self:GetLevelUpData()
        for index,v in ipairs(data) do
            local title,rewards,flag = unpack(v)
            local item = self:GetRewardLevelUpItem(index,title,rewards,flag)
            if not item_pos and flag ~= 1 then
                item_pos = index
            end
            self.list_view:addItem(item)
        end
        self.list_view:reload()
        if item_pos then
            self.list_view:showItemWithPos(item_pos)
        end
    else
        local items = self.list_view:getItems()
        if #items == 0 then return end
        local data = self:GetLevelUpData()
        for index,v in ipairs(data) do
            local title,rewards,flag = unpack(v)
            local item = items[index]
            if flag == 1 then
                item.title_label:show()
                item.button:hide()
            elseif flag == 2 then
                item.title_label:hide()
                item.button:show()
                item.button:setButtonEnabled(true)
            else
                item.button:setButtonEnabled(false)
                item.button:show()
                item.title_label:hide()
            end
        end
    end
end
-- flag 1.已领取 2.可以领取 3.不能领取
function GameUIActivityRewardNew:GetLevelUpData()
    local countInfo = User.countInfo

    local current_level = City:GetFirstBuildingByType('keep'):GetLevel()
    local r = {}
    for __,v in ipairs(config_levelup) do
        local flag = 0
        if app.timer:GetServerTime() > countInfo.registerTime/1000 + config_intInit.playerLevelupRewardsHours.value * 60 * 60 then
            flag = 3
        else
            if  v.level <= current_level then
                flag = self:CheckCanGetLevelUpReward(v.index) and 2 or 1
            else
                flag = 3
            end
        end
        local rewards = self:GetLevelUpRewardListFromConfig(v.rewards)
        table.insert(r,{string.format(_("等级%s"),v.level),rewards,flag})
    end
    return r
end

function GameUIActivityRewardNew:GetLevelUpRewardListFromConfig(config_str)
    local r = {}
    local tmp_list = string.split(config_str, ',')
    for __,v in ipairs(tmp_list) do
        local reward_type,reward_name,count = unpack(string.split(v, ':'))
        table.insert(r,{reward_type,reward_name,count})
    end
    return r
end

function GameUIActivityRewardNew:CheckCanGetLevelUpReward(level)
    local max_level = 0
    local countInfo = User.countInfo
    for __,v in ipairs(countInfo.levelupRewards) do
        if v == level then
            return false
        end
    end
    return true
end

function GameUIActivityRewardNew:GetRewardLevelUpItem(index,title,rewards,flag)
    local item = self.list_view:newItem()
    local content = display.newScale9Sprite(string.format("back_ground_548x40_%d.png", index % 2 == 0 and 1 or 2)):size(548,104)
    local title_label = UIKit:ttfLabel({
        text = title,
        size = 22,
        color= 0x514d3e
    }):align(display.LEFT_CENTER, 24, 52):addTo(content)
    local x = 104
    local reward_list = {}
    for __,v in ipairs(rewards) do
        local reward_type,reward_name,count = unpack(v)
        table.insert(reward_list, Localize_item.item_name[reward_name] .. " x" .. count)
        local item_bg = display.newSprite("box_118x118.png"):align(display.LEFT_CENTER, x, 52):addTo(content):scale(94/118)
        local sp = display.newSprite(UIKit:GetItemImage(reward_type,reward_name),59,59):addTo(item_bg)
        local size = sp:getContentSize()
        sp:scale(90/math.max(size.width,size.height))
        UIKit:addTipsToNode(sp,Localize_item.item_name[reward_name] .. " x" .. count,self)
        x = x + 130
    end
    local title_label = UIKit:ttfLabel({
        text = _("已领取"),
        size = 22,
        color= 0x514d3e
    }):align(display.CENTER,450, 54):addTo(content)
    item.title_label = title_label
    local tips_str = table.concat(reward_list, ",")
    local button = WidgetPushButton.new({normal = 'yellow_btn_up_148x58.png',pressed = 'yellow_btn_down_148x58.png',disabled = 'gray_btn_148x58.png'})
        :setButtonLabel("normal", UIKit:commonButtonLable({
            text = _("领取")
        }))
        :addTo(content)
        :pos(450,54)
        :onButtonClicked(function()
            NetManager:getLevelupRewardPromise(index):done(function()
                GameGlobalUI:showTips(_("提示"),tips_str)
                app:GetAudioManager():PlayeEffectSoundWithKey("BUY_ITEM")
            end)
        end)
    item.button = button
    if flag == 1 then
        title_label:show()
        button:hide()
    elseif flag == 2 then
        title_label:hide()
        button:show()
        button:setButtonEnabled(true)
    else
        button:setButtonEnabled(false)
        button:show()
        title_label:hide()
    end
    item:addContent(content)
    item:setItemSize(548,104)
    return item
end
----------------------
function GameUIActivityRewardNew:ui_ONLINE()
    local countInfo = User.countInfo
    local onlineTime = math.floor((countInfo.todayOnLineTime - countInfo.lastLoginTime)/1000)
    self.online_time = onlineTime
    UIKit:ttfLabel({
        text = _("每日在线时间到达，即可领取珍贵的道具和金龙币"),
        size = 20,
        color= 0x403c2f
    }):align(display.CENTER_TOP,304,self.height - 30):addTo(self.bg)
    UIKit:ttfLabel({
        text = _("今日已在线："),
        size = 20,
        color= 0x403c2f
    }):align(display.TOP_RIGHT, 304,self.height - 60):addTo(self.bg)
    self.online_time_label = UIKit:ttfLabel({
        text = GameUtils:formatTimeStyle1(DataUtils:getPlayerOnlineTimeSecondes()),
        size = 22,
        color= 0x318200
    }):align(display.TOP_LEFT, 304,self.height - 60):addTo(self.bg)
    self.online_list_view = UIListView.new{
        viewRect = cc.rect(26,20,556,630),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(self.bg)
    self:RefreshOnLineList(true)
end

function GameUIActivityRewardNew:GetOnLineItem(reward_type,item_key,time_str,rewards,flag,timePoint,next_point)
    local item = self.online_list_view:newItem()
    local content = UIKit:CreateBoxPanelWithBorder({
        width = 556,
        height= 116
    })
    local item_bg = display.newSprite("box_118x118.png"):align(display.LEFT_CENTER, 5, 58):addTo(content):scale(110/118)
    local image = UIKit:GetItemImage(reward_type,item_key)
    local sp = display.newSprite(image, 59,59, {class=cc.FilteredSpriteWithOne}):addTo(item_bg)
    local size = sp:getContentSize()
    sp:scale(90/math.max(size.width,size.height))
    UIKit:addTipsToNode(sp,rewards,self)
    local check_bg = display.newSprite("activity_check_bg_55x51.png"):align(display.RIGHT_BOTTOM,110,0):addTo(item_bg):scale(34/55)
    display.newSprite("activity_check_body_55x51.png"):addTo(check_bg):pos(27,17)
    sp.check_bg = check_bg
    item.sp = sp
    if flag == 1 then
        sp:setFilter(filter.newFilter("CUSTOM", json.encode({frag = "shaders/ps_discoloration.fs",shaderName = "ps_discoloration"})))
    end
    local time_label = UIKit:ttfLabel({
        text = time_str,
        size = 22,
        color= 0x514d3e
    }):align(display.LEFT_TOP, 120, 105):addTo(content)

    local desc_label = UIKit:ttfLabel({
        text = rewards,
        size = 20,
        color= 0x615b44
    }):align(display.LEFT_CENTER, 120, 58):addTo(content)

    local got_label = UIKit:ttfLabel({
        text = _("已领取"),
        size = 22,
        color= 0x514d3e
    }):align(display.CENTER, 471, 35):addTo(content)
    local button = WidgetPushButton.new({normal = 'yellow_btn_up_148x58.png',pressed = 'yellow_btn_down_148x58.png',disabled = 'gray_btn_148x58.png'})
        :setButtonLabel("normal", UIKit:commonButtonLable({
            text = _("领取"),
            size = 22,
        }))
        :addTo(content)
        :pos(471,41)

        :onButtonClicked(function()
            NetManager:getOnlineRewardPromise(timePoint):done(function()
                GameGlobalUI:showTips(_("提示"),rewards)
                app:GetAudioManager():PlayeEffectSoundWithKey("BUY_ITEM")
            end)
        end)
    local time_label = UIKit:ttfLabel({
        text = "",
        size = 20,
        color= 0x489200,
        align = cc.TEXT_ALIGNMENT_LEFT,
    }):addTo(content):align(display.CENTER,471,35)
    item.got_label = got_label
    item.button = button
    item.time_label = time_label
    if flag == 1 then
        got_label:show()
        button:hide()
        time_label:hide()
        check_bg:show()
    else
        check_bg:hide()
        got_label:hide()
        if flag == 2 then
            time_label:hide()
        else
            button:hide()
            if timePoint == next_point then
                local time = self.online_time + app.timer:GetServerTime()
                local diff_time = config_online[timePoint].onLineMinutes * 60 - time
                time_label:setString(GameUtils:formatTimeStyle1(diff_time))
                self.need_update_online_item[timePoint] = item
            elseif timePoint > next_point then
                time_label:setString(_("还不能领取"))
                time_label:setColor(UIKit:hex2c3b(0x514d3e))
            end
        end
    end
    item:addContent(content)
    item:setMargin({left = 0, right = 0, top = 0, bottom = 5})
    item:setItemSize(556, 116,false)
    return item
end

function GameUIActivityRewardNew:RefreshOnLineList(needClean)
    if needClean then
        self.need_update_online_item = {}
        self.online_list_view:removeAllItems()
        local data = self:GetOnLineTimePointData()
        local next_point = self:GetNextOnlineTimePoint()
        -- 自动滑动到可领取的第一个奖励位置
        local item_pos
        for i,v in ipairs(data) do
            local reward_type,item_key,time_str,rewards,flag,timePoint = unpack(v)
            local item = self:GetOnLineItem(reward_type,item_key,time_str,rewards,flag,timePoint,next_point)
            if not item_pos and flag ~= 1 then
                item_pos = i
            end
            self.online_list_view:addItem(item)
        end
        self.online_list_view:reload()
        if item_pos then
            self.online_list_view:showItemWithPos(item_pos)
        end
    else
        local items = self.online_list_view:getItems()
        if #items <= 0 then return end
        self.need_update_online_item = {}
        local data = self:GetOnLineTimePointData()
        local next_point = self:GetNextOnlineTimePoint()
        for index,v in ipairs(data) do
            local item = items[index]
            local reward_type,item_key,time_str,rewards,flag,timePoint = unpack(v)
            if flag == 1 then
                item.got_label:show()
                item.button:hide()
                item.time_label:hide()
                if not item.sp:getFilter() then
                    item.sp:setFilter(filter.newFilter("CUSTOM", json.encode({frag = "shaders/ps_discoloration.fs",shaderName = "ps_discoloration"})))
                end
                item.sp.check_bg:show()
            else
                item.sp.check_bg:hide()
                item.got_label:hide()
                if flag == 2 then
                    item.time_label:hide()
                    item.button:show()
                    if item.sp:getFilter() then
                        item.sp:clearFilter()
                    end
                else
                    -- if not item.sp:getFilter() then
                    --  item.sp:setFilter(filter.newFilter("CUSTOM", json.encode({frag = "shaders/ps_discoloration.fs",shaderName = "ps_discoloration"})))
                    -- end
                    item.button:hide()
                    item.time_label:show()
                    if timePoint == next_point then
                        local time = self.online_time + app.timer:GetServerTime()
                        local diff_time = config_online[timePoint].onLineMinutes * 60 - time
                        item.time_label:setColor(UIKit:hex2c3b(0x489200))
                        item.time_label:setString(GameUtils:formatTimeStyle1(diff_time))
                        self.need_update_online_item[timePoint] = item
                    elseif timePoint > next_point then
                        item.time_label:setString(_("还不能领取"))
                        item.time_label:setColor(UIKit:hex2c3b(0x514d3e))
                    end
                end
            end
        end
    end
end
--flag 1.已领取 2.可以领取 3.还不能领取
function GameUIActivityRewardNew:GetOnLineTimePointData()
    local on_line_time = DataUtils:getPlayerOnlineTimeMinutes()
    local r = {}
    for __,v in pairs(config_online) do
        local flag = 3
        if v.onLineMinutes <= on_line_time then
            if self:IsTimePointRewarded(v.timePoint) then
                flag = 1
            else
                flag = 2
            end
        end
        local reward_type,item_key,count = unpack(string.split(v.rewards,":"))
        local name = self:GetRewardName(reward_type,item_key)
        table.insert(r,{reward_type,item_key,string.format(_("在线%s分钟"),v.onLineMinutes),name .. " x" .. count,flag,v.timePoint})
    end
    return r
end


function GameUIActivityRewardNew:IsTimePointRewarded(timepoint)
    local countInfo = User.countInfo
    for __,v in ipairs(countInfo.todayOnLineTimeRewards) do
        if v == timepoint then
            return true
        end
    end
    return false
end

function GameUIActivityRewardNew:GetNextOnlineTimePoint()
    local on_line_time = DataUtils:getPlayerOnlineTimeMinutes()
    for __,v in pairs(config_online) do
        if v.onLineMinutes > on_line_time then
            return v.timePoint
        end
    end
end
----------------------
function GameUIActivityRewardNew:ui_MONTH_CARD()
    self:CreateMonthCardBuyButton()
    self:CreateMonthCardListView()
    self:CreateMonthCardItemLogo()
end
function GameUIActivityRewardNew:GetMonthCardData()
    local v = GameDatas.PlayerInitData.monthCard[0]
    local temp_data = {}
    temp_data['productId'] = v.productId
    temp_data['price'] = string.format("%.2f",v.price)
    temp_data['name'] = _("连续30天每天获得奖励")
    local rewards,rewards_price = self:FormatGemRewards(v.dailyRewards)
    temp_data['rewards'] = rewards
    temp_data['rewards_price'] = rewards_price
    temp_data['config'] = UILib.iap_package_image[v.name]
    return temp_data
end

function GameUIActivityRewardNew:CreateMonthCardItemLogo()
    local data = self:GetMonthCardData()
    local content = display.newSprite(data.config.small_content)
        :align(display.CENTER_BOTTOM, 304, 380)
        :addTo(self.bg)
    UIKit:ttfLabel({
        text = data.name,
        color= 0xfed36c,
        size = 24,
        align = cc.TEXT_ALIGNMENT_CENTER,
    }):align(display.CENTER_TOP, 294, 182):addTo(content)
    local clip_rect = display.newClippingRegionNode(cc.rect(0,0,549,138)):addTo(content)
    local logo = display.newSprite(data.config.logo)
    local logo_box = display.newSprite("store_logo_box_592x141.png",296,69):addTo(logo):zorder(5)
    local bg = display.newScale9Sprite(data.config.desc):size(335,92)
    bg:align(display.RIGHT_CENTER, 592, 69):addTo(logo)
    -- local gem_box = display.newSprite("store_gem_box_260x116.png"):align(display.CENTER, 0, 46):addTo(bg)
    local gem_icon = display.newSprite(data.config.npc, 0, 54):addTo(bg)
    -- light_gem():addTo(gem_icon, 1022):pos(gem_icon:getContentSize().width/2,gem_icon:getContentSize().height/2):scale(1.2)
    UIKit:ttfLabel({
        text = _("礼包中包含下列所有物品"),
        size = 16,
        color= 0xfed36c
    }):align(display.BOTTOM_CENTER, 167,16):addTo(bg)
    UIKit:ttfLabel({
        text = "1200 X 30 = 36000",
        size = 20,
        color= 0xffd200
    }):align(display.CENTER, 167,60):addTo(bg)
    logo:align(display.LEFT_BOTTOM,0,2):addTo(clip_rect)
end

function GameUIActivityRewardNew:CreateMonthCardListView()
    local list_bg = display.newScale9Sprite("background_568x120.png", 0,0,cc.size(546,216),cc.rect(15,10,538,100))
        :addTo(self.bg)
        :align(display.BOTTOM_CENTER, 304, 138)
    self.mc_info_list = UIListView.new({
        viewRect = cc.rect(11,10, 524, 196),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }):addTo(list_bg)
    self:RefreshMonthCardListView()
end

function GameUIActivityRewardNew:RefreshMonthCardListView()
    self.mc_info_list:removeAllItems()
    local rewards = self:GetMonthCardData().rewards
    for index,v in ipairs(rewards) do
        local item = self:GetMonthCardItem(index,v)
        self.mc_info_list:addItem(item)
    end
    self.mc_info_list:reload()
end
function GameUIActivityRewardNew:FormatGemRewards(rewards)
    local result_rewards = {}
    local rewards_price = {}
    local all_rewards = string.split(rewards, ",")
    for __,v in ipairs(all_rewards) do
        local one_reward = string.split(v,":")
        local category,key,count = unpack(one_reward)
        table.insert(result_rewards,{category = category,key = key,count = count})
        rewards_price[key] = count
    end
    return result_rewards,DataUtils:getItemsPrice(rewards_price)
end
function GameUIActivityRewardNew:GetMonthCardItem(index,reward)
    local item = self.mc_info_list:newItem()
    local content = display.newScale9Sprite(string.format("back_ground_548x40_%d.png", index % 2 == 0 and 1 or 2)):size(524,48)
    local bg = display.newSprite("box_118x118.png"):align(display.LEFT_CENTER, 14, 24):addTo(content)
    local icon = display.newSprite(UILib.item[reward.key]):align(display.CENTER, 59, 58):addTo(bg)
    icon:scale(100/math.max(icon:getContentSize().width,icon:getContentSize().height))
    bg:scale(0.3)
    -- local icon = display.newSprite(UILib.item[reward.key]):align(display.LEFT_CENTER, 14, 24):addTo(content)
    -- icon:scale(36/math.max(icon:getContentSize().width,icon:getContentSize().height))
    local item_name = Localize_item.item_name[reward.key]
    UIKit:ttfLabel({
        text = item_name,
        size = 22,
        color= 0x403c2f
    }):align(display.LEFT_CENTER, 62, 24):addTo(content)

    UIKit:ttfLabel({
        text = "x " .. reward.count,
        size = 22,
        color= 0x403c2f,
        align = cc.TEXT_ALIGNMENT_RIGHT,
    }):align(display.RIGHT_CENTER, 507, 24):addTo(content)
    item:addContent(content)
    item:setItemSize(524, 48)
    return item
end

function GameUIActivityRewardNew:CreateMonthCardBuyButton()
    if User:IsMonthCardActived() then
        if User:IsMonthCardTodayRewardsGet() then
            UIKit:ttfLabel({
                text = _("今日已领取"),
                size = 22,
                color= 0x403c2f,
            }):addTo(self.bg):align(display.CENTER,304,64)
        else
            local button = WidgetPushButton.new({
                normal = "yellow_btn_up_186x66.png",
                pressed= "yellow_btn_down_186x66.png"
            }):setButtonLabel(UIKit:ttfLabel({
                text = _("领取"),
                size = 24,
                color= 0xfff3c7,
                shadow = true,
            })):onButtonClicked(function()
                NetManager:getMothcardRewardsPromise():done(function ()
                    GameGlobalUI:showTips(_("提示"),_("今日月卡奖励领取成功"))
                end)
                self:LeftButtonClicked()
            end):addTo(self.bg):pos(304,64)
        end
        local days = GameDatas.PlayerInitData.intInit.monthCardTotalDays.value
        UIKit:ttfLabel({
            text = string.format(_("已激活(%s)"),User:GetMonthCardActivateDay().."/"..days),
            size = 22,
            color= 0x007c23,
        }):addTo(self.bg):align(display.CENTER,304,114)
    else
        local button = WidgetPushButton.new({
            normal = "store_buy_button_n_332x76.png",
            pressed= "store_buy_button_l_332x76.png"
        })
        local icon = display.newSprite("store_buy_icon_332x76.png"):addTo(button)
        local label = UIKit:ttfLabel({
            text = _("购买"),
            size = 24,
            color= 0xfff3c7,
            shadow= true,
        })
        button:setButtonLabel("normal", label)
        button:setButtonLabelOffset(0, 20)

        local isCn = GameUtils:GetGameLanguage() == 'cn'
        UIKit:ttfLabel({
            text = isCn and "￥" .. DataUtils:GetRMBPrice(71.93) or "$71.93",
            size =  24,
            color= 0xffd200
        }):addTo(icon):align(display.RIGHT_BOTTOM, 146, 10)
        display.newSprite("icon_x_70x20.png"):addTo(icon):align(display.RIGHT_BOTTOM, 146, 14)

        display.newSprite("icon_arrow_18x18.png"):align(display.CENTER_BOTTOM, 166, 14):addTo(icon)
        UIKit:ttfLabel({
            text = isCn and "￥" .. DataUtils:GetRMBPrice(self:GetMonthCardData().price) or "$" .. self:GetMonthCardData().price,
            size =  24,
            color= 0xffd200
        }):addTo(icon):align(display.LEFT_BOTTOM, 186, 10)
        button:addTo(self.bg):pos(304,64)
        button:onButtonClicked(function()
            self:OnBuyMonthCardButtonClicked()
        end)
        UIKit:ttfLabel({
            text = _("未激活"),
            size = 22,
            color= 0x403c2f,
        }):addTo(self.bg):align(display.CENTER,304,120)
    end
end

function GameUIActivityRewardNew:OnBuyMonthCardButtonClicked()
    if device.platform == 'android' and not app:getStore().canMakePurchases() and not ext.paypal.isPayPalSupport() then
        UIKit:showMessageDialog(_("错误"),_("Google Play商店暂时不能购买,请检查手机Google Play商店的相关设置"))
        return
    end
    if device.platform == 'android' and ext.paypal.isPayPalSupport() then
        local productId = self:GetMonthCardData().productId
        local info = DataUtils:getIapInfo(productId)
        ext.paypal.buy(UIKit:getIapPackageName(productId),productId,tonumber(string.format("%.2f",info.price)))
    else
        app:getStore().purchaseWithProductId(self:GetMonthCardData().productId,1)
    end
    device.showActivityIndicator()
    self:LeftButtonClicked()
end
----------------------
function GameUIActivityRewardNew:ui_IAP_REWARD()
    self:CreateIapRewardItemLogo()
    self:CreateIapRewardItem()
end

function GameUIActivityRewardNew:CreateIapRewardItemLogo()
    local content = display.newSprite("store_item_content_red_s_588x186.png")
        :align(display.CENTER_BOTTOM, 304, 628)
        :addTo(self.bg)
    UIKit:ttfLabel({
        text = _("累计充值大回馈"),
        color= 0xfed36c,
        size = 24,
        align = cc.TEXT_ALIGNMENT_CENTER,
    }):align(display.CENTER_TOP, 284, 182):addTo(content)
    local clip_rect = display.newClippingRegionNode(cc.rect(0,0,549,138)):addTo(content)
    local logo = display.newSprite("gem_logo_592x139_5.png")
    local logo_box = display.newSprite("store_logo_box_592x141.png",296,69):addTo(logo):zorder(5)
    local bg = display.newScale9Sprite("store_desc_black_335x92.png")
    bg:align(display.RIGHT_CENTER, 592, 69):addTo(logo)
    local gem_box = display.newSprite("store_gem_box_260x116.png"):align(display.CENTER, 0, 46):addTo(bg)
    local gem_icon = display.newSprite("store_gem_260x116.png", 0, 50):addTo(bg)
    light_gem():addTo(gem_icon, 1022):pos(gem_icon:getContentSize().width/2,gem_icon:getContentSize().height/2):scale(1.2)
    UIKit:ttfLabel({
        text = _("购买金龙币可获得丰厚奖励"),
        size = 20,
        color= 0xffedae,
        align = cc.TEXT_ALIGNMENT_LEFT,
        shadow= true,
        dimensions = cc.size(200, 0)
    }):align(display.LEFT_CENTER, 60,60):addTo(bg)
    local str_1 = _("%s后结束")
    local s,e = string.find(str_1,"%%s")
    local str = string.format("[{\"type\":\"text\", \"value\":\"%s\"},{\"type\":\"text\",\"color\":0xa2ff00,\"size\":22,\"value\":\"%s\"},{\"type\":\"text\", \"value\":\"%s\"}]",
        string.sub(str_1,1,s - 1),User:GetIapLeftTime(),string.sub(str_1,e+1))
    local title_label = RichText.new({width = 400,size = 20,color = 0xffedae,shadow = true})
    title_label:Text(str):align(display.LEFT_BOTTOM,60,10):addTo(bg)
    scheduleAt(self, function()
        if User:IsIapActived() then
            local str_1 = _("%s后结束")
            local s,e = string.find(str_1,"%%s")
            local str = string.format("[{\"type\":\"text\", \"value\":\"%s\"},{\"type\":\"text\",\"color\":0xa2ff00,\"size\":22,\"value\":\"%s\"},{\"type\":\"text\", \"value\":\"%s\"}]",
                string.sub(str_1,1,s - 1),User:GetIapLeftTime(),string.sub(str_1,e+1))
            title_label:Text(str)
        else
            self:LeftButtonClicked()
        end
    end)
    logo:align(display.LEFT_BOTTOM,0,2):addTo(clip_rect)
end
function GameUIActivityRewardNew:CreateIapRewardItem()
    local buy_gem_bg = display.newSprite("title_red_564x54_1.png")
        :align(display.TOP_CENTER, 304,600)
        :addTo(self.bg)
    local my_score = User:GetIapGemCount()
    UIKit:ttfLabel({
        text = string.format(_("已购买:%s"),my_score),
        size = 22,
        color = 0xffcb4e,
        shadow = true
    }):align(display.CENTER,buy_gem_bg:getContentSize().width/2,buy_gem_bg:getContentSize().height/2 + 6)
        :addTo(buy_gem_bg)


    local citizen_num_bg = display.newSprite("citizen_num_bg_170x714.png")
        :align(display.LEFT_BOTTOM, 16, 20)
        :addTo(self.bg)
        :scale(121/170)

    local iapRewards = GameDatas.PlayerInitData.iapRewards
    local progress_percent = 0
    for i=0,4 do
        local v = iapRewards[i]
        if v.gemNeed <= my_score then
            progress_percent = progress_percent + 0.2
        else
            local pre_value = iapRewards[i - 1] and iapRewards[i - 1].gemNeed or 0
            local gap = v.gemNeed - pre_value
            local pass = my_score - pre_value
            progress_percent = progress_percent + 0.2 * pass / gap
            break
        end
    end
    if progress_percent > 0 then
        display.newScale9Sprite("line_92x1.png"):align(display.LEFT_TOP, 30, 36 + 478)
            :addTo(self.bg)
            :size(92,478 * progress_percent)
    end
    self.iap_btns = {}
    self.iap_labels = {}
    for i=0,4 do
        local v = iapRewards[i]
        local y = citizen_num_bg:getPositionY() + (#iapRewards - i) * 478/5
        local point_bg = display.newSprite(my_score >= v.gemNeed and "title_yellow_80x30.png" or "title_blue_80x30.png")
            :align(display.LEFT_BOTTOM, 128, y)
            :addTo(self.bg)
        UIKit:ttfLabel({
            text = GameUtils:formatNumber(v.gemNeed),
            size = 22,
            color = 0xffedae,
            shadow = true
        }):align(display.CENTER,point_bg:getContentSize().width/2,point_bg:getContentSize().height/2 + 2)
            :addTo(point_bg)

        local item_rewards = {}
        local tmp_rewards = string.split(v.rewards,",")
        for i,v in ipairs(tmp_rewards) do
            local tt = string.split(v,":")
            table.insert(item_rewards, {name = tt[2],count = tt[3]})
        end
        local item_bg = display.newSprite("box_118x118.png"):align(display.LEFT_BOTTOM, 238, y):addTo(self.bg):scale(74/118)
        local sp = display.newSprite(UIKit:GetItemImage("items",item_rewards[1].name),59,59):addTo(item_bg)
        local size = sp:getContentSize()
        sp:scale(90/math.max(size.width,size.height))
        UIKit:addTipsToNode(item_bg,Localize_item.item_name[item_rewards[1].name].." X "..item_rewards[1].count,self:getParent(),nil,50,10)
        local item_bg = display.newSprite("box_118x118.png"):align(display.LEFT_BOTTOM, 332, y):addTo(self.bg):scale(74/118)
        local sp = display.newSprite(UIKit:GetItemImage("items",item_rewards[2].name),59,59):addTo(item_bg)
        local size = sp:getContentSize()
        sp:scale(90/math.max(size.width,size.height))
        UIKit:addTipsToNode(item_bg,Localize_item.item_name[item_rewards[2].name].." X "..item_rewards[2].count,self:getParent(),nil,50,10)
        local button = WidgetPushButton.new(
            {normal = "yellow_btn_up_148x58.png", pressed = "yellow_btn_down_148x58.png",disabled = "grey_btn_148x58.png"}
        ):setButtonLabel(UIKit:ttfLabel({
            text = _("领取"),
            size = 20,
            color = 0xfff3c7,
            shadow = true
        })):addTo(self.bg):align(display.LEFT_BOTTOM, 426, y)
            :onButtonClicked(function(event)
                if event.name == "CLICKED_EVENT" then
                    local scoreRewardedIndex = User:GetIapRewardedIndex()+ 1
                    if scoreRewardedIndex ~= i then
                        UIKit:showMessageDialog(_("提示"),_("请首先领取前面的奖励"))
                        return
                    end
                    NetManager:getTotalIAPRewardsPromise():done(function ()
                        app:GetAudioManager():PlayeEffectSoundWithKey("BUY_ITEM")
                        GameGlobalUI:showTips(_("提示"),
                            _("获得").." "..Localize_item.item_name[item_rewards[1].name].." X "..item_rewards[1].count.." , "..Localize_item.item_name[item_rewards[2].name].." X "..item_rewards[2].count)
                        self:RefreshIaps()
                    end)
                end
            end)
        button:setButtonEnabled(User:GetIapRewardedIndex() < i and my_score >= v.gemNeed)
        button:setVisible(User:GetIapRewardedIndex() < i)
        self.iap_btns[i] = button
        local label = UIKit:ttfLabel({
            text = _("已领取"),
            size = 22,
            color = 0x403c2f,
        }):addTo(self.bg):align(display.CENTER_BOTTOM, 500, y + 20)
        label:setVisible(User:GetIapRewardedIndex() >= i)
        self.iap_labels[i] = label
    end
end
function GameUIActivityRewardNew:RefreshIaps()
    local my_score = User:GetIapGemCount()
    local iapRewards = GameDatas.PlayerInitData.iapRewards
    for i,label in pairs(self.iap_labels) do
        label:setVisible(User:GetIapRewardedIndex() >= i)
    end
    for i,button in pairs(self.iap_btns) do
        local v = iapRewards[i]
        button:setButtonEnabled(User:GetIapRewardedIndex() < i and my_score >= v.gemNeed)
        button:setVisible(User:GetIapRewardedIndex() < i)
    end
end
return GameUIActivityRewardNew


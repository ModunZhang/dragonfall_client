local window = import("..utils.window")
local UIPageView = import("..ui.UIPageView")
local WidgetChat = import("..widget.WidgetChat")
local WidgetChangeMap = import("..widget.WidgetChangeMap")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUICityInfo = UIKit:createUIClass('GameUICityInfo')
local light_gem = import("..particles.light_gem")

function GameUICityInfo:DisplayOn()
    self.visible_count = self.visible_count + 1
    self:FadeToSelf(self.visible_count > 0)
end
function GameUICityInfo:DisplayOff()
    self.visible_count = self.visible_count - 1
    self:FadeToSelf(self.visible_count > 0)
end
function GameUICityInfo:FadeToSelf(isFullDisplay)
    self:stopAllActions()
    if isFullDisplay then
        self:show()
        transition.fadeIn(self, {
            time = 0.2,
        })
    else
        transition.fadeOut(self, {
            time = 0.2,
            onComplete = function()
                self:hide()
            end,
        })
    end
end




function GameUICityInfo:ctor(user, location)
    self.visible_count = 1
    GameUICityInfo.super.ctor(self, {type = UIKit.UITYPE.BACKGROUND})
    self.user = user
    self.location = location
end

function GameUICityInfo:onEnter()
    GameUICityInfo.super.onEnter(self)
    self:CreateTop()
    self:CreateBottom()
end
function GameUICityInfo:onExit()
    GameUICityInfo.super.onExit(self)
end
function GameUICityInfo:CreateTop()
    local top_bg = display.newSprite("top_bg_768x117.png"):addTo(self)
        :align(display.TOP_CENTER, display.cx, display.top )
    if display.width>640 then
        top_bg:scale(display.width/768)
    end
    -- 玩家按钮
    local button = cc.ui.UIPushButton.new(
        -- {normal = "tmp_text_head.png", pressed = "tmp_text_head.png"},
        -- {scale9 = false}
        ):addTo(top_bg):align(display.LEFT_CENTER,64, top_bg:getContentSize().height/2)
    button:setContentSize(cc.size(90,100))
    -- 玩家名字背景加文字
    -- local ox = 159
    -- local name_bg = display.newSprite("player_name_bg_168x30.png"):addTo(top_bg)
    --     :align(display.TOP_LEFT, ox, top_bg:getContentSize().height-10):setCascadeOpacityEnabled(true)
    -- self.name_label = cc.ui.UILabel.new({
    --     text = self.user.basicInfo.name,
    --     size = 18,
    --     font = UIKit:getFontFilePath(),
    --     align = cc.ui.TEXT_ALIGN_RIGHT,
    --     color = UIKit:hex2c3b(0xf3f0b6)
    -- }):addTo(name_bg):align(display.LEFT_CENTER, 14, name_bg:getContentSize().height/2 + 3)

    -- 战斗力按钮
    local power_button = cc.ui.UIPushButton.new(
        {normal = "power_btn_up_258x48.png", pressed = "power_btn_down_258x48.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            -- UIKit:newGameUI("GameUIPower"):AddToCurrentScene()
        end
    end):addTo(top_bg):align(display.TOP_CENTER, top_bg:getContentSize().width/2 + 24, top_bg:getContentSize().height - 6)
    -- 玩家战斗值文字
    UIKit:ttfLabel({
        text = _("战斗力"),
        size = 14,
        color = 0x9a946b,
    -- shadow = true
    }):addTo(power_button):align(display.CENTER, 0, -14)

    -- 玩家战斗值数字
    self.power_label = UIKit:CreateNumberImageNode({
        text = string.formatnumberthousands(self.user.basicInfo.power),
        size = 20,
        color = 0xf3f0b6,
    }):addTo(power_button):align(display.CENTER, 0, -36)

    -- 资源按钮
    local button = cc.ui.UIPushButton.new(
        -- {normal = "player_btn_up_314x86.png", pressed = "player_btn_down_314x86.png"},
        -- {scale9 = false}
        ):onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                -- UIKit:newGameUI("GameUIResourceOverview",self.city):AddToCurrentScene(true)
            end
        end):addTo(top_bg):align(display.LEFT_CENTER, 160, 40)
    button:setContentSize(cc.size(540,32))

    -- 资源图片和文字
    self.res_icon_map = {}
    local first_col = 18
    local label_padding = 15
    local padding_width = 105
    for i, v in ipairs({
        {"res_wood_82x73.png", "wood_label", "wood"},
        {"res_stone_88x82.png", "stone_label", "stone"},
        -- {"res_citizen_88x82.png", "citizen_label", "citizen"},
        {"res_food_91x74.png", "food_label", "food"},
        {"res_iron_91x63.png", "iron_label", "iron"},
        {"res_coin_81x68.png", "coin_label", "coin"},
    }) do
        local row = i > 3 and 1 or 0
        local col = (i - 1) % 3
        local x, y = first_col + (i - 1) * padding_width, 16
        self.res_icon_map[v[3]] = display.newSprite(v[1]):addTo(button):pos(x, y):scale(0.3)

        self[v[2]] = UIKit:ttfLabel({text = "-",
            size = 18,
            color = 0xf3f0b6,
        }):addTo(button):align(display.LEFT_CENTER,x + label_padding, y)
    end

    -- 玩家信息背景
    self.player_icon = UIKit:GetPlayerIconOnly(self.user.basicInfo.icon)
        :addTo(top_bg):align(display.LEFT_CENTER,69, top_bg:getContentSize().height/2 + 10):scale(0.65)
    local black_bg = display.newColorLayer(UIKit:hex2c4b(0xff000000))
    black_bg:setContentSize(cc.size(58,8))
    black_bg:addTo(top_bg):pos(95, 21)
    self.exp = display.newProgressTimer("player_exp_bar_62x12.png",
        display.PROGRESS_TIMER_BAR):addTo(top_bg):align(display.LEFT_CENTER,94, 24)
    self.exp:setBarChangeRate(cc.p(1,0))
    self.exp:setMidpoint(cc.p(0,0))

    local level_bg = display.newSprite("level_bg_85x20.png"):addTo(top_bg):align(display.LEFT_CENTER,69, 27):setCascadeOpacityEnabled(true)
    self.level_label = UIKit:CreateNumberImageNode({
        text = self.user:GetLevel().."",
        size = 14,
        color = 0xf3f0b6,
    }):addTo(level_bg):align(display.CENTER, 12, 9)
    -- vip
    local vip_btn = cc.ui.UIPushButton.new(
        {normal = "vip_btn_136x48.png"},
        {scale9 = false}
    ):align(display.TOP_LEFT, 150, top_bg:getContentSize().height - 6):addTo(top_bg)
        
    local vip_btn_img = UtilsForVip:IsVipActived(self.user) and "vip_bg_110x124.png" or "vip_bg_disable_110x124.png"
    self.vip_icon = display.newSprite("crown_gold_46x40.png",28,-24,{class=cc.FilteredSpriteWithOne}):addTo(vip_btn)
    self.vip_level = UIKit:ttfLabel({
        text =  "VIP "..self.user:GetVipLevel(),
        size = 20,
        shadow = true
    }):addTo(vip_btn):align(display.CENTER, self.vip_icon:getPositionX() + 55, self.vip_icon:getPositionY())
    if UtilsForVip:IsVipActived(self.user) then
        self.vip_level:setColor(UIKit:hex2c3b(0xffb400))
    else
        local my_filter = filter
        local filters = my_filter.newFilter("GRAY", {0.2, 0.3, 0.5, 0.1})
        self.vip_icon:setFilter(filters)
        self.vip_level:setColor(UIKit:hex2c3b(0xbfbfbf))
    end
    self.vip_btn = vip_btn

    -- 金龙币按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "gem_btn_up_149x47.png", pressed = "gem_btn_down_149x47.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
    end):addTo(top_bg):pos(top_bg:getContentSize().width - 143, top_bg:getContentSize().height - 30)
    local gem_icon = display.newSprite("store_gem_260x116.png"):addTo(button):pos(50, 0):scale(0.49)
    light_gem():addTo(gem_icon, 1022):pos(260/2, 116/2)

    self.gem_label = UIKit:ttfLabel({
        text ="-",
        size = 20,
        color = 0xffd200,
    }):addTo(button):align(display.CENTER, -14, 0)

    return top_bg
end


function GameUICityInfo:CreateBottom()
    -- 底部背景
    local bottom_bg = display.newSprite("bottom_bg_768x122.png")
        :align(display.BOTTOM_CENTER, display.cx, display.bottom)
        :addTo(self)
    bottom_bg:setTouchEnabled(true)
    if display.width >640 then
        bottom_bg:scale(display.width/768)
    end

    self.chat = WidgetChat.new():addTo(bottom_bg)
        :align(display.CENTER, bottom_bg:getContentSize().width/2, bottom_bg:getContentSize().height)

    cc.ui.UILabel.new({text = _("您正在访问其他玩家的城市, 无法使用其他功能, 点击左下角返回城市"),
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        valign = cc.ui.TEXT_VALIGN_CENTER,
        dimensions = cc.size(400, 100),
        color = UIKit:hex2c3b(0xe19319)})
        :addTo(bottom_bg):align(display.LEFT_CENTER, 250, display.bottom + 101/2)

    local map_node = WidgetChangeMap.new(WidgetChangeMap.MAP_TYPE.OTHER_CITY, self.location):addTo(self)
end
function GameUICityInfo:ChangeChatChannel(channel_index)
    self.chat:ChangeChannel(channel_index)
end
return GameUICityInfo
















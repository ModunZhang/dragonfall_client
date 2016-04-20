--
-- Author: Kenny Dai
-- Date: 2016-04-14 14:57:02
--
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local window = import("..utils.window")
local Enum = import("..utils.Enum")
local RichText = import("..widget.RichText")
local WidgetInfoWithTitle = import("..widget.WidgetInfoWithTitle")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUseItems = import("..widget.WidgetUseItems")
local VIP_LEVEL = GameDatas.Vip.level
local VIP_EFFECIVE_ALL_TYPE = Enum(
    "freeSpeedup",
    "helpSpeedup",
    "woodProductionAdd",
    "stoneProductionAdd",
    "ironProductionAdd",
    "foodProductionAdd",
    "citizenRecoveryAdd",
    "marchSpeedAdd",
    "normalGachaAdd",
    "storageProtectAdd",
    "wallHpRecoveryAdd",
    "dragonHpRecoveryAdd",
    "dragonExpAdd",
    "soldierAttackPowerAdd",
    "soldierHpAdd",
    "dragonLeaderShipAdd",
    "soldierConsumeSub"
)

-- VIP 效果总览
local VIP_EFFECIVE_ALL = {
    freeSpeedup = _("立即完成建筑时间"),
    helpSpeedup = _("协助加速效果提升"),
    woodProductionAdd = _("木材产量增加"),
    stoneProductionAdd = _("石料产量增加"),
    ironProductionAdd = _("铁矿产量增加"),
    foodProductionAdd = _("粮食产量增加"),
    citizenRecoveryAdd = _("城民增长速度"),
    marchSpeedAdd = _("提升行军速度"),
    normalGachaAdd = _("每日游乐场免费抽奖次数"),
    storageProtectAdd = _("暗仓保护上限提升"),
    wallHpRecoveryAdd = _("城墙修复速度提升"),
    dragonExpAdd =  _("巨龙获得经验值加成"),
    dragonHpRecoveryAdd =  _("巨龙体力恢复速度"),
    soldierAttackPowerAdd = _("所有军事单位攻击力提升"),
    soldierHpAdd = _("所有军事单位防御力提升"),
    dragonLeaderShipAdd = _("提升带兵上限"),
    soldierConsumeSub = _("维护费用减少"),
}
local GameUIVIPPop = class("GameUIVIPPop", WidgetPopDialog)

function GameUIVIPPop:ctor()
	GameUIVIPPop.super.ctor(self,580,_("激活VIP"),window.top - 140,"title_purple_656x124.png")
	self.title_sprite:setPositionY(580):zorder(20)
	self.title_label:setPositionY(self.title_sprite:getContentSize().height - 35)
	self.close_btn:setPosition(self.title_sprite:getContentSize().width - 25,self.title_sprite:getContentSize().height/2+16)
end
function GameUIVIPPop:onEnter()
	GameUIVIPPop.super.onEnter(self)
	local body = self.body
	local b_size = body:getContentSize()
	display.newSprite("gem_logo_592x139_4.png"):align(display.TOP_CENTER, b_size.width/2 , b_size.height - 5):addTo(body):flipX(true):scale(0.96)
	local shadowLayer = UIKit:shadowLayer():align(display.TOP_CENTER, 20 , b_size.height - 138):addTo(body)
	shadowLayer:setContentSize(568,133)
	display.newScale9Sprite("box_50x50.png",0,0, cc.size(574,140), cc.rect(20,20,10,10)):align(display.TOP_CENTER, b_size.width/2 , b_size.height ):addTo(body)

    local title_bg = display.newSprite("title_green_474x38.png"):align(display.LEFT_CENTER, b_size.width/2 - 180,b_size.height - 55):addTo(body)
    UIKit:ttfLabel({
    	text = _("激活VIP"),
    	size = 22,
    	color = 0xfffff3c7
    	}):align(display.LEFT_CENTER, 60, title_bg:getContentSize().height/2)
    :addTo(title_bg)

    local vip_level = User:GetVipLevel()
    
    local contenet_label = RichText.new({width = 180,size = 24,color = 0x403c2f})
        local str = "[{\"type\":\"text\",\"color\":\"0xffffd200\", \"value\":\"≤\"},{\"type\":\"text\", \"color\":\"0xff7eff00\", \"value\":\"%d\"},{\"type\":\"text\", \"color\":\"0xffffd200\", \"value\":\"%s\"}]"
        str = string.format(str,VIP_LEVEL[vip_level].freeSpeedup,_("分钟免费加速"))
        contenet_label:Text(str):align(display.LEFT_CENTER,b_size.width/2 - 126,b_size.height - 96):addTo(body)
	-- 当前vip等级
    local current_level = display.newSprite("vip_unlock_normal.png"):align(display.CENTER, b_size.width/2 - 180,b_size.height - 65):addTo(body)

    display.newSprite("VIP_"..vip_level.."_46x32.png"):addTo(current_level)
        :align(display.CENTER,48,45)

    local info_message = self:GetVipMessage()
    WidgetInfoWithTitle.new({
        info = info_message,
        title = _("额外拥有"),
        h = 306,
        style = "beside"
    }):addTo(body)
        :align(display.BOTTOM_CENTER, b_size.width/2, b_size.height/2 - 180)
    
    -- 激活VIP按钮
    local active_button = WidgetPushButton.new(
        {normal = "yellow_btn_up_186x66.png", pressed = "yellow_btn_down_186x66.png"},
        {scale9 = false},
        {
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        }
    ):setButtonLabel(UIKit:ttfLabel({
        text = _("激活VIP"),
        size = 20,
        color = 0xfff3c7,
        shadow = true
    }))
        :addTo(body):align(display.CENTER, b_size.width/2, 60)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                WidgetUseItems.new():Create({
                    item_name = "vipActive_1"
                }):AddToCurrentScene()
            end
        end)
end
function GameUIVIPPop:GetVipMessage()
    local vip_level = User:GetVipLevel()
    local config = VIP_LEVEL[vip_level]
    local info_message = {}
	for i,v in ipairs(VIP_EFFECIVE_ALL_TYPE) do
		if config[v] > 0 then
			local isPercentage = v ~= "freeSpeedup" and v ~= "normalGachaAdd"
			local text = ""
			if isPercentage then
				text = (config[v] * 100).."%"
			elseif v == "freeSpeedup" then
				text = config[v].._("分钟")
			end
			table.insert(info_message, {VIP_EFFECIVE_ALL[v],{text,0xff007c23}})
		end
	end
	return info_message
end
return GameUIVIPPop
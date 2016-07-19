--
-- Author: Kenny Dai
-- Date: 2015-01-16 11:14:47
--
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")

local WidgetInput = class("WidgetInput", WidgetPopDialog)

function WidgetInput:ctor(params)
    WidgetInput.super.ctor(self,210,_("调整数量"),display.top-400)
    self:DisableCloseBtn()
    local body = self.body
    local unit = params.unit or ""
    local exchange = 1
    if unit == "K" then
        exchange = 1000
    end
    local max = params.max * exchange
    local current = (params.current or 0) * exchange
    local min = (params.min or 0) * exchange
    local callback = params.callback or NOT_HANDLE
    self.current_value = current
    -- max 有时会变化
    self.max = max

    local function edit(event, editbox)
        local text = self.current_value
        text = text < min and min or text
        text = text > self.max and self.max or text
        if event == "began" then
            if text == 0 then
                editbox:setText("")
            else
                editbox:setText(text)
                self.perfix_lable:setString(string.format("/ %s", GameUtils:formatNumber(max)))
            end
            editbox:visibleText(false)
        elseif event == "ended" then
            if editbox:getText()=="" or min>text then
                local btn_value
                local btn_unit  = ""
                if min >= 1000 then
                    local f_value = GameUtils:formatNumber(min)
                    btn_value = string.sub(f_value,1,-2)
                    btn_unit = string.sub(f_value,-1,-1)
                else
                    btn_value = min
                end
                editbox:setText(btn_value)
                self.perfix_lable:setString(string.format(btn_unit.."/ %s", GameUtils:formatNumber(max)))
                self.current_value = min
            else
                local change_text = editbox:getText()
                local change_value = change_text == "" and min or tonumber(change_text)
                change_value = change_value < min and min or change_value
                change_value = change_value > self.max and self.max or change_value
                local e_value = change_value
                local btn_value
                local btn_unit  = ""
                if e_value>=1000 then
                    local f_value = GameUtils:formatNumber(e_value)
                    btn_value = string.sub(f_value,1,-2)
                    btn_unit = string.sub(f_value,-1,-1)
                else
                    btn_value = e_value
                end
                editbox:setText(btn_value)
                self.perfix_lable:setString(string.format(btn_unit.."/ %s", GameUtils:formatNumber(max)))

                self.current_value = e_value
            end
            callback(math.floor(self.current_value/exchange))
        end
    end

    local bg1 = WidgetUIBackGround.new({width = 558,height=90},WidgetUIBackGround.STYLE_TYPE.STYLE_4)
        :align(display.CENTER,304, 130):addTo(body)

    -- soldier current
    self.editbox = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "back_ground_83x32.png",
        size = cc.size(100,32),
        font = UIKit:getFontFilePath(),
        listener = edit
    })
    local editbox = self.editbox
    local btn_value,btn_unit = current,""
    if current>=1000 then
        local f_value = GameUtils:formatNumber(current)
        btn_value = string.sub(f_value,1,-2)
        btn_unit = string.sub(f_value,-1,-1)
    else
        btn_value = current
    end
    editbox:setMaxLength(10)
    editbox:setText(btn_value)
    editbox:setFont(UIKit:getFontFilePath(),20)
    editbox:setFontColor(cc.c3b(0,0,0))
    editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editbox:align(display.CENTER, body:getContentSize().width/2,body:getContentSize().height/2+20):addTo(body)

    self.perfix_lable = UIKit:ttfLabel({
        text = string.format(btn_unit.."/ %s", GameUtils:formatNumber(max)),
        size = 20,
        color = 0x403c2f
    }):addTo(body)
        :align(display.LEFT_CENTER, editbox:getPositionX()+70,editbox:getPositionY())

    WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("确定"),
            size = 22,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                callback(math.floor(self.current_value/exchange))
                self:LeftButtonClicked()
            end
        end):align(display.CENTER, editbox:getPositionX(),editbox:getPositionY()-80):addTo(body)
end
function WidgetInput:SetMax( max )
    self.max = max
end
function WidgetInput:onEnter()
    WidgetInput.super.onEnter(self)
    self.editbox:touchDownAction(editbox,2)
end
return WidgetInput








--
-- Author: Kenny Dai
-- Date: 2016-07-28 14:42:15
-- 部队阵型
--
local window = import("..utils.window")
local WidgetPopDialog = import(".WidgetPopDialog")
local WidgetUIBackGround = import(".WidgetUIBackGround")
local WidgetPushButton = import(".WidgetPushButton")
local WidgetTroopFormation = class("WidgetTroopFormation", WidgetPopDialog)
local filter_soldier_data = function ( soldiers )
    local filter_data = {}
    for i,v in ipairs(soldiers) do
        table.insert(filter_data, v.name)
    end
    return filter_data
end
function WidgetTroopFormation:ctor(soldiers,cb)
    WidgetTroopFormation.super.ctor(self, 490, _("阵型"), display.cy + 300)
    self.soldiers = filter_soldier_data(soldiers)
    self.cb = cb
end
function WidgetTroopFormation:onEnter()
    WidgetTroopFormation.super.onEnter(self)
    local body = self:GetBody()
    local size = body:getContentSize()
    local formation_soldiers = self:GetFormation()
    self.formation_names = {}
    for i = 1,3 do
        local content = WidgetUIBackGround.new({width = 556,height = 128},WidgetUIBackGround.STYLE_TYPE.STYLE_5)
            :align(display.CENTER,size.width/2,size.height - (i - 1) * 148 - 100)
            :addTo(body)
        local title_bg = display.newSprite("title_blue_544x32.png")
            :align(display.TOP_CENTER, 556/2, 124):addTo(content)
        local title = UIKit:ttfLabel({
            text = "",
            size = 22,
            color = 0xffedae,
        }):align(display.CENTER, title_bg:getContentSize().width/2, title_bg:getContentSize().height/2):addTo(title_bg)
        self.formation_names[i] = title
        display.newSprite("alliance_notice_icon_26x26.png"):addTo(title_bg):align(display.RIGHT_CENTER,title_bg:getContentSize().width - 20,title_bg:getContentSize().height/2)
        local button = WidgetPushButton.new()
            :addTo(title_bg):align(display.RIGHT_CENTER, title_bg:getContentSize().width - 20,title_bg:getContentSize().height/2)
            :onButtonClicked(function(event)
                if event.name == "CLICKED_EVENT" then
                    self:OpenChangeFormationName(i)
                end
            end)
        button:setContentSize(cc.size(100,32))
        button:setTouchSwallowEnabled(true)
        local formation = formation_soldiers[i]
        if formation and not LuaUtils:table_empty(formation) then
            WidgetPushButton.new({normal = "red_btn_up_148x58.png",pressed = "red_btn_down_148x58.png"})
                :setButtonLabel(UIKit:ttfLabel({
                    text = _("覆盖"),
                    size = 24,
                    color = 0xffedae,
                    shadow= true
                }))
                :onButtonClicked(function(event)
                    if event.name == "CLICKED_EVENT" then
                        if LuaUtils:table_empty(self.soldiers) then
                            UIKit:showMessageDialog(_("主人"),_("请为阵型加入士兵"))
                            return
                        end
                        UIKit:showMessageDialog(_("主人"),_("是否确认覆盖"),function ( ... )
                            self:SetFormation(title:getString(),self.soldiers,i)
                            GameGlobalUI:showTips(_("提示"),_("覆盖阵型成功"))
                            self:LeftButtonClicked()
                        end,function ()
                        end)
                    end
                end):align(display.CENTER,150,45):addTo(content)
            WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
                :setButtonLabel(UIKit:ttfLabel({
                    text = _("读取"),
                    size = 24,
                    color = 0xffedae,
                    shadow= true
                }))
                :onButtonClicked(function(event)
                    if event.name == "CLICKED_EVENT" then
                        self.cb(formation.soldiers)
                        GameGlobalUI:showTips(_("提示"),_("读取阵型成功"))
                        self:LeftButtonClicked()
                    end
                end):align(display.CENTER,556 - 150, 45):addTo(content)
            title:setString(formation.name)
        else
            WidgetPushButton.new({normal = "blue_btn_up_148x58.png",pressed = "blue_btn_down_148x58.png"})
                :setButtonLabel(UIKit:ttfLabel({
                    text = _("存储"),
                    size = 24,
                    color = 0xffedae,
                    shadow= true
                }))
                :onButtonClicked(function(event)
                    if event.name == "CLICKED_EVENT" then
                        if LuaUtils:table_empty(self.soldiers) then
                            UIKit:showMessageDialog(_("主人"),_("请为阵型加入士兵"))
                            return
                        end
                        self:SetFormation(title:getString(),self.soldiers,i)
                        GameGlobalUI:showTips(_("提示"),_("存储阵型成功"))
                        self:LeftButtonClicked()
                    end
                end):align(display.CENTER,556/2, 45):addTo(content)
            title:setString(_("阵型").." "..i)
        end
    end
end
function WidgetTroopFormation:onExit()
    WidgetTroopFormation.super.onExit(self)
end
function WidgetTroopFormation:GetFormation()
    return app:GetGameDefautlt():getTableForKey("Formation:"..User._id,{})
end
function WidgetTroopFormation:SetFormation(formation_name,soldiers,index)
    local formation_soldiers = self:GetFormation()
    if formation_soldiers[index] then
        table.remove(formation_soldiers,index)
    end
    local formation = {
        name = formation_name,
        soldiers = soldiers
    }
    table.insert(formation_soldiers, index, formation)
    return app:GetGameDefautlt():setTableForKey("Formation:"..User._id,formation_soldiers)
end
function WidgetTroopFormation:OpenChangeFormationName(index)
    local dialog = UIKit:newWidgetUI("WidgetPopDialog",180,_("更改阵型名称"),window.top-230):AddToCurrentScene()
    local body = dialog:GetBody()
    local size = body:getContentSize()
    local editbox = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "input_box.png",
        size = cc.size(576,48),
        font = UIKit:getFontFilePath(),
    })
    editbox:setPlaceHolder(eidtbox_holder)
    editbox:setMaxLength(20)
    editbox:setFont(UIKit:getEditBoxFont(),22)
    editbox:setFontColor(cc.c3b(0,0,0))
    editbox:setPlaceholderFontColor(cc.c3b(204,196,158))
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editbox:align(display.LEFT_TOP,16, size.height-30)
    editbox:addTo(body)
    WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("确定"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                local newName = string.trim(editbox:getText())
                if string.len(newName) == 0 then
                    UIKit:showMessageDialog(_("主人"),_("请输入新的阵型名称"))
                else
                    self.formation_names[index]:setString(newName)
                    dialog:LeftButtonClicked()
                end
            end
        end):align(display.CENTER,size.width/2, 60):addTo(body)
end
return WidgetTroopFormation

































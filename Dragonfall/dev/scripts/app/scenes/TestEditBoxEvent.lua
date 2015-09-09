--
-- Author: Danny He
-- Date: 2015-09-09 14:42:55
--
local TestEditBoxEvent = class("TestEditBoxEvent", function()
    return display.newScene("TestEditBoxEvent")
end)

function TestEditBoxEvent:ctor()
	app:createGrid(self)
    ext.registereForRemoteNotifications()
    self:createEditBox()
    app:createTitle(self, "Test EditBox Event Bug")
    app:createNextButton(self)
end

function TestEditBoxEvent:createEditBox()
	local onEdit = function(event)
        dump(event,"--event--")
    end
	local editbox = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "input_box.png",
        size = cc.size(417,51),
        listener = onEdit,
    })
    editbox:setMaxLength(140)
    editbox:setPlaceHolder(string.format("最多可输入%d字符",140))
    -- edit box 和 textview还未实现
    local fontArg = "DroidSansFallback"
    if device.platform == 'android' then
        fontArg = app:getFontFilePath()
    end
    editbox:setFont(fontArg,22)
    editbox:setFontColor(cc.c3b(0,0,0))
    editbox:setPlaceholderFontColor(cc.c3b(204,196,158))
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    editbox:align(display.CENTER,display.cx, display.cy):addTo(self)

    app:getCommonButton("test"):onButtonClicked(handler(self, self.CreateTestNode)):addTo(self):align(display.CENTER_BOTTOM,display.cx , display.bottom + 100)
end

function TestEditBoxEvent:CreateTestNode()
	if self.layer then
		self.layer:setVisible(not self.layer:isVisible())
	else
		local layer = display.newColorLayer(cc.c4b(255,0,0,255)):size(500,500)
		layer:setTouchEnabled(true)
		layer:addTo(self):align(display.CENTER,display.cx - 250, display.cy - 250)
		self.layer = layer
	end
end

return TestEditBoxEvent
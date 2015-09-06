--
-- Author: Danny He
-- Date: 2015-09-06 10:34:57
--
local TestBaseScene = class("TestBaseScene", function()
    return display.newScene("TestBaseScene")
end)
TestBaseScene.PUSH_BUTTON_IMAGES = {
    normal = "Button01.png",
    pressed = "Button01Pressed.png",
    disabled = "Button01Disabled.png",
}

function TestBaseScene:ctor()
	app:createGrid(self)

    self:createEditBox()
    self:createTestButton()
    app:createTitle(self, "Test UIButton")
    app:createNextButton(self)
end

function TestBaseScene:createEditBox()
	 local editbox = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "EditBoxBg.png",
        size = cc.size(417,51),
        listener = onEdit,
    })
    editbox:setPlaceHolder(string.format("最多可输入%d字符",140))
    editbox:setMaxLength(140)
    -- editbox:setFont(UIKit:getEditBoxFont(),22)
    -- editbox:setFontColor(cc.c3b(0,0,0))
    -- editbox:setPlaceholderFontColor(cc.c3b(204,196,158))
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    editbox:align(display.CENTER,display.cx, display.top - 70):addTo(self)
end

function TestBaseScene:createTestButton()
     cc.ui.UIPushButton.new(TestBaseScene.PUSH_BUTTON_IMAGES, {scale9 = true})
        :setButtonSize(240, 60)
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "Log Debug",
            size = 18
        }))
        :onButtonClicked(function(event)
            print("-------------------------------------")
            dump(cc.FileUtils:getInstance():getSearchPaths(),"getSearchPaths--->")
            print("-------------------------------------")
            
        end)
        :align(display.CENTER, display.cx, display.top - 150)
        :addTo(self)
end

return TestBaseScene
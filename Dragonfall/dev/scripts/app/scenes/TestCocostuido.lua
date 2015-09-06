--
-- Author: Danny He
-- Date: 2015-09-06 22:11:53
--
local TestCocostuido = class("TestCocostuido", function()
    return display.newScene("TestCocostuido")
end)


TestCocostuido.PUSH_BUTTON_IMAGES = {
    normal = "Button01.png",
    pressed = "Button01Pressed.png",
    disabled = "Button01Disabled.png",
}

function TestCocostuido:ctor()
	app:createGrid(self)
    app:createTitle(self, "TestCocostuido")
    app:createNextButton(self)
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:addArmatureFileInfo("animations/Box_guang.ExportJson")
    local guang_box = ccs.Armature:create("Box_guang"):addTo(self):align(display.CENTER, display.cx, display.top - 200)

    -- guang_box:getAnimation():play("Animation1", -1, -1)
    self.guang_box = guang_box
    self:createTestButton()
end


function TestCocostuido:createTestButton()
     cc.ui.UIPushButton.new(TestCocostuido.PUSH_BUTTON_IMAGES, {scale9 = true})
        :setButtonSize(240, 60)
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "Play",
            size = 18
        }))
        :onButtonClicked(function(event)
        	self.guang_box:getAnimation():play("Animation1", -1, -1)
        end)
        :align(display.LEFT_BOTTOM, display.left, display.bottom + 200)
        :addTo(self)
    cc.ui.UIPushButton.new(TestCocostuido.PUSH_BUTTON_IMAGES, {scale9 = true})
        :setButtonSize(240, 60)
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "Stop",
            size = 18
        }))
        :onButtonClicked(function(event)
        	self.guang_box:getAnimation():stop()
        end)
        :align(display.RIGHT_BOTTOM, display.right, display.bottom + 200)
        :addTo(self)

    cc.ui.UIPushButton.new(TestCocostuido.PUSH_BUTTON_IMAGES, {scale9 = true})
        :setButtonSize(240, 60)
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "pause",
            size = 18
        }))
        :onButtonClicked(function(event)
        	self.guang_box:getAnimation():pause()
        end)
        :align(display.LEFT_BOTTOM, display.left, display.bottom + 100)
        :addTo(self)


    cc.ui.UIPushButton.new(TestCocostuido.PUSH_BUTTON_IMAGES, {scale9 = true})
        :setButtonSize(240, 60)
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "resume",
            size = 18
        }))
        :onButtonClicked(function(event)
        	self.guang_box:getAnimation():resume()
        end)
        :align(display.RIGHT_BOTTOM, display.right, display.bottom + 100)
        :addTo(self)
end

return TestCocostuido
--
-- Author: Danny He
-- Date: 2015-09-07 09:08:28
--

local TestTexture = class("TestTexture", function()
    return display.newScene("TestTexture")
end)

function TestTexture:ctor()
	app:createGrid(self)
    app:createTitle(self, "TestTexture")
    app:createNextButton(self)
    self:createTest()
end


function TestTexture:createTest()
	local pvr_image = "animations/ui_animation_0.pvr.ccz"
	if device.platform == 'android' then
		pvr_image = "animations/ui_animation_0.png"
	end
	local pvr = display.newSprite(pvr_image, display.cx, display.cy):addTo(self)
	local pvrtool = display.newSprite("images/battleHunger_128x128.png", display.cx, display.cy):addTo(self)
	app:getCommonButton("Image Info"):onButtonClicked(function()
		print("hasPremultipliedAlpha--->ui_animation_0.pvr.ccz",pvr:getTexture():hasPremultipliedAlpha())
		print("hasPremultipliedAlpha--->battleHunger_128x128.png",pvrtool:getTexture():hasPremultipliedAlpha())
	end):align(display.CENTER, display.cx, display.bottom + 50):addTo(self)

end



return TestTexture
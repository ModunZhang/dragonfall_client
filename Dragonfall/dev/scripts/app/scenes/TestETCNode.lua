--
-- Author: Danny He
-- Date: 2015-09-07 14:27:28
--

local TestETCNode = class("TestETCNode", function()
    return display.newScene("TestETCNode")
end)

function TestETCNode:ctor()
	app:createGrid(self)
    self:createTest()
    app:createTitle(self, "TestETCNode")
    app:createNextButton(self)
end


function TestETCNode:createTest()
	-- Scale9Sprite
	display.newScale9Sprite("images/battleHunger_128x128.png"):align(display.CENTER,display.cx, display.top - 100):addTo(self)
	-- ProgressTimer
	local progressFill = display.newSprite("images/battleHunger_128x128.png")
    local ProgressTimer = cc.ProgressTimer:create(progressFill)
    ProgressTimer:setType(display.PROGRESS_TIMER_BAR)
    ProgressTimer:setBarChangeRate(cc.p(1,0))
    ProgressTimer:setMidpoint(cc.p(0,0))
    ProgressTimer:align(display.CENTER,display.cx, display.top - 300):addTo(self)
    ProgressTimer:setPercentage(50)

    -- frame
    display.addSpriteFrames("animations/ui_animation_0.plist","animations/ui_animation_0.png",function()
    	display.newSprite("#55.png"):align(display.CENTER,display.cx, display.top - 500):addTo(self)
    end)

    -- shaders
    display.newFilteredSprite("images/battleHunger_128x128.png", "CUSTOM", json.encode({frag = "shaders/ps_discoloration.fs",shaderName = "ps_discoloration"})):align(display.CENTER,display.cx, display.top - 600):addTo(self)

    -- shader + frame
    display.newFilteredSprite("#55.png", "CUSTOM", json.encode({frag = "shaders/ps_discoloration.fs",shaderName = "ps_discoloration"})):align(display.CENTER,display.cx, display.top - 700):addTo(self)
end

return TestETCNode
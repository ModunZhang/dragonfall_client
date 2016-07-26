--
-- Author: Kenny Dai
-- Date: 2016-07-26 10:53:20
--
local WidgetProgressCountDown = class("WidgetProgressCountDown",function ()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    node:setTouchEnabled(true)
    return node
end)

function WidgetProgressCountDown:ctor(cute_time)
    local progress = display.newSprite("progress_bg_116x89.png"):addTo(self)
    self.cute_time = cute_time
    self.time = UIKit:ttfLabel({
        text = GameUtils:formatTimeStyle1(cute_time - app.timer:GetServerTime()),
        size = 22,
        color = 0xff3c00
    }):align(display.CENTER, 0, 0):addTo(self)
end

function WidgetProgressCountDown:onEnter()
    scheduleAt(self, function()
        if self.cute_time - app.timer:GetServerTime() > 0 then
            self.time:setString(GameUtils:formatTimeStyle1(self.cute_time - app.timer:GetServerTime()))
        else
    		self:removeFromParent(true)
        end
    end)
end

return WidgetProgressCountDown


local GameUIFteDefenceDragon = UIKit:createUIClass("GameUIFteDefenceDragon", "GameUISendTroopNew")

local WidgetFteArrow = import("..widget.WidgetFteArrow")
function GameUIFteDefenceDragon:Find()
    return self.march_btn
end
function GameUIFteDefenceDragon:OnMoveInStage()
	GameUIFteDefenceDragon.super.OnMoveInStage(self)

    return self:PromiseOfMax():next(function()
        local r = self:Find():getCascadeBoundingBox()
        self:GetFteLayer():SetTouchObject(self:Find())
        WidgetFteArrow.new(_("点击按钮：驻防")):addTo(self:GetFteLayer())
        :TurnRight():align(display.RIGHT_CENTER, r.x - 10, r.y + r.height/2)
        return self:PromiseOfAttack()
    end)
end

return GameUIFteDefenceDragon
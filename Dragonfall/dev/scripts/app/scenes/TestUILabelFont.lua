--
-- Author: Danny He
-- Date: 2015-09-06 17:24:14
--

local TestUILabelFont = class("TestUILabelFont", function()
    return display.newScene("TestUILabelFont")
end)

function TestUILabelFont:ctor()
	app:createGrid(self)
    app:createTitle(self, "Test UILabelFont")
    self:createTest()
    app:createNextButton(self)
end

function TestUILabelFont:createTest()
	print("isFileExist-->",app:getFontFilePath(),cc.FileUtils:getInstance():isFileExist(app:getFontFilePath()))
	cc.ui.UILabel.new({
		text = "Font File Test:g",
		size = 24, 
		color = display.COLOR_BLACK,
		font = app:getFontFilePath()
	}):align(display.CENTER, display.cx, display.top - 70):addTo(self)

	local label = cc.ui.UILabel.new({
		text = "gg,省略号Label测试.阿西吧",
		size = 24, 
		color = display.COLOR_BLACK,
		font = app:getFontFilePath(),
		dimensions = cc.size(240, 30)
	}):align(display.CENTER, display.cx, display.top - 120):addTo(self)

	label:setLineBreakWithoutSpace(true)
	label:setEllipsisEabled(true)
end

return TestUILabelFont
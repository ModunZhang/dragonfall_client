--
-- Author: dannyhe
-- Date: 2014-08-05 17:34:54
--
local LogoScene = class("LogoScene", function()
    return display.newScene("LogoScene")
end)
function LogoScene:ctor()
    self:loadSplashResources()
end
local UIPageView = import("..ui.UIPageView")
local UIListView = import("..ui.UIListView")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")

function LogoScene:onEnter()
    --关闭屏幕锁定定时器
    if ext.disableIdleTimer then
        ext.disableIdleTimer(true)
    end
    self.layer = cc.LayerColor:create(cc.c4b(255,255,255,255)):addTo(self)
    self.sprite = display.newSprite("batcat_logo_368x507.png", display.cx, display.cy):addTo(self.layer)
    self:performWithDelay(function() self:beginAnimate() end,0.5)

   --  local sprite = display.newLayer():addTo(self):pos(0,display.top + 200)
   --   local listview = UIListView.new{
   --      bgColor = UIKit:hex2c4b(0x7a10aaee),
   --      viewRect = cc.rect(display.left+60 ,display.bottom+50, 550 , 514),
   --      direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
   --  }:addTo(sprite)
   --  for i=1,20 do
   --      local item = listview:newItem()
   --      item:setItemSize(550,170)
   --      local content = display.newSprite("background_550x170.jpg")
   --      UIKit:ttfLabel({
   --          text ="item>>>"..i,
   --          size = 30,
   --          color = 0xffedae,
   --          shadow = true,
   --      }):addTo(content):pos(100,80)
   --      item:addContent(content)
                       
   --      listview:addItem(item)
   --  end
   --  listview:reload()
   --   local button = WidgetPushButton.new({normal = "green_btn_up_148x58.png",pressed = "green_btn_down_148x58.png"}
   --          ,{}
   --          ,{
   --              disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
   --          })
   --          :setButtonLabel(UIKit:ttfLabel({
   --              text ="reset",
   --              size = 20,
   --              color = 0xffedae,
   --              shadow = true,
   --          }))
   --          :onButtonClicked(function(event)
   --              if event.name == "CLICKED_EVENT" then
   --                  sprite:setPositionY(0)
   --              end
   --          end)
   --          :align(display.CENTER_BOTTOM, display.cx - 100, display.bottom+80)
   --          :addTo(self)

   -- local button = WidgetPushButton.new({normal = "green_btn_up_148x58.png",pressed = "green_btn_down_148x58.png"}
   --          ,{}
   --          ,{
   --              disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
   --          })
   --          :setButtonLabel(UIKit:ttfLabel({
   --              text ="restart",
   --              size = 20,
   --              color = 0xffedae,
   --              shadow = true,
   --          }))
   --          :onButtonClicked(function(event)
   --              if event.name == "CLICKED_EVENT" then
   --                  sprite:setPositionY(display.top + 199)
   --                  -- transition.moveTo(sprite,{
   --                  --     x = 0,
   --                  --     y = display.top - 100,
   --                  --     time = 0.15,
   --                  --     onComplete = function()
   --                  --         print("y====",sprite:getPositionY())
   --                  --         -- transition.fadeOut(self:GetTitleBar(),{
   --                  --         --     time = 0.05,
   --                  --         --     onComplete = function()
   --                  --         --         self:OnMoveOutStage()
   --                  --         --     end
   --                  --         -- })
   --                  --     end
   --                  -- })
   --              end
   --          end)
   --          :align(display.CENTER_BOTTOM, display.cx + 100, display.bottom+80)
   --          :addTo(self)


--     local stencil = display.newNode()
--     local child_layer = display.newColorLayer(UIKit:hex2c4b(0x889aafff))
--     child_layer:setContentSize(cc.size(520,514))
--     child_layer:pos(display.left + 60,display.bottom + 200)
--     child_layer:setTouchSwallowEnabled(false)
--     stencil:addChild(child_layer)


--     local clippingNode = cc.ClippingNode:create(stencil):pos(0,0):addTo(self)
--     clippingNode:setInverted(false)
--     clippingNode:setAlphaThreshold(0.5)
--     local listview = UIListView.new{
--         bgColor = UIKit:hex2c4b(0x7a10aaee),
--         viewRect = cc.rect(display.left + 60,display.bottom + 200, 520 , 514),
--         direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
--     }
--     clippingNode:addChild(listview)
--     -- local listview = UIListView.new{
--     --     bgColor = UIKit:hex2c4b(0x7a10aaee),
--     --     viewRect = cc.rect(0, 0, 520 , 514),
--     --     direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
--     -- }:addTo(self):pos(display.left + 60,display.bottom + 200)


-- -- display.newColorLayer(UIKit:hex2c4b(0x88111fff))


    -- local listview = UIListView.new{
    --     bgColor = UIKit:hex2c4b(0x7a10aaee),
    --     viewRect = cc.rect(display.left + 60,display.bottom + 200, 520 , 514),
    --     direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    -- }:addTo(self)
    -- local pv = UIPageView.new {
    --     viewRect = cc.rect(0, 0 , 200, 600),
    --     row = 1,
    --     padding = {left = 0, right = 0, top = 10, bottom = 0},
    --     nBounce = true,
    --     continuous_touch = true
    -- }
    -- local item = pv:newItem()
    -- local content_node = display.newColorLayer(UIKit:hex2c4b(0x7a0aa000))
    -- content_node:setTouchSwallowEnabled(false)
    -- -- WidgetUIBackGround.new({width = 568,height = 152},WidgetUIBackGround.STYLE_TYPE.STYLE_2):addTo(content_node)
    -- content_node:setContentSize(cc.size(200, 600))
    -- item:addChild(content_node)
    -- pv:addItem(item)
    -- local item = pv:newItem()
    -- local content_node = display.newColorLayer(UIKit:hex2c4b(0x889aafff))
    -- content_node:setTouchSwallowEnabled(false)
    -- -- WidgetUIBackGround.new({width = 568,height = 152},WidgetUIBackGround.STYLE_TYPE.STYLE_2):addTo(content_node)
    -- content_node:setContentSize(cc.size(200, 600))
    -- item:addChild(content_node)
    -- pv:addItem(item)
    -- pv:reload()
    -- pv:setTouchSwallowEnabled(false)
    -- local item = listview:newItem()
    -- item:setItemSize(520,600)
    -- item:addContent(UIListView.new{
    --     bgColor = UIKit:hex2c4b(0x889aafff),
    --     viewRect = cc.rect(0,0, 600 , 600),
    --     direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    -- })
    -- listview:addItem(item)
    -- listview:reload()

    -- local pv = UIPageView.new {
    --     viewRect = cc.rect(100, 0 , 200, 600),
    --     row = 1,
    --     padding = {left = 0, right = 0, top = 10, bottom = 0},
    --     nBounce = true,
    --     continuous_touch = true
    -- }:addTo(all_node)

    -- local item = pv:newItem()
    -- local content_node = display.newColorLayer(UIKit:hex2c4b(0x7a0aa000))
    -- content_node:setTouchSwallowEnabled(false)
    -- WidgetUIBackGround.new({width = 568,height = 152},WidgetUIBackGround.STYLE_TYPE.STYLE_2):addTo(content_node)
    -- content_node:setContentSize(cc.size(200, 600))
    -- item:addChild(content_node)
    -- pv:addItem(item)
    -- local item = pv:newItem()
    -- local content_node = display.newColorLayer(UIKit:hex2c4b(0x889aafff))
    -- content_node:setTouchSwallowEnabled(false)
    -- WidgetUIBackGround.new({width = 568,height = 152},WidgetUIBackGround.STYLE_TYPE.STYLE_2):addTo(content_node)
    -- content_node:setContentSize(cc.size(200, 600))
    -- item:addChild(content_node)
    -- pv:addItem(item)
    -- pv:reload()
    -- pv:setTouchSwallowEnabled(false)

    -- local item = listview:newItem()
    -- item:setItemSize(520,600)
    -- item:addContent(all_node)
    -- listview:addItem(item)
    -- listview:reload()

end

function LogoScene:beginAnimate()
    local action = cc.Spawn:create({cc.ScaleTo:create(checknumber(2),1.5),cca.fadeTo(1.5,255/2)})
    self.sprite:runAction(action)
    local sequence = transition.sequence({
        cc.FadeOut:create(1),
        cc.CallFunc:create(function()
            self:performWithDelay(function()
                self.sprite:removeFromParent(true)
                app:enterScene("MainScene")
            end, 0.5)
        end),
    })
    self.layer:runAction(sequence)
end
--预先加载登录界面使用的大图
function LogoScene:loadSplashResources()
    --加载splash界面使用的图片
    display.addImageAsync("splash_logo_515x92.png",function()
        display.addImageAsync("splash_beta_bg_3987x1136.jpg",function()end)
    end)
end



function LogoScene:onExit()
    cc.Director:getInstance():getTextureCache():removeTextureForKey("batcat_logo_368x507.png")
end

return LogoScene
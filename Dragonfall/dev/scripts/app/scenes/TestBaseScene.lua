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
    ext.registereForRemoteNotifications()
    self:createEditBox()
    self:createTestButton()
    self:createLocalPushTest()
    self:createMailTest()
    self:createCopyText()
    self:IapTest()
    self:MusicTest()
    app:createTitle(self, "Test Base")
    app:createNextButton(self)
end

function TestBaseScene:createEditBox()
    local onEdit = function(event)
        dump(event,"--event--")
    end
	local editbox = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "input_box.png",
        size = cc.size(417,51),
        listener = onEdit,
    })
    editbox:setPlaceHolder(string.format("最多可输入%d字符",140))
    editbox:setMaxLength(140)
    -- edit box 和 textview还未实现
    local fontArg = "DroidSansFallback"
    if device.platform == 'android' then
        fontArg = app:getFontFilePath()
    end
    editbox:setFont(fontArg,22)
    editbox:setFontColor(cc.c3b(0,0,0))
    editbox:setPlaceholderFontColor(cc.c3b(204,196,158))
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    editbox:align(display.CENTER,display.cx, display.top - 70):addTo(self)
    -- editbox:setEnabled(false)
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
            self:LogDebug()
        end)
        :align(display.LEFT_CENTER, display.left + 10, display.top - 150)
        :addTo(self)
end

function TestBaseScene:LogDebug()
    print("-------------------------------------SearchPaths")
    dump(cc.FileUtils:getInstance():getSearchPaths(),"SearchPaths--->")
    print("-------------------------------------WritablePath")
    print(device.writablePath)    
    print("-------------------------------------now")
    print(ext.now()) 
    print("-------------------------------------getBatteryLevel")
    print(ext.getBatteryLevel())
    print("-------------------------------------getInternetConnectionStatus")
    print(ext.getInternetConnectionStatus())
    print("-------------------------------------disableIdleTimer")
    print(ext.disableIdleTimer(true))
    print("-------------------------------------closeKeyboard")
    print(ext.closeKeyboard())
    print("-------------------------------------getOSVersion")
    print(ext.getOSVersion())
    print("-------------------------------------getDeviceModel")
    print(ext.getDeviceModel())
    print("-------------------------------------getAppVersion")
    print(ext.getAppVersion())
    print("-------------------------------------getAppBuildVersion")
    print(ext.getAppBuildVersion())
    print("-------------------------------------getDeviceToken")
    print(ext.getDeviceToken())
    print("-------------------------------------getOpenUDID")
    print(ext.getOpenUDID())
    print("-------------------------------------getDeviceLanguage")
    print(ext.getDeviceLanguage())
    print("-------------------------------------isAppAdHoc")
    print(ext.isAppAdHoc())

    -- TODO:
    -- tolua_function(tolua_S, "createDirectory", tolua_ext_createDirectory);
    -- tolua_function(tolua_S, "removeDirectory", tolua_ext_removeDirectory);
    -- tolua_function(tolua_S, "isDirectoryExist", tolua_ext_isDirectoryExist);
    -- tolua_function(tolua_S, "crc32", tolua_ext_crc32);

    -- tolua_function(tolua_S, "restart", tolua_ext_restart);
    -- tolua_function(tolua_S, "__logFile", tolua_ext_log_file);
end

function TestBaseScene:createLocalPushTest()
    cc.ui.UIPushButton.new(TestBaseScene.PUSH_BUTTON_IMAGES, {scale9 = true})
        :setButtonSize(240, 60)
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "Local Push",
            size = 18
        }))
        :onButtonClicked(function(event)
            ext.localpush.cancelAll()
            ext.localpush.switchNotification("test",true)
            ext.localpush.addNotification("test", ext.now()/1000 + 60,"test","test")
        end)
        :align(display.RIGHT_CENTER, display.right - 10, display.top - 150)
        :addTo(self)
end

function TestBaseScene:createMailTest()
    cc.ui.UIPushButton.new(TestBaseScene.PUSH_BUTTON_IMAGES, {scale9 = true})
        :setButtonSize(240, 60)
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "Send Mail",
            size = 18
        }))
        :onButtonClicked(function(event)
            local canSendMail = ext.sysmail.sendMail("dannyjiajia@gmail.com","mail subject","mail body",function()end)
            print("canSendMail--->",canSendMail)
        end)
        :align(display.LEFT_CENTER, display.left + 10, display.top - 220)
        :addTo(self)
end

function TestBaseScene:createCopyText()
    cc.ui.UIPushButton.new(TestBaseScene.PUSH_BUTTON_IMAGES, {scale9 = true})
        :setButtonSize(240, 60)
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "Copy Action",
            size = 18
        }))
        :onButtonClicked(function(event)
            local str = "Dragonfall_" .. os.time()
            print("Copy:",str)
            ext.copyText(str)
        end)
        :align(display.RIGHT_CENTER, display.right - 10, display.top - 220)
        :addTo(self)
end

function TestBaseScene:IapTest()
    cc.ui.UIPushButton.new(TestBaseScene.PUSH_BUTTON_IMAGES, {scale9 = true})
        :setButtonSize(240, 60)
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = "Iap Test",
            size = 18
        }))
        :onButtonClicked(function(event)
            device.showActivityIndicator()
            app:getStore().purchaseWithProductId("com.dragonfall.2500dragoncoins",1)
        end)
        :align(display.LEFT_CENTER, display.left + 10, display.top - 290)
        :addTo(self)
end

function TestBaseScene:MusicTest()
    app:getCommonButton("Play Music"):onButtonClicked(function(event)
        audio.playMusic("audios/sfx_ballista_attack.mp3",false)
    end):align(display.RIGHT_CENTER, display.right - 10, display.top - 290)
        :addTo(self)
end


return TestBaseScene
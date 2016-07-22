local errorMessages = {}
local MAX_ERRORS = 10
local SEND_TIME = 120

if cc.Application:getInstance():getTargetPlatform() == 10 then -- winrt platform
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        if #errorMessages > 0 then
            GameUtils:UploadErrors(table.concat(errorMessages, string.format("\n%s\n", string.rep("-", 30))))
            errorMessages = {}
        end
    end, SEND_TIME, false)
end

function __G__TRACKBACK__(errorMessage)
    if CONFIG_LOG_DEBUG_FILE then
        print("----------------------------------------")
        print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
        print(debug.traceback("", 2))
        print("----------------------------------------")
        if device.platform ~= 'winrt' and device.platform ~= 'android' then
            local errDesc = tostring(errorMessage) .. "\n" .. debug.traceback("", 2)
            device.showAlert("☠错误☠",errDesc,{"复制！"},function()
                ext.copyText(errDesc)
            end)
        end
    else
        if device.platform == 'winrt' then
            local errDesc = string.format("LuaTag:%s\n[%s]\n[%s]\n[%s]\n[%s] %s\n%s",
                tostring(app.client_tag or "unknown"),
                json.encode(DataManager.latestUserData),
                json.encode(DataManager.latestDeltaData),
                json.encode(DataManager.originDeltaData),
                os.date("%Y-%m-%d %H:%M:%S",math.floor(ext.now()/1000)),
                tostring(errorMessage),
                debug.traceback("", 2)
            )
            table.insert(errorMessages, errDesc)
            if #errorMessages > MAX_ERRORS then
                table.remove(errorMessages, 1)
            end
        elseif type(buglyReportLuaException) == 'function' then
            local version = app.client_tag or "unknown"
            buglyPutUserData("LuaTag", version) -- send autoupdate version
            buglyReportLuaException(errorMessage, debug.traceback("", 2))
        end
    end
end
function _(text)
    return text
end
require("app.MyApp").new():run()

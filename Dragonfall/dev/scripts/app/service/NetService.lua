local NetService = {}
local cocos_promise = import("..utils.cocos_promise")
--lua pomelo
local json = json
-- if device.platform == 'winrt' then
    CCPomelo = import("libs.pomelo.CCPomelo")
    local not_handle = function( ... )
        return ...
    end
    json = {
        encode = not_handle,
        decode = not_handle,
    }
-- end
function NetService:init(  )
    self.m_pomelo = CCPomelo:getInstance()
    self.m_deltatime = 0
    self.m_urlcode = import("app.utils.urlcode")
end

function NetService:isConnected()
    return self.m_pomelo:isReady()
end

function NetService:isDisconnected()
    return not self:isConnected()
end

function NetService:connect(host, port, cb)
    self.m_pomelo:asyncConnect(host, port, function ( success ) 
        cb(success)
    end)
end

function NetService:disconnect( )
    if self:isDisconnected() then return end
    self.m_pomelo:cleanup() -- clean the callback in pomelo thread
    self.m_pomelo:stop()
end


function NetService:getServerTime()
    return ext.now() + self.m_deltatime
end

function NetService:setDeltatime(deltatime)
    self.m_deltatime = deltatime
end

function NetService:request(route, lmsg, cb, count)
    if self:isDisconnected() then 
        cocos_promise.defer(function()
            cb(false,{message = _("连接服务器失败,请检测你的网络环境!"),code = 0}) 
        end)
        return 
    end
    lmsg = lmsg or {}
    -- lmsg.__time__ = ext.now() + self.m_deltatime
    local count = count or 0
    local args = {route, lmsg, cb, count + 1}
    local ret = self.m_pomelo:request(route, json.encode(lmsg), function ( success, jmsg )
            if jmsg then
                jmsg = json.decode(jmsg)
                if jmsg.code == 504 then
                    if args[4] < 2 then
                        self:request(unpack(args))
                        return
                    else
                        jmsg.code = 0
                    end
                end
            else
               jmsg = nil 
            end
            cb(success, jmsg)
    end)
    if not ret then
        cocos_promise.defer(function()
            cb(false,{message = _("连接服务器失败,请检测你的网络环境!"),code = 0}) 
        end)
    end
end

function NetService:notify( route, lmsg, cb )
    if self:isDisconnected() then 
        cocos_promise.defer(function()
            cb(false,{message = _("连接服务器失败,请检测你的网络环境!"),code = 0}) 
        end)
    return end
    lmsg = lmsg or {}
    -- lmsg.__time__ = ext.now() + self.m_deltatime
    self.m_pomelo:notify(route, json.encode(lmsg), function ( success )
        cb(success)
    end)
end

function NetService:addListener( event, cb )
    self.m_pomelo:addListener(event, function ( success, jmsg )
        cb(success, jmsg and json.decode(jmsg) or nil)
    end)
end

function NetService:removeListener( event )
    self.m_pomelo:removeListener(event)
end

function NetService:get(url, args, cb, progressCb)
    local urlString = url
    if param then
        urlString = urlString .. "?" .. self.m_urlcode.encodetable(args)
    end
    print("NetService:get---->",url)
    local request = network.createHTTPRequest(function(event)
        local request = event.request
        local eventName = event.name

        if eventName == "completed" then
            cb(true, request:getResponseStatusCode(), request:getResponseData(),request)
        elseif eventName == "cancelled" then

        elseif eventName == "failed" then
            cb(false, request:getErrorCode(), request:getErrorMessage(),request)
        elseif eventName == "inprogress" or eventName == "progress" then
            local totalLength = event.total
            local currentLength = event.dltotal
            if progressCb then progressCb(totalLength, currentLength) end
        end
    end, urlString)

    request:setTimeout(180) -- 3 min
    request:start()

    return request
end

function NetService:cancelGet(request)
    request:cancel()
end

function NetService:formatTimeAsTimeAgoStyleByServerTime( time )
    time =  math.floor(math.abs(self:getServerTime() - time) / 1000)
    return GameUtils:formatTimeAsTimeAgoStyle(time)
end

return NetService


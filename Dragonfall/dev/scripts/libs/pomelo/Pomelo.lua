-- 需要有一个消息pool 定时取消息处理,否则容易卡UI
-- 再封装一层connector, 切换使用tcp, udp websocket
local scheduler = require("framework.scheduler")
local Protobuf = require("libs.pomelo.Protobuf")
local Protocol = require("libs.pomelo.Protocol")
local Package = require("libs.pomelo.Package")
local Message = require("libs.pomelo.Message")
local Emitter = require("libs.pomelo.Emitter")

local RES_OK = 200
local RES_FAIL = 500
local RES_OLD_CLIENT = 501

local LUA_CLIENT_TYPE = 'lua-client'
local LUA_CLIENT_VERSION = '0.0.1'

-- 继承Emitter
local Pomelo = class("Pomelo",function()
    return Emitter.new()
end)

function Pomelo:ctor()
    self.socket = nil
    self.reqId = 1
    --Map from request id to route
    self.routeMap = {}

    self.heartbeatInterval = 0
    self.heartbeatTimeout = 0
    self.heartbeatId = nil
    self.heartbeatTimeoutId = nil
    
    self.handshakeBuffer = {
        sys = {
            type = LUA_CLIENT_TYPE,
            version = LUA_CLIENT_VERSION,
        }
    }

    self.handlers = {}
    self.handlers[Package.TYPE_HANDSHAKE] = handler(self,self._handshake)
    self.handlers[Package.TYPE_HEARTBEAT] = handler(self,self.heartbeat)
    self.handlers[Package.TYPE_DATA] = handler(self,self._onData)
    self.handlers[Package.TYPE_KICK] = handler(self,self._onKick)

    self._messagePool = {}
end

function Pomelo:init(params, cb)
    printf("Pomelo:init()")
    self.params = params

    local host = params.host
    local port = params.port

    self.connectType = connectType
    self.initCallback = cb

    dhcrypt.createdh()
    self.handshakeBuffer.sys.clientKey = dhcrypt.base64encode(dhcrypt.getpublickey())
    self.secret = nil
    self:_initWebSocket(host, port)
end

function Pomelo:request(route, msg, cb)
    if not route then
        return false
    end

    if not self:_isReady() then
        printError("Pomelo:request() - socket not ready")
        return false
    end

    self.reqId = self.reqId + 1
    self:_sendMessage(self.reqId, route, msg)
    self._callbacks[self.reqId] = cb
    self.routeMap[self.reqId] = route
    return true
end

function Pomelo:disconnect()
    printf("Pomelo:disconnect()")

    if self:_isReady() then
        self:_unregisterHandler()
        self.socket:close()
        self.socket = nil
    end

    if self.heartbeatId then
        self:_clearTimeout(self.heartbeatId)
        self.heartbeatId = nil
    end

    if self.heartbeatTimeoutId then
        self:_clearTimeout(self.heartbeatTimeoutId)
        self.heartbeatTimeoutId = nil
    end

    self:removeAllListener()
    self.data = nil
end

-- 用于外部文件缓存dict/protos, 减少数据流量
function Pomelo:getData()
    return self.data
end

function Pomelo.setData(data)
    self.data = data
end


function Pomelo:_initWebSocket(host, port)
    local url = 'ws://' .. host
    if port then
        url = url .. ':' .. port
    end

    self.socket = cc.WebSocket:create(url)
    self.socket.send = self.socket.sendString
    self:_registerHandler()
end

function Pomelo:_registerHandler( )
    local onopen = function(event)
        local obj = Package.encode(Package.TYPE_HANDSHAKE, Protocol.strencode(json.encode(self.handshakeBuffer)))
        self:_send(obj)
    end

    local onmessage = function(message)
        self:_processPackage(Package.decode(message))
    end

    local onerror = function(event)
        printf('onerror')
        self:emit('disconnect', event)
        self:disconnect()
        if self.initCallback then
            self.initCallback(false)
            self.initCallback = nil
        end
    end

    local onclose = function(event)
        printf('onclose')
        self:emit('disconnect', event)
        self:disconnect()
        if self.initCallback then
            self.initCallback(false)
            self.initCallback = nil
        end
    end

    self.socket:registerScriptHandler(onopen, cc.WEBSOCKET_OPEN)
    self.socket:registerScriptHandler(onmessage,cc.WEBSOCKET_MESSAGE)
    self.socket:registerScriptHandler(onclose,cc.WEBSOCKET_CLOSE)
    self.socket:registerScriptHandler(onerror,cc.WEBSOCKET_ERROR)
end

function Pomelo:_unregisterHandler( )
    self.socket:unregisterScriptHandler(cc.WEBSOCKET_OPEN)
    self.socket:unregisterScriptHandler(cc.WEBSOCKET_MESSAGE)
    self.socket:unregisterScriptHandler(cc.WEBSOCKET_CLOSE)
    self.socket:unregisterScriptHandler(cc.WEBSOCKET_ERROR)
end

function Pomelo:_processPackage(msg)
    if not msg then return end
    if #msg > 0 then
        for i, msg_ in ipairs(msg) do
            self.handlers[msg_.type](msg_.body)
        end
    else
        self.handlers[msg.type](msg.body)
    end
end


function Pomelo:_processMessage(msg)
    --    printf("Pomelo:_processMessage()")
    --    printf("msg.id=%s,msg.route=%s,msg.body=%s",msg.id,msg.route,msg.body)
    --    printf("json.encode(msg.body)=%s",json.encode(msg.body))
    if msg.id==0 then
        self:emit(msg.route, msg.body)
    end

    --if have a id then find the callback function with the request
    local cb = self._callbacks[msg.id]
    --    printf("msg.id=%s,type(cb)=%s",msg.id,type(cb))
    self._callbacks[msg.id] = nil
    if type(cb) ~= 'function' then
        return
    end

    --    --printf("type(msg.body)=%s",type(msg.body))
    cb(msg.body)
end

function Pomelo:_processMessageBatch(msgs)
    for i=1,#msgs do
        self:_processMessage(msgs[i])
    end
end

function Pomelo:_isReady()
    if not self.socket then return false end
    return self.socket:getReadyState() == cc.WEBSOCKET_STATE_OPEN
end

-- pomelo级别连接成功而不是仅仅websocket连接成功
function Pomelo:_isConnected()
    return self:_isReady() and self.data ~= nil
end

function Pomelo:_sendMessage(reqId,route,msg)
    local _type = Message.TYPE_REQUEST
    if reqId == 0 then
        _type = Message.TYPE_NOTIFY
    end

    msg = Protocol.strencode(json.encode(msg))

    local compressRoute = 0
    if self.data.dict and self.data.dict[route] then
        route = self.data.dict[route]
        compressRoute = 1
    end

    msg = Message.encode(reqId,_type,compressRoute,route,msg)
    if self.secret then
        msg = Protocol.strencode(dhcrypt.rc4(self.secret, Protocol.strdecode(msg)))
    end
    local packet = Package.encode(Package.TYPE_DATA, msg)
    self:_send(packet)
end

function Pomelo:_send(packet)
    if self:_isReady() then

        -- local arr, len = {}, #packet
        -- for i = 1, len do
        --     arr[i] = string.char(packet[i])
        -- end
        -- local str = table.concat(arr)
        local str = Protocol.strdecode(packet)

        self.socket:send(str)
    end
end

function Pomelo:heartbeat(data)
    --    printf("Pomelo:heartbeat(data)")
    if self.heartbeatInterval == 0 then
        -- no heartbeat
        return
    end

    if self.heartbeatId ~= nil then
        -- already in a heartbeat interval
        return
    end

    self.heartbeatId = self:_setTimeout(
        function()
            printf('heartbeat')
            local obj = Package.encode(Package.TYPE_HEARTBEAT)
            self:_send(obj)
            self:_clearTimeout(self.heartbeatId)
            self.heartbeatId = nil
        end, self.heartbeatInterval)
    
    if self.heartbeatTimeoutId ~= nil then
        self:_clearTimeout(self.heartbeatTimeoutId)
    end
    self.heartbeatTimeoutId = self:_setTimeout(
        function ()
            printf('heartbeat timeout')
            self:emit('disconnect', event)
            self:disconnect()
        end, self.heartbeatTimeout)
end

function Pomelo:_handshake(data)
    -- printf("Pomelo:_handshake Protocol.strdecode(data)=%s",#data, Protocol.strdecode(data))
    -- dump(Protocol.strdecode(data), #data)

    data = json.decode(Protocol.strdecode(data))

    if data.code == RES_OLD_CLIENT then
        self:emit('error','client version not fullfill')
        return
    end

    if data.code ~= RES_OK then
        self:emit('error','_handshake fail')
        return
    end

    self:_handshakeInit(data)
    if data.sys.serverKey then
        self.secret = dhcrypt.base64encode(dhcrypt.computesecret(dhcrypt.base64decode(data.sys.serverKey)))
        local rc4 = dhcrypt.base64encode(dhcrypt.rc4(self.secret, data.sys.challenge))
        local obj = Package.encode(Package.TYPE_HANDSHAKE_ACK, Protocol.strencode(json.encode({challenge = rc4})));
        self:_send(obj)
    else
        self.secret = nil
        local obj = Package.encode(Package.TYPE_HANDSHAKE_ACK)
        self:_send(obj)
    end

    if self.initCallback then
        self:initCallback(self.socket)
        self.initCallback = nil
    end
end


function Pomelo:_onData(data)
    if self.secret then
        data = Protocol.strencode(dhcrypt.rc4(self.secret, Protocol.strdecode(data)))
    end

    local msg = Message.decode(data)
    if msg.id > 0 then
        msg.route = self.routeMap[msg.id]
        self.routeMap[msg.id] = nil
        if not msg.route then
            return
        end
    end
    if not self.data then
        return
    end
    msg.body = self:_deCompose(msg)
    self:_processMessage(msg)
end

function Pomelo:_onKick(data)
    local msg = json.decode(Protocol.strdecode(data))
    self:emit('onKick', msg)
end

-- msg 为packect.decode后的, body需要message.decode , body可以为pbc编码, msgpack等
function Pomelo:_deCompose(msg)
    local protos = {}
    if self.data.protos then
        protos = self.data.protos.server
    end
    local abbrs = self.data.abbrs
    local route = msg.route

    --Decompose route from dict
    if msg.compressRoute ~= 0 then
        if not abbrs or not abbrs[route] then
            return {}
        end
        msg.route = abbrs[route]
        route = msg.route
    end

    return json.decode(Protocol.strdecode(msg.body))
end

function Pomelo:_handshakeInit(data)
    --    printf("Pomelo:_handshakeInit(data=%s)",json.encode(data))
    if data.sys and data.sys.heartbeat then
        self.heartbeatInterval = data.sys.heartbeat         -- heartbeat interval
        self.heartbeatTimeout = self.heartbeatInterval * 2  -- max heartbeat timeout
    end

    self:_initData(data)
end

--Initilize data used in pomelo client
function Pomelo:_initData(data)
    if not data or not data.sys then
        return
    end

    self.data = self.data or {}

    local dict = data.sys.dict
    --Init compress dict
    if data.sys.useDict and dict then
        self.data.dict = dict
        self.data.abbrs = {}
        for k,v in pairs(dict) do
            self.data.abbrs[dict[k]] = k
        end
    end

    self.data.dictVersion = data.sys.dictVersion
end

function Pomelo:_setTimeout(fn,delay)
    return scheduler.performWithDelayGlobal(fn,delay)
end

function Pomelo:_clearTimeout(fn)
    if fn and fn ~= 0 then
        scheduler.unscheduleGlobal(fn)
    end
end

return Pomelo



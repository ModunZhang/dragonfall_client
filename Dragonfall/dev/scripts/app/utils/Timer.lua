local Timer = class("Timer")
local NetManager = NetManager
function Timer:ctor()
end
function Timer:GetServerTime()
    return NetManager:getServerTime() / 1000.0
end

return Timer



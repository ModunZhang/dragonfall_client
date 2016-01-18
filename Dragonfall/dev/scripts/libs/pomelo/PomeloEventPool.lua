--[[ 
	PomeloEventPool
	为Lua版本pomelo提供的一个事件池,用于解决ui被网络事件卡死的bug v0.01
--]] 
import('app.utils.Minheap')
local scheduler = require("framework.scheduler")
local PomeloEventPool = class("PomeloEventPool")

function PomeloEventPool:ctor()
	self.message_queue = Minheap.new(function(a,b)
        return a.time < b.time
    end)
end

function PomeloEventPool:run()
	if not self.update_id then
		self.update_id = scheduler.scheduleUpdateGlobal(handler(self,self._update))
	end
end

function PomeloEventPool:isRunning()
	return self.update_id ~= nil
end

function PomeloEventPool:_update(dt)
	 if not self.message_queue:empty() then
        local message = self.message_queue:pop()
        local callbacks,args = message.callbacks,message.args
        if callbacks then
	        for i=1,#callbacks do
        		-- we want to call lua function in protect model
	            pcall(callbacks[i], args)
	        end
	    end
    end
end

function PomeloEventPool:clear()
	if self.message_queue then self.message_queue:clear() end
end

function PomeloEventPool:add( msg )
	if type(msg) ~= 'table' or not msg.args or not msg.callbacks then return end
	if self.message_queue then
		msg.time = os.time()
		self.message_queue:push(msg)
	end
end

function PomeloEventPool:stop()
	if self.update_id then
		scheduler.unscheduleGlobal(self.update_id)
		self.update_id = nil
	end
	self:clear()
end

return PomeloEventPool
local Observer = class("Observer")


function Observer.extend(target, ...)
	local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, Observer)
    Observer.ctor(target, ...)
    return target
end
function Observer:ctor(...)
	self.observer = {}
end
function Observer:AddObserver(observer)
    if type(observer) == "userdata"
    and tolua.isnull(observer) then
        return observer
    end
	for i,v in ipairs(self.observer) do
		if v == observer then
			return v
		end
	end
	table.insert(self.observer, observer)
	return observer
end
function Observer:RemoveAllObserver()
	self.observer = {}
end
function Observer:RemoveObserver(observer)
	for i,v in ipairs(self.observer) do
		if v == observer then
			return table.remove(self.observer, i)
		end
	end
end
function Observer:NotifyObservers(func)
    local observer = {}
    for _,v in ipairs(self.observer) do
        if type(v) ~= "userdata" then
            table.insert(observer, v)
        else
            if not tolua.isnull(observer) then
                table.insert(observer, v)
            end
        end
    end
    self.observer = observer
    for _,v in ipairs(observer) do
        if func(v) then return end
    end
end


return Observer

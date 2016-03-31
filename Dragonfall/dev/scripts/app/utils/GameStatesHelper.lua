local GameStatesHelper = class("GameStatesHelper")

function GameStatesHelper:ctor()
	self.__functions__ = {}
end

function GameStatesHelper:getInstance()
	if not GameStatesHelper._instance_ then
		GameStatesHelper._instance_ = GameStatesHelper:new()
	end
	return GameStatesHelper._instance_
end
-- 注意:每次重新登陆成功后.只会执行一个添加的函数,并不会执行所有添加的函数!
-- scheduleFunction(function,args...)
function GameStatesHelper:scheduleFunction(...)
	local args = {...}
	local func = table.remove(args, 1)
	if type(func) ~= "function" then return end
	local args = args
	if device.platform ~= 'android' then
		pcall(func,unpack(args or {}))
	else
		table.insert(self.__functions__,{f = func,args = args})
	end

end

function GameStatesHelper:popExecute()
	if device.platform ~= 'android' or #self.__functions__ == 0 then return end
	local data = table.remove(self.__functions__,1)
	pcall(data.f,unpack(data.args or {}))
end

return GameStatesHelper
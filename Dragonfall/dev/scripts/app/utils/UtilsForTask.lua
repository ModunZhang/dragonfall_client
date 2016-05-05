UtilsForTask = {}
local Enum = import(".Enum")
local Localize = import(".Localize")
local NotifyItem = import(".NotifyItem")
local RecommendedMission = import("..entity.RecommendedMission")

local default = {}
for i,v in ipairs(RecommendedMission) do
    default[i] = false
end


local CATEGORY = Enum("BUILD", "DRAGON", "TECHNOLOGY", "SOLDIER", "EXPLORE")
UtilsForTask.TASK_CATEGORY = CATEGORY
local category_map = {
    [CATEGORY.BUILD] = {
        "cityBuild"
    },
    [CATEGORY.DRAGON] = {
        "dragonLevel",
        "dragonStar",
        "dragonSkill",
    },
    [CATEGORY.TECHNOLOGY] = {
        "productionTech",
        "militaryTech",
        "soldierStar",
    },
    [CATEGORY.SOLDIER] = {
        "soldierCount",
    },
    [CATEGORY.EXPLORE] = {
        "pveCount",
        "attackWin",
        "strikeWin",
        "playerKill",
        "playerPower",
    }
}
local category_localize = {
    [CATEGORY.BUILD] = _("城市建设"),
    [CATEGORY.DRAGON] = _("培养巨龙"),
    [CATEGORY.TECHNOLOGY] = _("研发科技"),
    [CATEGORY.SOLDIER] = _("招募部队"),
    [CATEGORY.EXPLORE] = _("冒险与征服")
}
local resource_map = {
    "gem",
    "exp",
    "coin",
    "food",
    "wood" ,
    "iron" ,
    "stone",
}


local rewards_icon_map = {
    gem = "gem_icon_62x61.png",
    exp = "upgrade_experience_icon.png",
    coin = "res_coin_81x68.png",
    food = "res_food_91x74.png",
    wood = "res_wood_82x73.png",
    iron = "res_iron_91x63.png",
    stone = "res_stone_88x82.png",
}


-- resource
local resource_meta = {}
resource_meta.__index = resource_meta
function resource_meta:Desc()
    return Localize.fight_reward[self.name]
end
function resource_meta:CountDesc()
    return GameUtils:formatNumber(self.count)
end
function resource_meta:Icon()
    return rewards_icon_map[self.name]
end
-------

local GrowUpTasks = GameDatas.GrowUpTasks
local function get_rewards(config)
    local rewards = {}
    for _,v in ipairs(resource_map) do
        if config[v] > 0 then
            table.insert(rewards, setmetatable({type = "resources", name = v, count = config[v]}, resource_meta))
        end
    end
    return NotifyItem.new(unpack(rewards))
end
-- cityBuild
local cityBuild_meta = {}
cityBuild_meta.__index = cityBuild_meta
function cityBuild_meta:Title()
    local config = self:Config()
    if config.level == 1 then
        if GameDatas.HouseLevelUp[config.name] then
            return string.format(_("建造一个%s"), Localize.building_name[config.name])
        else
            return string.format(_("解锁建筑%s"), Localize.building_name[config.name]) 
        end
    end
    return string.format(_("将%s升级到等级%d"), Localize.building_name[config.name], config.level)
end
function cityBuild_meta:Desc()
    return Localize.building_description[self:Config().name]
end
function cityBuild_meta:GetRewards()
    return get_rewards(self:Config())
end
function cityBuild_meta:Config()
    return GrowUpTasks[self:TaskType()][self.id]
end
function cityBuild_meta:TaskType()
    return "cityBuild"
end
function cityBuild_meta:IsBuild()
    local config = self:Config()
    return config.level == 1 and GameDatas.HouseLevelUp[config.name]
end
function cityBuild_meta:IsUnlock()
    local config = self:Config()
    return config.level == 1 and not GameDatas.HouseLevelUp[config.name]
end
function cityBuild_meta:IsUpgrade()
    return self:Config().level > 1
end

----------------------

local dragonLevel_meta = {}
dragonLevel_meta.__index = dragonLevel_meta
function dragonLevel_meta:Title()
    local config = self:Config()
    return string.format(_("将%s升级到等级%d"), Localize.dragon[config.type], config.level)
end
function dragonLevel_meta:Desc()
    return Localize.dragon_buffer[self:Config().type]
end
function dragonLevel_meta:GetRewards()
    return get_rewards(self:Config())
end
function dragonLevel_meta:Config()
    return GrowUpTasks[self:TaskType()][self.id]
end
function dragonLevel_meta:TaskType()
    return "dragonLevel"
end
----------------------


-- 龙星级
local dragonStar_meta = {}
dragonStar_meta.__index = dragonStar_meta
function dragonStar_meta:Title()
    local config = self:Config()
    return string.format(_("将%s提升到星级%d"), Localize.dragon[config.type], config.star)
end
function dragonStar_meta:Desc()
    return Localize.dragon_buffer[self:Config().type]
end
function dragonStar_meta:GetRewards()
    return get_rewards(self:Config())
end
function dragonStar_meta:Config()
    return GrowUpTasks[self:TaskType()][self.id]
end
function dragonStar_meta:TaskType()
    return "dragonStar"
end
----------------------

-- 龙技能
local dragonSkill_meta = {}
dragonSkill_meta.__index = dragonSkill_meta
function dragonSkill_meta:Title()
    local config = self:Config()
    return string.format(_("将%s技能%s提升到等级%d"), Localize.dragon[config.type], Localize.dragon_skill[config.name], config.level)
end
function dragonSkill_meta:Desc()
    return Localize.dragon_skill_effection[self:Config().name]
end
function dragonSkill_meta:GetRewards()
    return get_rewards(self:Config())
end
function dragonSkill_meta:Config()
    return GrowUpTasks[self:TaskType()][self.id]
end
function dragonSkill_meta:TaskType()
    return "dragonSkill"
end
----------------------


-- 生产科技
local productionTech_meta = {}
productionTech_meta.__index = productionTech_meta
function productionTech_meta:Title()
    local config = self:Config()
    return string.format(_("将%s科技研发到等级%d"), Localize.productiontechnology_name[config.name], config.level)
end
function productionTech_meta:Desc()
    return Localize.productiontechnology_buffer[self:Config().name]
end
function productionTech_meta:GetRewards()
    return get_rewards(self:Config())
end
function productionTech_meta:Config()
    return GrowUpTasks[self:TaskType()][self.id]
end
function productionTech_meta:TaskType()
    return "productionTech"
end
----------------------

-- 生产科技
local militaryTech_meta = {}
militaryTech_meta.__index = militaryTech_meta
function militaryTech_meta:Title()
    local config = self:Config()
    return string.format(_("将%s科技研发到等级%d"), Localize.getMilitaryTechnologyName(config.name), config.level)
end
function militaryTech_meta:Desc()
    return Localize.getMilitaryTechnologyName(self:Config().name)
end
function militaryTech_meta:GetRewards()
    return get_rewards(self:Config())
end
function militaryTech_meta:Config()
    return GrowUpTasks[self:TaskType()][self.id]
end
function militaryTech_meta:TaskType()
    return "militaryTech"
end
----------------------

-- 士兵星级
local soldierStar_meta = {}
soldierStar_meta.__index = soldierStar_meta
function soldierStar_meta:Title()
    local config = self:Config()
    return string.format(_("将%s提升到星级%d"), Localize.soldier_name[config.name], config.star)
end
function soldierStar_meta:Desc()
    return Localize.soldier_name[self:Config().name]
end
function soldierStar_meta:GetRewards()
    return get_rewards(self:Config())
end
function soldierStar_meta:Config()
    return GrowUpTasks[self:TaskType()][self.id]
end
function soldierStar_meta:TaskType()
    return "soldierStar"
end
----------------------


-- 士兵星级
local soldierCount_meta = {}
soldierCount_meta.__index = soldierCount_meta
function soldierCount_meta:Title()
    local leftCount = self:Config().count - UtilsForSoldier:TotalSoldiers(User)[self:Config().name]
    if leftCount <= 0 then
        local str = string.formatnumberthousands(self:Config().count)
        return string.format(_("招募%s个%s(%s/%s)"),str,Localize.soldier_name[self:Config().name],str,str)
    else
        return string.format(_("招募%s个%s(%s/%s)"), 
            string.formatnumberthousands(self:Config().count),
            Localize.soldier_name[self:Config().name],
            string.formatnumberthousands(self:Config().count - leftCount),
            string.formatnumberthousands(self:Config().count))
    end
end
function soldierCount_meta:Desc()
    return Localize.soldier_name[self:Config().name]
end
function soldierCount_meta:GetRewards()
    return get_rewards(self:Config())
end
function soldierCount_meta:Config()
    return GrowUpTasks[self:TaskType()][self.id]
end
function soldierCount_meta:TaskType()
    return "soldierCount"
end
----------------------

-- pve探索
local pveCount_meta = {}
pveCount_meta.__index = pveCount_meta
function pveCount_meta:Title()
    local leftCount = self:Config().count - User.countInfo.pveCount
    if leftCount <= 0 then
        local str = string.formatnumberthousands(self:Config().count)
        return string.format(_("探索%s次PVE(%s/%s)"),str,str,str)
    else
        return string.format(_("探索%s次PVE(%s/%s)"), 
            string.formatnumberthousands(self:Config().count),
            string.formatnumberthousands(self:Config().count - leftCount),
            string.formatnumberthousands(self:Config().count))
    end
end
function pveCount_meta:Desc()
    return string.format(_("探索次数达到%s描述"), string.formatnumberthousands(self:Config().count))
end
function pveCount_meta:GetRewards()
    return get_rewards(self:Config())
end
function pveCount_meta:Config()
    return GrowUpTasks[self:TaskType()][self.id]
end
function pveCount_meta:TaskType()
    return "pveCount"
end
----------------------

-- 攻击胜利
local attackWin_meta = {}
attackWin_meta.__index = attackWin_meta
function attackWin_meta:Title()
    return string.format(_("攻击玩家获胜%s次"), string.formatnumberthousands(self:Config().count))
end
function attackWin_meta:Desc()
    return string.format(_("攻击玩家获胜%s次描述"), string.formatnumberthousands(self:Config().count))
end
function attackWin_meta:GetRewards()
    return get_rewards(self:Config())
end
function attackWin_meta:Config()
    return GrowUpTasks[self:TaskType()][self.id]
end
function attackWin_meta:TaskType()
    return "attackWin"
end
----------------------

-- 攻击胜利
local strikeWin_meta = {}
strikeWin_meta.__index = strikeWin_meta
function strikeWin_meta:Title()
    return string.format(_("突袭玩家获胜%s次"), string.formatnumberthousands(self:Config().count))
end
function strikeWin_meta:Desc()
    return string.format(_("突袭玩家获胜%s次描述"), string.formatnumberthousands(self:Config().count))
end
function strikeWin_meta:GetRewards()
    return get_rewards(self:Config())
end
function strikeWin_meta:Config()
    return GrowUpTasks[self:TaskType()][self.id]
end
function strikeWin_meta:TaskType()
    return "strikeWin"
end
----------------------


-- 攻击胜利
local playerKill_meta = {}
playerKill_meta.__index = playerKill_meta
function playerKill_meta:Title()
    return string.format(_("击杀积分达到%s"), string.formatnumberthousands(self:Config().kill))
end
function playerKill_meta:Desc()
    return string.format(_("击杀积分达到%s描述"), string.formatnumberthousands(self:Config().kill))
end
function playerKill_meta:GetRewards()
    return get_rewards(self:Config())
end
function playerKill_meta:Config()
    return GrowUpTasks[self:TaskType()][self.id]
end
function playerKill_meta:TaskType()
    return "playerKill"
end
----------------------

-- power
local playerPower_meta = {}
playerPower_meta.__index = playerPower_meta
function playerPower_meta:Title()
    return string.format(_("power值到达%s"), string.formatnumberthousands(self:Config().power))
end
function playerPower_meta:Desc()
    return string.format(_("power值到达%s描述"), string.formatnumberthousands(self:Config().power))
end
function playerPower_meta:GetRewards()
    return get_rewards(self:Config())
end
function playerPower_meta:Config()
    return GrowUpTasks[self:TaskType()][self.id]
end
function playerPower_meta:TaskType()
    return "playerPower"
end
----------------------

local meta_map = {
    cityBuild = cityBuild_meta,
    dragonLevel = dragonLevel_meta,
    dragonStar = dragonStar_meta,
    dragonSkill = dragonSkill_meta,
    productionTech = productionTech_meta,
    militaryTech = militaryTech_meta,
    soldierStar = soldierStar_meta,
    soldierCount = soldierCount_meta,
    pveCount = pveCount_meta,
    attackWin = attackWin_meta,
    strikeWin = strikeWin_meta,
    playerKill = playerKill_meta,
    playerPower = playerPower_meta,
}

local function getKeyFunc(type)
    if type == "cityBuild"
    or type == "productionTech"
    or type == "militaryTech"
    or type == "soldierStar"
    or type == "soldierCount" then
        return function(task) return task.name end
    end

    if type == "dragonStar"
    or type == "dragonLevel" then
        return function(task) return task.type end
    end

    if type == "dragonSkill" then
        return function(task) return string.format("%s_%s",task.type,task.name) end
    end
    return function(task) return type end
end
local firstTaskMap = {}
for k,configs in pairs(GrowUpTasks) do
    local t = {}
    local keyFunc = getKeyFunc(k)
    for i = 0, #configs do
        local config = configs[i]
        local key = keyFunc(config)
        if not t[key] then
            t[key] = config.id
        end
    end
    firstTaskMap[k] = t
end

---
local category_meta = {}
category_meta.__index = category_meta
function category_meta:Title()
    return category_localize[self.category]
end
function category_meta:Desc()
    return string.format("%s (%.2f%%)", self:Title(), self.available * 100)
end
---------

function UtilsForTask:CompleteTasksByType(growUpTasks, type_)
    return growUpTasks[type_]
end
function UtilsForTask:GetFirstCompleteTasks(growUpTasks)
    local r = {}
    for category,v in ipairs(CATEGORY) do
        for _,v in ipairs(self:GetFirstCompleteTasksByCategory(growUpTasks, category)) do
            table.insert(r, v)
        end
    end
    return r
end
local type_map = {
    dragonLevel = true,
    dragonStar = true
}
local index_map = {
    pveCount = true,
    attackWin = true,
    strikeWin = true,
    playerPower = true,
    playerKill = true,
}
function UtilsForTask:GetFirstCompleteTasksByCategory(growUpTasks, category)
    local r = {}
    for _,tag in ipairs(category_map[category]) do
        local mark_map = {}
        local tasks = {}
        for i,v in ipairs(growUpTasks[tag]) do tasks[i] = v end
        table.sort(tasks, function(a, b) return a.id < b.id end)
        for _,v in ipairs(tasks) do
            local category_name = v.name
            if type_map[tag] then
                category_name = v.type
            elseif index_map[tag] then
                category_name = v.index
            end
            if not v.rewarded and not mark_map[category_name] then
                mark_map[category_name] = true
                table.insert(r, setmetatable(v, meta_map[tag]))
                if index_map[tag] then
                    break
                end
            end
        end
    end
    return r
end
function UtilsForTask:GetAvailableTasksGroup(growUpTasks)
    local r = {}
    for category,v in ipairs(CATEGORY) do
        table.insert(r, self:GetAvailableTasksByCategory(growUpTasks, category))
    end
    return r
end
function UtilsForTask:GetAvailableTasksByCategory(growUpTasks, category)
    local r = {}
    local p = 0
    if category == CATEGORY.BUILD then
        local r1,count1,total1 = self:GetAvailableTaskByTag(growUpTasks, "cityBuild")
        table.sort(r1, function(a, b)
            return a.id < b.id
        end)
        r = r1
        p = count1 / total1
    elseif category == CATEGORY.DRAGON then
        local r1,count1,total1 = self:GetAvailableTaskByTag(growUpTasks, "dragonLevel")
        local r2,count2,total2 = self:GetAvailableTaskByTag(growUpTasks, "dragonStar")
        local r3,count3,total3 = self:GetAvailableTaskByTag(growUpTasks, "dragonSkill")
        local dragons = {
            redDragon = {
                dragonLevel = {}, dragonStar = {}, dragonSkill = {}
            },
            greenDragon = {
                dragonLevel = {}, dragonStar = {}, dragonSkill = {}
            },
            blueDragon = {
                dragonLevel = {}, dragonStar = {}, dragonSkill = {}
            },
        }
        for _,v in ipairs(r1) do
            table.insert(dragons[v.type].dragonLevel, v)
        end
        for _,v in ipairs(r2) do
            table.insert(dragons[v.type].dragonStar, v)
        end
        for _,v in ipairs(r3) do
            table.insert(dragons[v.type].dragonSkill, v)
        end
        for _,v in pairs(dragons) do
            table.sort(v.dragonSkill, function(a,b)
                return a.id < b.id
            end)
        end
        for _,dragon_type in ipairs{"redDragon", "greenDragon", "blueDragon"} do
            local dragon = dragons[dragon_type]
            for _,v in ipairs(dragon.dragonLevel) do
                table.insert(r, v)
            end
            for _,v in ipairs(dragon.dragonStar) do
                table.insert(r, v)
            end
            for _,v in ipairs(dragon.dragonSkill) do
                table.insert(r, v)
            end
        end
        p = (count1 + count2 + count3) / (total1 + total2 + total3)
    elseif category == CATEGORY.TECHNOLOGY then
        local count, total = 0, 0
        for i,tag in ipairs(category_map[category]) do
            local r1,count1,total1 = self:GetAvailableTaskByTag(growUpTasks, tag)
            table.sort(r1, function(a, b)
                return a.id < b.id
            end)
            for _,v in ipairs(r1) do
                table.insert(r, v)
            end
            count = count + count1
            total = total + total1
        end
        p = count / total
    elseif category == CATEGORY.SOLDIER then
        local r1,count1,total1 = self:GetAvailableTaskByTag(growUpTasks, "soldierCount")
        table.sort(r1, function(a, b)
            return a.id < b.id
        end)
        r = r1
        p = count1 / total1
    elseif category == CATEGORY.EXPLORE then
        local count, total = 0, 0
        for i,tag in ipairs(category_map[category]) do
            local r1,count1,total1 = self:GetAvailableTaskByTag(growUpTasks, tag)
            table.sort(r1, function(a, b)
                return a.id < b.id
            end)
            for _,v in ipairs(r1) do
                table.insert(r, v)
            end
            count = count + count1
            total = total + total1
        end
        p = count / total
    end
    return setmetatable({tasks = r, available = p, category = category}, category_meta)
end
function UtilsForTask:GetAvailableTaskByTag(growUpTasks, tag)
    -- 找到每个任务类型的第一个
    local available_map = {}
    for tasKey,id in pairs(firstTaskMap[tag]) do
        available_map[tasKey] = id
    end

    -- 找到未完成的任务id
    local keyFunc = getKeyFunc(tag)
    local configs = GrowUpTasks[tag]
    for i,v in ipairs(growUpTasks[tag]) do
        local key      = keyFunc(configs[v.id])
        local nextTask = configs[v.id + 1]
        -- 还有没做完的此类型的任务
        if nextTask then
            available_map[key] = nextTask.id
        else -- 没有所有此类型的任务已经做完
            available_map[key] = nil
        end
    end

    -- 找到未完成的任务
    local r = {}
    local count = 0
    for k,id in pairs(available_map) do
        local t = configs[id]
        count = count + t.index - 1
        table.insert(r, setmetatable(t, meta_map[tag]))
    end
    return r, count, #configs + 1
end
function UtilsForTask:GetCompleteTaskCount(growUpTasks)
    local count = 0
    for _,category in pairs(growUpTasks) do
        for _,task in ipairs(category) do
            if not task.rewarded then
                count = count + 1
            end
        end
    end
    return count
end
function UtilsForTask:IsGetAnyCityBuildRewards(growUpTasks)
    for i,v in ipairs(self:CompleteTasksByType(growUpTasks, "cityBuild")) do
        if v.id >= 0 and v.rewarded then
            return true
        end
    end
end
local cityBuild = GameDatas.GrowUpTasks.cityBuild
local materialDepot_index
for i,mission in ipairs(RecommendedMission) do
    if  mission.type == "cityBuild" 
    and cityBuild[mission.id].name == "materialDepot" then
        materialDepot_index = i
        break
    end
end
function UtilsForTask:NeedTips(userData)
    for i,mission in ipairs(RecommendedMission) do
        if not self:CheckIsComplete(userData, mission) 
        and i < materialDepot_index then
            return true
        end
    end
    return false
end
function UtilsForTask:CheckIsComplete(userData, mission)
    local growUpTasks = userData.growUpTasks
    local GrowUpTasks = GameDatas.GrowUpTasks
    local tasks = growUpTasks[mission.type]
    local configs = GrowUpTasks[mission.type]
    local config = configs[mission.id]
    for i = #tasks, 1, -1 do
        local task = tasks[i]
        if task.name == config.name and task.id >= config.id then
            return true
        end
    end
    return false
end
function UtilsForTask:GetBeginnersTask(userData)
    for _,mission in ipairs(RecommendedMission) do
        if not self:CheckIsComplete(userData, mission) then
            return setmetatable({ id = mission.id }, meta_map[mission.type])
        end
    end
end


return UtilsForTask



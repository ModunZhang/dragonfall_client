local Sprite = import("..sprites.Sprite")
local CityScene = import(".CityScene")
local GameUIAllianceWatchTowerTroopDetail = import("..ui.GameUIAllianceWatchTowerTroopDetail")
local OtherCityScene = class("OtherCityScene", CityScene)
function OtherCityScene:ctor(user, city, location)
    OtherCityScene.super.ctor(self, city)
    self.user = user
    self.city = city
    self.location = location
end
function OtherCityScene:onEnter()
    OtherCityScene.super.onEnter(self)
    self.home = UIKit:newGameUI('GameUICityInfo', self.user, self.location):AddToScene(self):setTouchSwallowEnabled(false)

    if not self.location.canShowBuildingLevel then
        self:GetSceneLayer():HideLevelUpNode()
    end

    for k,v in pairs(self:GetSceneLayer().soldiers) do
        v:hide()
    end

    self.showDragon = false
    local level = Alliance_Manager:GetMyAlliance()
                    :GetAllianceBuildingInfoByName("watchTower").level
    if level >= 13 then
        self.showDragon = true
        if self.user.defenceTroop and self.user.defenceTroop ~= json.null then
            local troopDetail = clone(self.user.defenceTroop)

            -- soldiers
            for i,v in ipairs(troopDetail.soldiers) do
                v.star = UtilsForSoldier:SoldierStarByName(self.user, v.name)
            end

            -- dragon
            troopDetail.dragon = self.user.dragons[self.user.defenceTroop.dragonType]

            -- skills
            local skills = {}
            for k,v in pairs(troopDetail.dragon.skills) do
                table.insert(skills, {k, v})
            end
            table.sort(skills, function(a,b) return a[1] > b[1] end)
            local t = {}
            for i,v in ipairs(skills) do
                table.insert(t, v[2])
            end
            skills = t
            troopDetail.dragon.skills = skills

            -- equipments
            local equipments = {}
            for type,v in pairs(troopDetail.dragon.equipments) do
                if #v.name > 0 then
                    table.insert(equipments,{
                        type = type, name = v.name, star = v.star
                    })
                end
            end
            local seqs = {
                ["crown"] = 1,
                ["chest"] = 2,
                ["armguardLeft"] = 3,
                ["armguardRight"] = 4,
                ["sting"] = 5,
                ["orb"] = 6,
            }
            table.sort(equipments, function(a,b)
                return seqs[a.type] > seqs[b.type]
            end)
            troopDetail.dragon.equipments = equipments

            -- militaryTechs
            local militaryTechs = {}
            for name,v in pairs(self.user.militaryTechs) do
                if v.level > 0 then
                    table.insert(militaryTechs, {name = name, level = v.level})
                end
            end
            table.sort(militaryTechs, function(a, b) return a.name > b.name end)
            troopDetail.militaryTechs = militaryTechs


            -- militaryBuffs
            local militaryBuffs = {}
            local buff_key = {
                troopSizeBonus  = 1,
                dragonHpBonus   = 2,
                dragonExpBonus  = 3,
                marchSpeedBonus = 4,
                unitHpBonus     = 5,
                infantryAtkBonus= 6,
                archerAtkBonus  = 7,
                cavalryAtkBonus = 8,
                siegeAtkBonus   = 9,
            }
            for i,v in ipairs(self.user.itemEvents) do
                if buff_key[v.type] then
                    table.insert(militaryBuffs, v)
                end
            end
            table.sort(militaryBuffs, function(a,b)
                return buff_key[a.type] > buff_key[b.type]
            end)
            troopDetail.militaryBuffs = militaryBuffs

            self.troopDetail = troopDetail
        end
    end
    if not self.showDragon then
        for k,v in pairs(self:GetSceneLayer().buildings) do
            if v:GetEntity():GetType() == "dragonEyrie" then
                v:ReloadSpriteCaseDragonDefencedChanged(nil)
            end
        end
    end
end
function OtherCityScene:GetHomePage()
    return self.home
end
--不处理任何场景建筑事件
function OtherCityScene:OnTouchClicked(pre_x, pre_y, x, y)
    local building = self:GetSceneLayer():GetClickedObject(x, y)
    if building then
        app:lockInput(true);self:performWithDelay(function()app:lockInput()end,0.3)
        Sprite:PromiseOfFlash(unpack(self:CollectBuildings(building)))
        :next(function()
            if self.showDragon then
                local type = building:GetEntity():GetType()
                if (type == "dragonEyrie"
                or type == "wall") then
                    if self.troopDetail then
                        UIKit:newGameUI(
                            "GameUIAllianceWatchTowerTroopDetail",
                            self.troopDetail,
                            Alliance_Manager:GetMyAlliance():GetAllianceBuildingInfoByName("watchTower").level,
                            true,
                            GameUIAllianceWatchTowerTroopDetail.DATA_TYPE.MARCH,
                            true
                        ):AddToCurrentScene(true)
                    else
                        UIKit:showMessageDialog(_("主人"),_("玩家未驻防！"))
                    end
                end
            else
                UIKit:showMessageDialog(_("主人"),_("巨石阵等级大于13才可以查看驻防信息！"))
            end
        end)
    end
end

return OtherCityScene

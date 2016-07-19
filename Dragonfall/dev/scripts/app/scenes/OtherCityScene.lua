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
                    if self.user.defenceTroop and
                        self.user.defenceTroop ~= json.null then
                        local troopDetail = clone(self.user.defenceTroop)
                        for i,v in ipairs(troopDetail.soldiers) do
                            v.star = UtilsForSoldier:SoldierStarByName(self.user, v.name)
                        end
                        troopDetail.dragon = self.user.dragons[self.user.defenceTroop.dragonType]
                        UIKit:newGameUI(
                            "GameUIAllianceWatchTowerTroopDetail",
                            troopDetail,
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

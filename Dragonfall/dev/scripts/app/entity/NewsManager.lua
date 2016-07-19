--
-- Author: Kenny Dai
-- Date: 2016-04-26 10:25:37
--
local Enum = import("..utils.Enum")
local MultiObserver = import("..entity.MultiObserver")
local NewsManager = class("NewsManager", MultiObserver)
NewsManager.LISTEN_TYPE = Enum("NEWS_CHANGED","UNREAD_NEWS_CHANGED")
local function fliter_news( datas )
    local filter_data = {}
    for i,v in ipairs(datas) do
        if v.time > User.countInfo.registerTime then
            table.insert(filter_data, v)
        end
    end
    return filter_data
end
function NewsManager:ctor()
    NewsManager.super.ctor(self)
    self:GetAllNewsFromServer()
end

--从服务器获取所有新闻
function NewsManager:GetAllNewsFromServer()
    NetManager:getServerNoticesPromise():done(function (response)
        self.newsData = fliter_news(response.msg.notices)
        dump(self.newsData)
    end)
end
-- 所有新闻
function NewsManager:GetNewsData()
    return self.newsData or {} -- 如果未从服务器取到数据使其为空表
end
function NewsManager:OnNewsChanged(changeData)
    for i,change in ipairs(changeData) do
        if change.type == "add" then
            table.insert(self:GetNewsData(), change.data)
        elseif change.type == "remove" then
            for i,v in ipairs(self:GetNewsData()) do
                if v.id == change.data then
                    table.remove(self:GetNewsData(),i)
                end
            end
        end
    end
    self:NotifyListeneOnType(NewsManager.LISTEN_TYPE.NEWS_CHANGED,function(listener)
        listener:OnNewsChanged()
    end)
    self:NotifyListeneOnType(NewsManager.LISTEN_TYPE.UNREAD_NEWS_CHANGED,function(listener)
        listener:NewsUnreadChanged()
    end)
end
-- 未读新闻数
function NewsManager:GetUnreadCount()
    local unReadCount = 0
    for i,v in ipairs(self:GetNewsData()) do
        if not self:IsReadNews(v.id) then
            unReadCount = unReadCount + 1
        end
    end
    return unReadCount
end
function NewsManager:IsReadNews(news_id)
    local news = app:GetGameDefautlt():getTableForKey("NEWS_READ") or {}
    for i,v in ipairs(news) do
        if news_id == v then
            return true
        end
    end
end
function NewsManager:ReadNews(news_id)
    local news_read = app:GetGameDefautlt():getTableForKey("NEWS_READ") or {}
    table.insert(news_read, news_id)
    if #news_read > 10 then
        for i,new in ipairs(news_read) do
            local isLive = false
            for j,current in ipairs(self:GetNewsData()) do
                if new == current.id then
                    isLive = true
                    break
                end
            end
            if not isLive then
                table.remove(news_read,i)
            end
        end
    end
    app:GetGameDefautlt():setTableForKey("NEWS_READ", news_read)

    self:NotifyListeneOnType(NewsManager.LISTEN_TYPE.UNREAD_NEWS_CHANGED,function(listener)
        listener:NewsUnreadChanged()
    end)
end
return NewsManager









--升级层
local LayerLevelUp = class("LayerLevelUp", cc.load("mvc").ViewBase)

function LayerLevelUp:onCreate()
     --加载精灵帧
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames("/ui/fightUI/levelUp.plist")

    --创建升级精灵
    --背景
    self.node_ = cc.Node:create()
    self:addChild(self.node_)
    local sp = cc.Sprite:createWithSpriteFrameName("levelUp_bg.png"):setPosition(display.center)
    self.node_:addChild(sp)
    
    --title
    local title = cc.Sprite:createWithSpriteFrameName("levelUp_title.png")
    title:setPosition(sp:getAnchorPointInPoints())
    sp:addChild(title)

    --打开本地文件，好存放升级信息
    self:initLevelUpData()
end

--升级时动画
function LayerLevelUp:runAnimation()
    local function func()
        self:setVisible(false)
    end
    local delay = cc.DelayTime:create(1)
    local fade = cc.FadeOut:create(2)
    local hide = cc.CallFunc:create(func)
    --local rf = cc.RemoveSelf:create()
    self:runAction(cc.Sequence:create(delay, fade, hide))
end

--击杀人数与升级需人数
function LayerLevelUp:initLevelUpData()
    self.killCount_ = cc.UserDefault:getInstance():getIntegerForKey("killCount", 0)
    self.nextLevel_ = cc.UserDefault:getInstance():getIntegerForKey("nextLevelCount", 2)
end

--保存升级信息
function LayerLevelUp:saveLevelUpData()
    cc.UserDefault:getInstance():setIntegerForKey("killCount", self.killCount_)
    cc.UserDefault:getInstance():setIntegerForKey("nextLevelCount", self.nextLevel_)
end

--获取当前击杀多少人
function LayerLevelUp:getKillCount()
    return self.killCount_
end

--获取升级信息
function LayerLevelUp:getLevelUpData()
    return self.nextLevel_
end

--设置升级数据
function LayerLevelUp:setLevelUpData(killCount)
    self.killCount_ = killCount
    if self.killCount_ == self.nextLevel_ then
        --自定义消息
        local selfEvent = cc.EventCustom:new("LevelUp")
        self:getEventDispatcher():dispatchEvent(selfEvent)

        self.nextLevel_  = self.nextLevel_ * 2
    end
    self:saveLevelUpData()
    print("current: ", self.killCount_, "nextLevel count: ", self.nextLevel_)
end

return LayerLevelUp

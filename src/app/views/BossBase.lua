
local BossBase = class("BossBase", cc.load("mvc").ViewBase)

function BossBase:onCreate()
    --获取场景id
    self.ScenesIdx_ = 40000 + cc.GameArgs.sceneIdx   --场景id

    --获取Boss的id
    local ids = cc.GameArgs.Scenes[self.ScenesIdx_].bossIds
    self.bossIds_ =  string.split(ids, "_")

    --当前出场boss
    self.curBossIdx_ = 1  

    self.bossBgs_ = {}          --背景
    self.bossHeads_ = {}        --boss头像
    self.countDown_ = 10       --倒计时
    self.bossFlag_  = false     --boss是否出现

    self.isInBattle_ = false    --boss是否进场

    --创建boss头像
    self:createBossHead()

    --监听Boss被击杀情况
    local ev = cc.EventListenerCustom:create("Boss killed", handler(self, self.listenBossKilled))
    local disp = self:getEventDispatcher()
    disp:addEventListenerWithSceneGraphPriority(ev, self)
end

function BossBase:listenBossKilled()
    self.curBossIdx_ = self.curBossIdx_ + 1
    --如果三只boss被击杀，要回到 1
    if self.curBossIdx_ > 3 then 
        self.curBossIdx_ = 1 
    end

    self:updateBossHead()  --更新头像
    self:updateLabelPos()  --更新标签位置      
    self.label_:setVisible(true)
end


--创建boss头像
function BossBase:createBossHead()
    -- 获取table中有多少个id
    local count = #self.bossIds_ 
    --遍历创建
    for i=1, count do
        self:createBoss(self.bossIds_[i]+0, i)
    end

end

--更新boss头像
function BossBase:updateBossHead()
    self.curBossIdx_ = self.curBossIdx_ + 1
    --如果三只boss被击杀，要回到 1
    if self.curBossIdx_ > 3 then 
        self.curBossIdx_ = 1 
    end

    for k, value in ipairs(self.bossHeads_) do
        local id = self.bossIds_[k]
        if k ~= self.curBossIdx_ then
            value:setTexture("bossAvatar/bossAvatar_" .. id .. "_gray.png")
        else
            value:setTexture("bossAvatar/bossAvatar_" .. id .. ".png")
        end
   end
end

--根据位置下标创建Boss
function BossBase:createBoss(id, idx)
    --创建背景
    local bg = cc.Sprite:create("bossAvatar/bossAvatar_circle.png")
    self:addChild(bg)
    local x, y = display.cx -35, display.height - 84  -- 基准位置
    bg:setPosition(cc.p(x+idx*152, y))
    table.insert(self.bossBgs_, bg)

    --创建头像 
    local head = nil
    if idx == self.curBossIdx_ then
        head = cc.Sprite:create("bossAvatar/bossAvatar_" .. id .. ".png")
    else
        head = cc.Sprite:create("bossAvatar/bossAvatar_" .. id .. "_gray.png")
    end
    bg:addChild(head)
    head:setPosition(cc.p(bg:getAnchorPointInPoints()))
    head:setLocalZOrder(-1)   -- 让头像在背景里面
    table.insert(self.bossHeads_, head)

     --创建label显示boss出现的时间
    self.label_ = cc.Label:createWithBMFont("font/font_task.fnt", "")
    self:addChild(self.label_)
    self.label_:setScale(2)
    self.label_:setColor(cc.c3b(255, 0, 0))
    --self.label:setTextColor(cc.c4b(255,0,0))  --只支持 ttf字体
    self:updateLabelPos()
end

function BossBase:updateLabelPos()
    local x, y = self.bossBgs_[self.curBossIdx_]:getPosition()
    self.label_:setPosition(cc.p(x, y-20))
end

--倒计时
function BossBase:bossCountDown(dt)
    if self.isInBattle_ then 
        return 
    end

     --更新显示时间
    self:updateBossTime()
    
    --每调用一次 总时间减一
    self.countDown_ = self.countDown_ - 1
    
    if self.countDown_ == 0 then
        self.countDown_ = 30

        --self.bossFlag_ = true   --boss该出现了
        --自定义消息
        local selfEvent = cc.EventCustom:new("Boss Begin")
        self:getEventDispatcher():dispatchEvent(selfEvent)

        self.label_:setVisible(false)   
    end
end

function BossBase:updateBossTime()
    --更新label
    local min = math.modf(self.countDown_ / 60)
    local sec = math.fmod(self.countDown_, 60)
    local str = string.format("%02d:%02d", min, sec)
    self.label_:setString(str)
end

function BossBase:onEnter()
    --启动定时器 boss倒计时出现
    self.bossTimer_ = cc.GameUtil.startTimer(handler(self, self.bossCountDown), 1)
end

function BossBase:onExit()
    cc.GameUtil.killTimer(self.bossTimer_)
end

return BossBase

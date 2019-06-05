--战斗层
local LayerFight = class("LayerFight", cc.load("mvc").ViewBase)

function LayerFight:onCreate()
    --添加背景
    self.bg_ = cc.Sprite:create("maps/4000" .. cc.GameArgs.sceneIdx .. ".png")
    self.bg_:setPosition(display.center)
    self:addChild(self.bg_)

     --英雄
    self.Role_ = require("app.views.Role"):create(cc.GameArgs.RoleId)
    self.bg_:addChild(self.Role_)
    self.Role_:setPosition(display.center)

    --场景id
    self.ScenesIdx_ = 40000 + cc.GameArgs.sceneIdx+0

    --获取怪物们的相关信息
    self:getNpcsInfo()
    
    --创建boss层
    self.LayerBoss_ = require("app.views.BossBase"):create()
    self:addChild(self.LayerBoss_)
    
    --怒气值
    self.anger_ = 0

    --金币变化
    self.goldChange_ = 0

    --用于暂停定时器标记
    self.stopTimer_ = false

    --监听抽奖-Boss出现情况
    self:listenInfo()
    self.fac_ = 1    --奖励默认一倍

    --创建升级界面
    self:createLevelUp()
    
    --阵型相关
    self.bInFormation_ = false

    --清场状态
    self.bInBossLeft_ = false

    --清场时速度变快，导致在判断是否出场会出现一个bug
    self.leftFactor_ = true
end

--监听 创建和销毁大乐购并创建Boss 以及升级
function LayerFight:listenInfo()
    local ev = cc.EventListenerCustom:create("finished Lottery", handler(self, self.callBackOne))
    local disp = self:getEventDispatcher()
    disp:addEventListenerWithSceneGraphPriority(ev, self)

    local ev2 = cc.EventListenerCustom:create("Boss Begin", handler(self, self.callBackTwo))
    local disp2 = self:getEventDispatcher()
    disp2:addEventListenerWithSceneGraphPriority(ev2, self)

    local ev3 = cc.EventListenerCustom:create("LevelUp", handler(self, self.levelUpSet))
    local disp3 = self:getEventDispatcher()
    disp3:addEventListenerWithSceneGraphPriority(ev3, self)
end

--创建Boss
function LayerFight:callBackOne()
    self:gameResume()

     --保存抽奖因子
     self.fac_  = self.lottery_.factor_  
     
     --销毁大乐购
     self.lottery_:removeFromParent()
     
     --创建Boss
     self.LayerBoss_.isInBattle_ = true
     self.Boss_ = require("app.views.NPC")
                        :create(self.LayerBoss_.bossIds_[self.LayerBoss_.curBossIdx_]+0)
     self:addChild(self.Boss_) 
     table.insert(self.NPCS_, self.Boss_)
     self.LayerBoss_.bossFlag_ = false
end

--创建大乐透
function LayerFight:callBackTwo()
    self:gamePause()
    self.lottery_ = require("app.views.BossLottery"):create(self.LayerBoss_.curBossIdx_+0)
    self.lottery_:setLocalZOrder(5)
    self:addChild(self.lottery_)  
end

--创建升级界面
function LayerFight:createLevelUp()
    self.level_ = require("app.views.LayerLevelUp"):create()
    self:addChild(self.level_)
    self.level_:setLocalZOrder(4)
    self.level_:setVisible(false)

    --当前击杀人数
    self.killCount_ = self.level_:getKillCount()

    --获取升级所需条件
    self.nextLevel_ = self.level_:getLevelUpData()
end

--获取怪物们相关信息
function LayerFight:getNpcsInfo()
    --保存怪物
    self.NPCS_ = {}

    --保存怪物出现的概率
    self.SoliderInfo_ = {}

    --获取npc出现的概率
    self:getNpcInfo()
end

--获取随机出现的概率
function LayerFight:getNpcInfo()
    --拆分字符串获取NPC信息
    local tb1 = string.split(cc.GameArgs.Scenes[self.ScenesIdx_].soldierProbabilitys, "_")  --概率信息
    local tb2 = string.split(cc.GameArgs.Scenes[self.ScenesIdx_].soldierIds, "_")           --NPC的id
    local tb3 = string.split(cc.GameArgs.Scenes[self.ScenesIdx_].scoreInterregional, "_")   --分值

    local idx = 1
    local lastChance = 0   -- 上一个的概率
    
    while true do
        local tb = {chance = tb1[idx]*100+lastChance, id = tb2[idx], score = tb3[idx]}
        lastChance = tb.chance
        table.insert(self.SoliderInfo_, tb)
        if idx == #tb1 then
            break
        end
        idx = idx + 1
    end
end

--随机创建npc
function LayerFight:createNpc(dt)
    if self.stopTimer_ then return end
    --在清场状态下，不产生新的NPC
    if self.bInBossLeft_ then return end

    local rand = math.random(60)    --[1-60]
    if rand ~= 1 then
        return 
    end
    local d = math.random(100)-1

    for key, value in ipairs(self.SoliderInfo_) do
        if value.chance > d then
            --创建NPC
            local npc = require("app.views.NPC"):create(value.id+0)
            self:addChild(npc)
            table.insert(self.NPCS_, npc)
            break
        end
    end
end

function LayerFight:updateTimer()
    --创建怪物
    self.timerNpc_ = cc.GameUtil.startTimer(handler(self, self.createNpc), 0) 
    --Role 移动
    self.RoleTimer_ = cc.GameUtil.startTimer(handler(self, self.moveRole), 0)
    --让NPC移动
    self.timer_ = cc.GameUtil.startTimer(handler(self, self.moveNpc), 0)
    --检测NPC是否离开屏幕
    self.checkNpc_ = cc.GameUtil.startTimer(handler(self, self.checkNpcOutOfWindow), 0)
    --碰撞检测
    self.collTimer_ = cc.GameUtil.startTimer(handler(self, self.collisionRole), self.Role_.attackSpeed_)
    --npc有概率攻击主角
    self.attackRoleTimer_ = cc.GameUtil.startTimer(handler(self,self.attackRole), 0)
    --npc攻击主角的定时器
    self.attackRoleTimer2_ = cc.GameUtil.startTimer(handler(self,self.attackRoleFrequency), 1)
end

function LayerFight:onEnter()
    self:updateTimer()
end

function LayerFight:onExit()
    --关闭定时器
    cc.GameUtil.killTimer(self.RoleTimer_)
    cc.GameUtil.killTimer(self.timer_)
    cc.GameUtil.killTimer(self.timerNpc_)
    cc.GameUtil.killTimer(self.collTimer_)
    cc.GameUtil.killTimer(self.checkNpc_)
    cc.GameUtil.killTimer(self.attackRoleTimer_)
    cc.GameUtil.killTimer(self.attackRoleTimer2_)
end

--Role移动
function LayerFight:moveRole(dt)
    if self.stopTimer_ then return end
    self.Role_:move(dt)
end

--NPC移动
function LayerFight:moveNpc(dt)
    if self.stopTimer_ then return end
    for key, value in ipairs(self.NPCS_) do
        value:move(dt)
    end
end

--npc有概率会攻击主角
function LayerFight:attackRole()
    local rcRole = self.Role_:getCollisionRect()
    for k, v in ipairs(self.NPCS_) do 
        if v.attackPro_ ~= 0 or v.attackPro_ ~= nil then
            --Role在npc的攻击范围
            local rc = v:getAttackRect()
            
            --概率攻击
            local r = math.random()

            if cc.rectIntersectsRect(rcRole, rc) and r < v.attackPro_ then
                v:setAttack(true)
            else
                v:setAttack(false)
            end
        end
    end
end

--NPC每隔一秒，攻击Role
function LayerFight:attackRoleFrequency()
    for k, v in ipairs(self.NPCS_) do 
        if v.attackPro_ ~= 0 or v.attackPro_ ~= nil then
            if v.isAttack_ then   --正在攻击Role
                self.Role_:setHurt()  --Role受伤
                self.goldChange_ = self.goldChange_ - 10  --被砍一次减金币
            end
        end
    end
end

--检测NPC离场
function LayerFight:checkNpcOutOfWindow(dt)
    local npcCount = #self.NPCS_    -- 获取npc数量
 
    --遍历NPC
    for i=npcCount, 1,  -1 do
        local value = self.NPCS_[i]
        --判断npc是否出窗口
        if math.abs(value.moveDistance_) > value.maxMoveDistance_ then
            --boss离场
            if value.RoleId_ == self.LayerBoss_.bossIds_[self.LayerBoss_.curBossIdx_]+0 then                
                self:bossLeave(false)
            end
            value:removeFromParent()
            table.remove(self.NPCS_, i)
        end
    end

    --回归普通状态
    if #self.NPCS_ == 0 and self.bInFormation_ then
        self.bInBossLeft_ = false
        self.bInFormation_ = false
        self.LayerBoss_.isInBattle_ = false
    end
 
    --NPC和boss都离场了， 出阵
    if #self.NPCS_ == 0 and self.bInBossLeft_ then
        self.bInFormation_ = true
        --创建阵型
        local form = require("app.views.LayerFormation"):create(self.NPCS_)
        self:addChild(form)
    end
end

--碰撞检测
function LayerFight:collisionRole(dt)  
    if self.Role_.isAttack_ then
        --金币在攻击状态会变化
        self.goldChange_ = self.goldChange_ - 1
        --获取角色的攻击矩形
        local rcRole = self.Role_:getAttackRect()
        -- 获取npc数量
        local nCount = #self.NPCS_    
        --遍历NPC表
        for i=nCount, 1,  -1 do
            local value = self.NPCS_[i]
            --获取NPC碰撞检测矩形
            local rcNpc = value:getCollisionRect()
            --判断两个点是否交到一块
            if cc.rectIntersectsRect(rcRole, rcNpc) then
                --npc挨揍了
                value:setHurt()
                --npc减血
                self:subBlood(value, i)
            end
        end
    end 
end

--Npc减血
function LayerFight:subBlood(value, i)
    local atk = math.random(self.Role_.minAtk_, self.Role_.maxAtk_)
    value.blood_ = value.blood_ - atk
    if value.blood_ > 0 then
        --飙血动画
        value:blood()
    else
        self:npcDead(value, i)
    end
end

--金币动画
function LayerFight:goldAnimation(value)
    local money = value.money_
    local idx = money / 10
    idx = math.modf(idx)
    if idx > 5 then idx = 5 end
    if idx <= 0 then idx = 1 end
    
    local x, y = value:getPosition()
    y = y+40

    --金币部分
    local name = string.format("common_money_%d.png", idx)
    local sp = cc.Sprite:createWithSpriteFrameName(name):setGlobalZOrder(1)
    sp:setPosition(cc.p(x , y))
    self:addChild(sp)
    
    local function callback()
        sp:setOpacity(255)
    end

    local function callback2()
        --金币增加
        self.goldChange_ = self.goldChange_ + money
    end

    local fade = cc.FadeOut:create(2)
    local call = cc.CallFunc:create(callback)
    local call2 = cc.CallFunc:create(callback2)
    local rf = cc.RemoveSelf:create()
    local to = cc.MoveTo:create(1.0, cc.p(400, 80))
    sp:runAction(cc.Sequence:create(fade, call, to, call2, rf))
    sp:runAction(cc.MoveBy:create(2, cc.p(0, 80)))

    --文字部分
    local label = cc.Label:createWithBMFont("font/font_gold.fnt", value.money_ .. "")
    label:setPosition(cc.p(x+sp:getBoundingBox().width/2, y))
    self:addChild(label)

    fade = cc.FadeOut:create(2)
    rf = cc.RemoveSelf:create()
    label:runAction(cc.Sequence:create(fade, rf))      --淡出，自毁
    label:runAction(cc.MoveBy:create(2, cc.p(0, 80)))   --上升
end

--npc死亡
function LayerFight:npcDead(value, i)
    --npc死亡
    value:setDead()
    
    --累计人数，用于升级
    self.killCount_ = self.killCount_ + 1
    self.level_:setLevelUpData(self.killCount_)

    --boss死亡
    if value.RoleId_ == self.LayerBoss_.bossIds_[self.LayerBoss_.curBossIdx_]+0 then
        --boss奖励
        value.money_ = value.money_ * self.fac_
        self:bossLeave(true)
    end

    --怒气增加
    self.anger_ = self.anger_ + value.anger_

    --金币动画
    self:goldAnimation(value)

    --npc死亡，从table中移除
    table.remove(self.NPCS_, i) 
end

--升级设置
function LayerFight:levelUpSet()
    self.level_:setVisible(true)
    self.level_:runAnimation()
end

--boss离场情景
function LayerFight:bossLeave(isKilled)
    --boss刚刚离开战场，不产生新怪物，表示进入阵型状态
    self.bInBossLeft_ = true
    --开始清场，npc以四倍速度加速逃离战场
    for k, v in ipairs(self.NPCS_) do
        v.speed_ = v.speed_ * 4
    end

    --boss被击杀
    if isKilled then
        --自定义消息
        local selfEvent = cc.EventCustom:new("Boss killed")
        self:getEventDispatcher():dispatchEvent(selfEvent)
    end
end

--与大招的碰撞检测
function LayerFight:collisionSkill()
    local function func()
        --获取角色攻击范围
        local rcAttack = self.Role_:getAttackRect()
        rcAttack.width = display.width

        local npcCount = #self.NPCS_    -- 获取npc数量
        for i=npcCount, 1,  -1 do
            local value = self.NPCS_[i]
            --npc能被攻击到的矩形范围
            local rc = value:getCollisionRect()
            --碰撞检测
            if cc.rectIntersectsRect(rcAttack, rc) then
                self:npcDead(value, i)
            end
        end
    end

    local delay = cc.DelayTime:create(0.3)
    local call = cc.CallFunc:create(func)
    self:runAction(cc.Sequence:create(delay, call))
end

--大招设置
function LayerFight:setSkill()
    --角色动画
    self.Role_:setSkill()
    
    --创建skill精灵
    self.Role_:createSkillSprite()

    --动画
    self.Role_:skillAnimation()
    
    --创建Label显示大招的名字
    self.Role_:showSkillName()
    
    --碰撞检测
    self:collisionSkill()
end

--游戏暂停
function LayerFight:gamePause()
    --1.定时器关闭
    self.stopTimer_ = true

    self.Role_:pause()
    for k, v in ipairs(self.NPCS_) do
        v:pause()
    end
end

--游戏继续
function LayerFight:gameResume()
    self.stopTimer_ = false

    self.Role_:resume()
    for k, v in ipairs(self.NPCS_) do
        v:resume()
    end
end

return LayerFight

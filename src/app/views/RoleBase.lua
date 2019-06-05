local RoleBase = class("RoleBase", function(RoleId)
    local sp = cc.Sprite:create()

    --保存角色id
    sp.RoleId_ = RoleId

    --设置锚点
    local x = cc.GameArgs.ModelConfig[sp.RoleId_].pointX
    local y = cc.GameArgs.ModelConfig[sp.RoleId_].pointY
    sp:setAnchorPoint(cc.p(x, y))
    
    return sp
end)

function RoleBase:ctor()
    --print("RoleBase ctor")
	self:init()               --初始化
end

function RoleBase:init()
    --角色id
    self.RId_ = 0

    --角色的位移向量
    self.moveVec_ = {x=0, y=0}   
    
    --角色是否跑动
    self.isRunning_ = false

    --角色是否走动
    self.isWalking_ = false

    --角色是否攻击
    self.isAttack_ = false

    --角色是否受伤害
    self.isHurt_ = false

    --角色是否死亡
    self.isDead_ = false

    --角色死亡标记
    self.isRemoveFlg_ = false

    --角色的速度
    self.speed_ = 0

    --获取角色的大小
    self.RoleWidth_ = 0     --（宽）
    self.RoleHeight_ = 0    --（高）

    --角色默认的状态（站着）
    self.RoleStatus_ = nil

    --角色朝向(默认朝右)
    self.isRoleFace_ = true  
    
    --角色的攻击速度
    self.attackSpeed_ = 0             

    --角色攻击力
    self.minAtk_ = 0    --（最小）
    self.maxAtk_ = 0    --（最大）

    --角色的血量(默认一百，方便调试)
    self.blood_ = 100

    --标记角色移动的距离
    self.moveDistance_ = 0

    --角色的怒气值
    self.anger_ = 0

    --角色大招有关信息
    self.skillId_ = 0
    self.skillInfo = {}

    --角色的大小
    self.RoleSize_ = {width = 0, height = 0}
    
    --角色攻击的大小
    self.attackSize_ = {width=0, height=0}

    --用于区分角色与NPC的动画的
    self.type = "npc"
end

--角色的大小
function RoleBase:getRoleSize()
    local size = cc.GameArgs.ModelConfig[self.RId_+0].size
    local tp = string.split(size, "_")
    self.RoleSize_.width, self.RoleSize_.height = tp[1], tp[2]
    --print("RoleSize", self.RoleSize_.width, self.RoleSize_.height)
end

--角色攻击的大小
function RoleBase:getAttackSize()
    local size  = cc.GameArgs.ModelConfig[self.RId_+0].AttackSize
    local tp  = string.split(size, "_")
    self.attackSize_.width = tp[1] or 0
    self.attackSize_.height = tp[2] or 0
end
--更新状态
function RoleBase:updateStatus()
    if self.isAttack_ then return end
    
    if self.isWalking_ then
        if self.isRunning_ then
            self.RoleStatus_ = "run"
        else
            self.RoleStatus_ = "walk"
        end
    else
        self.RoleStatus_ = "stand"
    end
end


function RoleBase:setRunning(running)
    self.isRunning_ = running
    self:updateStatus()
end

function RoleBase:setWalking(walking) 
    self.isWalking_ = walking
    self:updateStatus()
end

function RoleBase:setAttack(attack)
    if self.isHurt_ then return end
    if attack == self.isAttack_ then return end

    if attack then
        self:stopAllActions()
        self.RoleStatus_ = "attack"
        self:runAnimation()
    else
        if self.type == "npc" then
            self.RoleStatus_ = "walk"
        else
            self.RoleStatus_ = "attack_stop"   --特殊动作来过渡一下，防止得到错误动作
        end
    end
end

function RoleBase:setHurt()
    if self.isHurt_ then return end
    
    self.isHurt_ = true

    self:stopAllActions()
    self.RoleStatus_ = "hurt"
    self:runAnimation()
end

function RoleBase:setDead()
    self.isDead_ = true
    self:stopAllActions()

    self.RoleStatus_ = "die"
    self:runAnimation()
end

--角色发大招
function RoleBase:setSkill()
    self:stopAllActions()
    self.isHurt_ = false
    self.RoleStatus_ = "skill"
    self:runAnimation()
end

--获取碰撞检测时的矩形范围
function RoleBase:getCollisionRect()
    local rect = {x=0, y=0, width=0, height=0}

    rect.x, rect.y = self:getPosition()
    rect.width =  self.RoleSize_.width or 0 
    rect.height = self.RoleSize_.height or 0
  
    return rect
end

--获取攻击矩形范围
function RoleBase:getAttackRect()
    local rect = {x=0, y=0, width=0, height=0}
    rect.x , rect.y = self:getPosition()

    if self.isRoleFace_ == false then
        rect.x = rect.x - self.attackSize_.width
    end

    rect.width = self.attackSize_.width or 0
    rect.height = self.attackSize_.height or 0

    return rect
end

function RoleBase:runAnimation()
    if self.isRemoveFlg_ then
        local delay = cc.DelayTime:create(2)
        local rf = cc.RemoveSelf:create()
        self:runAction(cc.Sequence:create(delay, rf))    
        return 
    end

    if self.RoleStatus_ == "attack" then
        self.isAttack_ = true
    else
        self.isAttack_ = false
    end

    if self.RoleStatus_ == "attack_stop" then
        self.isAttack_ = false
        self:updateStatus()
    end

    local aniDir = "model/" .. self.RId_
    local plistFile  = aniDir .. "/" .. self.RId_ .. "_" .. self.RoleStatus_ .. ".plist"
    
    --判断配置文件中是否存在相应的动画，若不存在则跳过此动画
    local path = "E:/cocos/Lua/ThreeKingdom/res/" .. plistFile
    local ret = cc.GameUtil.file_exists(path)
    if ret == false then
        return 
    end

    local ani = cc.GameUtil.loadAnimations(plistFile, self.RoleStatus_, self.RId_, 0.05)
    local amt = cc.Animate:create(ani) 

    local function callback()
        self:runAnimation()
    end
    local call = cc.CallFunc:create(callback,{})
    
    local function callbackHurt()
        self.isHurt_ = false
        self:updateStatus()
    end
     
    local function callbackDead()
        self.isRemoveFlg_ = true
    end
    
    local function callbackSkill()
        self:updateStatus()
    end

    local call2 = nil

    if self.RoleStatus_ == "hurt" then
        call2 = cc.CallFunc:create(callbackHurt)
        self:runAction(cc.Sequence:create(amt, call2, call))
    elseif self.RoleStatus_ == "die" then 
        call2 = cc.CallFunc:create(callbackDead)
        self:runAction(cc.Sequence:create(amt, call2, call))
    elseif self.RoleStatus_ == "skill" then
        call2 = cc.CallFunc:create(callbackSkill)
        self:runAction(cc.Sequence:create(amt, call2, call))
    else
        self:runAction(cc.Sequence:create(amt, call))     
    end
end 

function RoleBase:setMoveVec(vec)
    if vec.x ~= self.moveVec_.x or vec.y ~= self.moveVec_.y then
        self.moveVec_ = cc.p(vec.x, vec.y)
        if self.moveVec_.x < 0 then    --设置角色移动的方向
            self:setFlippedX(true)     --向左
            self.isRoleFace_ = false
        elseif self.moveVec_.x > 0 then
            self:setFlippedX(false)    --向右
            self.isRoleFace_ = true
        end
    end
end

function RoleBase:move(dt)
    --判断角色是否能走
    if self.moveVec_.x == 0 and self.moveVec_.y == 0 then
        return
    end

    if self.isHurt_  or self.isAttack_ then 
        return 
    end

    local delta = cc.pMul(self.moveVec_, self.speed_*dt)
    local x , y = self:getPosition()

    if self.type  ~= "npc" then
        --检测出边界问题
        --上下
        if y+delta.y < 0 or y+delta.y >= display.cy then
            delta.y = 0
        end
    
        --左右
        if x+delta.x- self.RoleWidth_ < 0 or x+delta.x+self.RoleWidth_ >= display.width then
            delta.x = 0
        end
    end

    self:setPosition(cc.p(x+delta.x, y+delta.y))

    --保存角色移动的距离
    self.moveDistance_ = self.moveDistance_ + delta.x
end


return RoleBase

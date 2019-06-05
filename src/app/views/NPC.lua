local tmp =  require("app.views.RoleBase")

local NPC = class("NPC", tmp)

function NPC:ctor()
    --调用父类的构造函数
    self.super.ctor(self)
    
    --保存NPC的id（方便 动画）
    self.RId_ = self.RoleId_

    --初始化各项数据
    self:initData()

     --NPC移动的方向
    self:moveDir()

    --运行动画
    self:runAnimation(self)
        
    --获取角色大小
    self:getRoleSize()

    --获取角色的攻击范围
    self:getAttackSize() 
end

function NPC:initData()
        --设置NPC的速度
    self.speed_ = cc.GameArgs.Soldier[self.RoleId_].moveSpeed

    --NPC默认的动画
    self.RoleStatus_ = "walk"

    --获取怒气值
    self.anger_ = cc.GameArgs.Soldier[self.RoleId_].anger

    --自身价值
    self.money_ = cc.GameArgs.Soldier[self.RoleId_].money

    --默认角色移动多少距离，就算出窗口
    self.maxMoveDistance_ = display.width + 400

    --NPC攻击概率
    self.attackPro_ = cc.GameArgs.Soldier[self.RoleId_].attackProbability

    --NPC攻击速度
    self.attackSpeed_ = cc.GameArgs.Soldier[self.RoleId_].attackSpeed
end

 --NPC随机出现的方向
function NPC:moveDir()
    local dir = math.random()
    if dir < 0.5 then   -- 从左往右
        self.moveVec_ = cc.p(1,0)
        self:setPositionX(200)   --出现的位置
    else  --从右往左
        self.moveVec_ = cc.p(-1, 0)
        self:setPositionX(display.width-200)
        self:setFlippedX(true)
    end
    self:setPositionY(math.random(0, display.cy))
end

--飙血动画
function NPC:blood()
    local sp = cc.Sprite:create():setPosition(cc.p(self:getPosition())):addTo(self)
    sp:setPositionY(sp:getPositionY() + self.RoleSize_.height)
    --执行动画 然后removeSelf
    local ani = cc.GameUtil.getAnimation("fightImg/blood.plist", "blood_%04d.png", 0, 0.05)
    local mt = cc.Animate:create(ani)
    local rf = cc.RemoveSelf:create()
    sp:runAction(cc.Sequence:create(mt, rf))
end

return NPC

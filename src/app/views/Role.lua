--添加英雄
local tmp = require("app.views.RoleBase")

local Role = class("Role", tmp)

function Role:ctor()
    --调用父类的构造函数
    self.super:ctor(self)

    --保存角色的id（方便动画）
    self.RId_ = self.RoleId_

    --设置角色的默认状态
    self.RoleStatus_ = "stand"

    self.type = "ROLE"

    --设置角色的移动速度
    self.speed_ = cc.GameArgs.Role[self.RoleId_+0].moveSpeed * 60/2    
    
    --获取角色的攻击速度
    self.attackSpeed_ = cc.GameArgs.Role[self.RoleId_+0].attackSpeed             --设置攻击速度

    --获取角色大招的id
    self.skillId_ = cc.GameArgs.Role[self.RoleId_+0].skillId

    --保存大招相关信息
    self.skillInfo_ = cc.GameArgs.Skill[self.skillId_+0]

    self:initData()
end

function Role:initData()
    --获取角色大小
    self:getRoleSize()

    --获取角色的攻击范围    
    self:getAttackSize()
    
    --运行动画
    self:runAnimation(self)

    --获取角色攻击力
    self:getAttackForce()
end


--获取攻击力度
function Role:getAttackForce()
    self.minAtk_ = cc.GameArgs.Role[self.RoleId_].minATK    --（最小）
    self.maxAtk_ = cc.GameArgs.Role[self.RoleId_].maxATK    --（最大）
    --print(self.minAtk_, self.maxAtk_)
end

--创建大招精灵
function Role:createSkillSprite()
    self.skillSprite_ = cc.Sprite:create()
    
    --设置锚点
    local x = self.skillInfo_.skillpointX
    local y = self.skillInfo_.skillpointY
    self.skillSprite_:setAnchorPoint(cc.p(x, y))

    --设置位置
    local rx, ry = self:getPosition()
    self.skillSprite_:setPosition(cc.p(rx, ry))
    self:addChild(self.skillSprite_)
end

--大招动画
function Role:skillAnimation()
    if self.isRoleFace_ then self.skillSprite_:setFlippedX(true) end
    local plistFile = string.format("model/%d/%d_skill_hit.plist", self.skillId_, self.skillId_)
    local skFormat = self.skillId_  .. "_skill_hit_%04d.png"
    local ani = cc.GameUtil.getAnimation(plistFile, skFormat, 0, 0.05)
    local mt = cc.Animate:create(ani)
    local rf = cc.RemoveSelf:create()
    self.skillSprite_:runAction(cc.Sequence:create(mt, rf))
end

--显示大招名字
function Role:showSkillName()
    local skillName = cc.Label:createWithBMFont("font/font_skillName.fnt", self.skillInfo_.name)
    self:addChild(skillName)
    skillName:setPosition(cc.p(display.cx, display.height - 100))
    --字体消失
    local delay = cc.DelayTime:create(1)
    local fade  = cc.FadeOut:create(0.6)
    local rm = cc.RemoveSelf:create()
    skillName:runAction(cc.Sequence:create(delay, fade, rm))
end

return Role
local tmp =  require("app.views.RoleBase")

local NPC = class("NPC", tmp)

function NPC:ctor()
    --���ø���Ĺ��캯��
    self.super.ctor(self)
    
    --����NPC��id������ ������
    self.RId_ = self.RoleId_

    --��ʼ����������
    self:initData()

     --NPC�ƶ��ķ���
    self:moveDir()

    --���ж���
    self:runAnimation(self)
        
    --��ȡ��ɫ��С
    self:getRoleSize()

    --��ȡ��ɫ�Ĺ�����Χ
    self:getAttackSize() 
end

function NPC:initData()
        --����NPC���ٶ�
    self.speed_ = cc.GameArgs.Soldier[self.RoleId_].moveSpeed

    --NPCĬ�ϵĶ���
    self.RoleStatus_ = "walk"

    --��ȡŭ��ֵ
    self.anger_ = cc.GameArgs.Soldier[self.RoleId_].anger

    --�����ֵ
    self.money_ = cc.GameArgs.Soldier[self.RoleId_].money

    --Ĭ�Ͻ�ɫ�ƶ����پ��룬���������
    self.maxMoveDistance_ = display.width + 400

    --NPC��������
    self.attackPro_ = cc.GameArgs.Soldier[self.RoleId_].attackProbability

    --NPC�����ٶ�
    self.attackSpeed_ = cc.GameArgs.Soldier[self.RoleId_].attackSpeed
end

 --NPC������ֵķ���
function NPC:moveDir()
    local dir = math.random()
    if dir < 0.5 then   -- ��������
        self.moveVec_ = cc.p(1,0)
        self:setPositionX(200)   --���ֵ�λ��
    else  --��������
        self.moveVec_ = cc.p(-1, 0)
        self:setPositionX(display.width-200)
        self:setFlippedX(true)
    end
    self:setPositionY(math.random(0, display.cy))
end

--�Ѫ����
function NPC:blood()
    local sp = cc.Sprite:create():setPosition(cc.p(self:getPosition())):addTo(self)
    sp:setPositionY(sp:getPositionY() + self.RoleSize_.height)
    --ִ�ж��� Ȼ��removeSelf
    local ani = cc.GameUtil.getAnimation("fightImg/blood.plist", "blood_%04d.png", 0, 0.05)
    local mt = cc.Animate:create(ani)
    local rf = cc.RemoveSelf:create()
    sp:runAction(cc.Sequence:create(mt, rf))
end

return NPC

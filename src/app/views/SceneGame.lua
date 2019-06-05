
local SceneGame = class("SceneGame", cc.load("mvc").ViewBase)

function SceneGame:onCreate()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("joyStick/joyStickImg.plist")

    --战斗层  
    --英雄和怪物，移动和碰撞检测
    self.fight_ = require("app.views.LayerFight"):create()
    self:addChild(self.fight_)
    
    --控制层
    --提供用户接口，控制英雄
    self.ctrl_ = self.app_:createView("LayerCtrl")
    self:addChild(self.ctrl_)

    --设置和信息
    --游戏菜单
    self.menu_ = self.app_:createView("LayerMenu")
    self:addChild(self.menu_)
    
    --提示层
    --提示信息
    self.tip_ = self.app_:createView("LayerTip")
    self:addChild(self.tip_)

    --添加金币层
    self.gold_ = require("app.views.LayerGold"):create()
    self:addChild(self.gold_)
end

function SceneGame:onEnter()
    --添加定时器(获取英雄每一帧的状态)
    self.timer_ = cc.GameUtil.startTimer(handler(self, self.update), 0)
end

function SceneGame:onExit()
    cc.GameUtil.killTimer(self.timer_)
end

--定时器处理函数
function SceneGame:update(dt)
    self.fight_.Role_:setMoveVec(self.ctrl_.moveVec_)    --移动
    self.fight_.Role_:setRunning(self.ctrl_.isRunning_)  --跑
    self.fight_.Role_:setWalking(self.ctrl_.isWalking_)  --走
    self.fight_.Role_:setAttack(self.ctrl_.isAttack_)    --攻击
    if self.ctrl_.isSkill_ then 
        self.fight_:setSkill()      --发大招
        --self.ctrl_.isSkill_ = false
    end
    --获取怒气值，设置进度条
    self:getAngerToSetPercentage()

    --改变金币层的显示
    self.gold_:changeGold(self.fight_.goldChange_)
    self.fight_.goldChange_ = 0  --得重置
end

function SceneGame:getAngerToSetPercentage()
    local pre = self.ctrl_.progressTimer_:getPercentage()
    pre = pre + self.fight_.anger_
    self.fight_.anger_ = 0

    pre = pre > 100 and 100 or pre
    self.ctrl_.progressTimer_:setPercentage(pre)
end

return SceneGame

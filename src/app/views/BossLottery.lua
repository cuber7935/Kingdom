--抽奖界面（大乐透）
local BossLottery = class("BossLottery", cc.load("mvc").ViewBase)

function BossLottery:ctor(value)
    self.curId_ = value
    self:init()
end

function BossLottery:init()
    --加载精灵帧
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames("/ui/fightUI/bossLottery.plist")

    --创建大转盘
    self:createBg()

    --创建指针
    self:createPointer()

    --创建珠子
    self:createPearls()

    --概率因子
    self.factor_ = 1

    --抽奖是否完成
    self.isFinish_ = false

       --大乐购概率
    self.fortune_ = {}

    --获取大乐购概率
    self:getWheelOfFortune()

    --奖励倍数
    self.BonusTimes_ = {1, 2, 10, 20, 50, 100}

    --旋转角度
    self.angleFix_ = {0, 60, 120, 180, 240, 300} 

    --添加触摸
    self:addTouch()
end

--创建大转盘
function BossLottery:createBg()
    self.bg_ = cc.Sprite:createWithSpriteFrameName("bossLottery_bg.png")
    self:addChild(self.bg_)
    self.bg_:setPosition(display.center)
end

--创建指针
function BossLottery:createPointer()
    self.pointer_ = cc.Sprite:createWithSpriteFrameName("bossLottery_btn.png")
    self:addChild(self.pointer_)
    local sz = self.pointer_:getContentSize()
    self.pointer_:setPosition(cc.p(display.cx, display.cy + sz.height/2 - sz.width/2))
end

--创建珠子
function BossLottery:createPearls()
    local angle = 0
    local radius = self.bg_:getContentSize().width/2 - 15
    local bAncher = self.bg_:getAnchorPointInPoints()
    for i=1, 12 do
        local idx = math.fmod(i, 2) + 1
        local shine = cc.Sprite:createWithSpriteFrameName("bossLottery_light_" .. idx .. ".png")
        self.bg_:addChild(shine)

        local x = math.sin(angle * math.pi/180) * radius + bAncher.x
        local y = math.cos(angle * math.pi/180) * radius + bAncher.y

        shine:setPosition(cc.p(x, y))

        angle = angle + 30
    end
end

-- 获取boss奖励概率
function BossLottery:getWheelOfFortune()
    local first = string.split(cc.GameArgs.WheelOfFortune[1].firstProbability, "_")
    local second = string.split(cc.GameArgs.WheelOfFortune[1].secondProbability, "_")
    local third = string.split(cc.GameArgs.WheelOfFortune[1].thirdProbability,"_")

    table.insert(self.fortune_, first)
    table.insert(self.fortune_, second)
    table.insert(self.fortune_, third)

    for _, v in ipairs(self.fortune_) do
        local tPro = v
        for k, value in ipairs(tPro) do
            if k == 1 then
                tPro[k] = tPro[k] + 0
            else
                tPro[k] = tPro[k] + tPro[k-1] 
            end
        end
    end

end

--触摸
function BossLottery:addTouch()
    local listener = cc.EventListenerTouchOneByOne:create() -- 创建一个事件监听器
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.TouchBeagn), cc.Handler.EVENT_TOUCH_BEGAN)
    
    local eventDispatcher = self:getEventDispatcher() -- 得到事件派发器
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.pointer_) -- 将监听器注册到派发器中
end

function BossLottery:TouchBeagn(touch)
     -- 判断是否点中抽奖键
    local touchPt = touch:getLocation()
    --获取两点的距离
    local dt = math.sqrt(cc.pDistanceSQ(touchPt, display.center))
    if dt <  self.pointer_:getContentSize().width/2 then
        --if self.isFinish_ then return false end
        
        local key = self:getBonusTimes()
        self:rotateByAngle(key)

        return true
    else
        return false
    end
end

--获取奖励倍数对应的角度
function BossLottery:getBonusTimes()
    --根据当前boss获取相关概率
    local pro = self.fortune_[self.curId_]
    --随机值
    local rValue = math.random()
    --获取奖励倍数
    for k, v in ipairs(pro) do
        if v < rValue then
            self.factor_ = self.BonusTimes_[k] 
            
            return k 
        end
    end 
end

--转动转盘(8-10次)
function BossLottery:rotateByAngle(val)
    val = val or 1
     -- 旋转角度（圈数）
    local angle = math.random(8,10) * 360
    
    --实际转的角度
    angle = angle + self.angleFix_[val+0] + math.random(0, 60)
    --print(self.angleFix_[value+0])
    local function func()
         --自定义消息
        local selfEvent = cc.EventCustom:new("finished Lottery")
        self:getEventDispatcher():dispatchEvent(selfEvent)
    end

    local rot = cc.RotateBy:create(angle/720, angle)
    local ease = cc.EaseExponentialOut:create(rot)
    local call = cc.CallFunc:create(func)
    --self.bg_:runAction(cc.Sequence:create(rot, call))
   
   --开始旋转动作  使用EaseExponentialOut(迅速加速，然后慢慢减速)
    self.bg_:runAction(cc.Sequence:create(ease, call))
end

return BossLottery

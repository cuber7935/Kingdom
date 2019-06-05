--控制层
local LayerCtrl = class("LayerCtrl", cc.load("mvc").ViewBase)

function LayerCtrl:onCreate()
    self.moveVec_ = {x=0, y=0}     -- 移动方向
    self.isRunning_ = false        -- 是否跑动
    self.isWalking_ = false        -- 是否走动
    self.isAttack_ = false         -- 是否攻击
    self.isSkill_  = false         -- 发大招
   
   --控制方向键
    self:createDir()
    self:addTouchDir()

    --攻击键
    self:createAttack()
    self:addTouchAttack()

    --大招
    self:createSkill()
    self:addTouchSkill()
end

--创建方向键
function LayerCtrl:createDir()
    self.dir_ = cc.Sprite:createWithSpriteFrameName("joyStick.png")
    self.ctrl_ = cc.Sprite:createWithSpriteFrameName("joyStickCenter.png")
    self:addChild(self.dir_)
    self.dir_:addChild(self.ctrl_ )

    self.ctrl_ :setPosition(self.dir_:getAnchorPointInPoints())
    local rc = self.dir_:getBoundingBox()
    self.dir_:setPosition(cc.p(rc.width/2+20, rc.height/2+20))
    self.rc_ = self.dir_:getBoundingBox()
end

function LayerCtrl:addTouchDir()
    local listener = cc.EventListenerTouchOneByOne:create() -- 创建一个事件监听器
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.TouchBeagn), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.TouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.TouchEnded), cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = self:getEventDispatcher() -- 得到事件派发器
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.dir_) -- 将监听器注册到派发器中
end

 --创建攻击按钮
function LayerCtrl:createAttack()
    self.layer_ = cc.Layer:create()
    self:addChild(self.layer_)

    self.btn_ = cc.Sprite:createWithSpriteFrameName("joyStickButton.png")
    self.layer_:addChild(self.btn_)
    local rc = self.btn_:getBoundingBox() 
    self.btn_:setPosition(cc.p(display.width-rc.width/2, rc.height/2+20 ))
    self.rcBtn_ = rc

end

function LayerCtrl:addTouchAttack()    
    local listener = cc.EventListenerTouchOneByOne:create() -- 创建一个事件监听器
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(handler(self, self.btnBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.btnEnded), cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = self:getEventDispatcher() -- 得到事件派发器
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.btn_) -- 将监听器注册到派发器中
end

--攻击键
function LayerCtrl:createSkill()
    local layer = cc.Layer:create()
    self.layer_:addChild(layer)
    --创建背景精灵
    self.jKillGrayBtn_ = cc.Sprite:createWithSpriteFrameName("joyStickskillButtonGray.png")
    layer:addChild(self.jKillGrayBtn_)

    local x, y = self.btn_:getPosition()
    local dt = self.jKillGrayBtn_:getContentSize().width/2 + self.btn_:getContentSize().width/2 + 20
    x = x - dt
    self.jKillGrayBtn_:setPosition(cc.p(x, y))
   
    --创建前景精灵
    self.force = cc.Sprite:createWithSpriteFrameName("joyStickskillButton.png")
    self.progressTimer_ = cc.ProgressTimer:create(self.force)
    layer:addChild(self.progressTimer_)
    self.progressTimer_:setPosition(cc.p(self.jKillGrayBtn_:getPosition()))

    --设置进度条属性
    self.progressTimer_:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.progressTimer_:setMidpoint(cc.p(0,0))
    self.progressTimer_:setBarChangeRate(cc.p(0, 1))
end

function LayerCtrl:addTouchSkill()
    local listener = cc.EventListenerTouchOneByOne:create() -- 创建一个事件监听器
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(handler(self, self.skillBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.skillEnded), cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = self:getEventDispatcher() -- 得到事件派发器
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.jKillGrayBtn_) 
end

function LayerCtrl:skillBegan(touch)
    -- 怒气值小于100， 不让点
    if self.progressTimer_:getPercentage() < 99.999 then return false end

    -- 判断是否点中技能键
    local pt = cc.p(self.jKillGrayBtn_:getPosition())
    local touchPt = touch:getLocation()
    --获取两点的距离(未开平方)
    local dt = math.sqrt(cc.pDistanceSQ(touchPt, pt))
    if dt <  self.jKillGrayBtn_:getContentSize().width/2  then
        --进度条清空
        self.progressTimer_:setPercentage(0)
        --背景图切换
        self.jKillGrayBtn_:setSpriteFrame("joyStickskillButtonHighLight.png")
        --记录发大招信息
        self.isSkill_ = true
        return true
    else
        return false
    end
end

function LayerCtrl:skillEnded()
    --背景图切换
    self.jKillGrayBtn_:setSpriteFrame("joyStickskillButtonGray.png")
    --记录发大招信息
    self.isSkill_ = false
end


function LayerCtrl:TouchBeagn(touch, event)
    local ret = cc.rectContainsPoint( self.rc_, self.dir_:convertToNodeSpace(touch:getLocation())) 
    if ret then
        self.isWalking_ = true
    end
    return ret
end

function LayerCtrl:TouchEnded()
    self.ctrl_ :setPosition(self.dir_:getAnchorPointInPoints())
    self.isRunning_ = false
    self.isWalking_ = false
    self.moveVec_ = cc.p(0,0)
end

function LayerCtrl:TouchMoved(touch)
   --大圈的位置
   local pos =  cc.p(self.dir_:getPosition())
   --触摸点的位置
   local touchPt = touch:getLocation()
   
   --获取两个点的距离
   local dist = math.sqrt(cc.pDistanceSQ(pos, touchPt))
   
   --两球半径之差
   local ret = self.dir_:getBoundingBox().width/2 - self.ctrl_:getBoundingBox().width/2
   
   local dt = cc.pSub(touchPt, pos)
   dt = cc.pNormalize(dt)              --归化 dt是一个table
   self.moveVec_ = cc.p(dt.x, dt.y)    --需要深拷贝，否则改变其中一个表，另一个表也跟着变化

   --判断 距离是否在大圈内
   if dist > ret then   -- 不在
       dt = cc.pMul(dt, ret)     --乘法（xy 都乘以半径之差）
       dt = cc.pAdd(dt, pos)     --加法（加上大圈的位置）
       self.ctrl_:setPosition(self.dir_:convertToNodeSpace(dt))    --注意要将世界坐标转换成节点坐标
       self.isRunning_ = true
   else  --在
       self.ctrl_:setPosition(self.dir_:convertToNodeSpace(touchPt))
       self.isRunning_ = false
   end
end

function LayerCtrl:btnBegan(touch)
    if self.isAttack_ then 
        return 
    end

     -- 判断是否点中技能键
    local x, y = self.btn_:getPosition()
    local touchPt = touch:getLocation()
    --获取两点的距离(未开平方)
    local dt = math.sqrt(cc.pDistanceSQ(touchPt, cc.p(x, y)))
    if dt <  self.btn_:getContentSize().width/2 then
        self.isAttack_ = true
        self.btn_:setSpriteFrame("joyStickButtonHighLight.png")
        return true
    else
        self.isAttack_ = false
        return false
    end
end

function LayerCtrl:btnEnded()
    self.isAttack_ = false
    self.btn_:setSpriteFrame("joyStickButton.png")
end

return LayerCtrl
local LayerGold = class("LayerGold", cc.load("mvc").ViewBase)

function LayerGold:onCreate()
    --加载精灵帧
    local spriteFrameCache = cc.SpriteFrameCache:getInstance()
    spriteFrameCache:addSpriteFrames("common/common.plist")

    --创建背景
    self:createBg()

    --创建前景
    self:createFore()

    --保存金币
    self.saveMoney_ = 0
end


function LayerGold:createBg()
    local bg1 = cc.Sprite:createWithSpriteFrameName("common_ink.png")
    self.bg2_ = cc.Sprite:createWithSpriteFrameName("common_frame_1.png")
    self:addChild(self.bg2_)
    self:addChild(bg1)
    bg1:setScale(1.5)
    self.bg2_:setScale(1.8, 1.2)
    
    self.pos_ = cc.p(400, 80)

    bg1:setPosition(self.pos_)
    self.bg2_:setPosition(cc.p(self.pos_.x+ self.bg2_:getBoundingBox().width/2, self.pos_.y))
end

function LayerGold:createFore()
    local fore1 = cc.Sprite:createWithSpriteFrameName("common_money_3.png")  
    self:addChild(fore1)
    fore1:setPosition(self.pos_)

    self.fore2_ = cc.Label:createWithBMFont("font/font_gold.fnt", "0")
    self:addChild(self.fore2_)  
    local x, y = self.bg2_:getPosition()
    self.fore2_:setPosition(cc.p(x, y-8))
end

--钱发生变化
function LayerGold:callBackGold()
    if self.saveMoney_ < 0 then
        self:setGold(-1)
        self.saveMoney_ = self.saveMoney_ + 1
    elseif self.saveMoney_  > 0 then
        self:setGold(1)
        self.saveMoney_ = self.saveMoney_ - 1
    end
end

function LayerGold:setGold(value)
    value = value or 0

    local money = self.fore2_:getString()
    money = money + value
    self.fore2_:setString(money .."")
end

function LayerGold:changeGold(changeValue)
    self.saveMoney_ = self.saveMoney_+ changeValue
end

function LayerGold:onEnter()
    self.timer = cc.GameUtil.startTimer(handler(self, self.callBackGold), 0)
end

function LayerGold:onExit()
    cc.GameUtil.killTimer(self.timer)
end


return LayerGold

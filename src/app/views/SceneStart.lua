local SceneStart = class("SceneStart", cc.load("mvc").ViewBase)

function SceneStart:onExit()
    -- 关掉定时器
    cc.GameUtil.killTimer(self.timer_)
end

-- 动态背景
function SceneStart:moveBg(dt)
    local bgRight = self.node_:getChildByName("createCharacter_bg_1")   --右
    local bgLeft = self.node_:getChildByName("createCharacter_bg_19")   --左

    local rx, ry = bgRight:getPosition()            --右
    local lx, ly = bgLeft:getPosition()             --左

    bgRight:setPosition(cc.p(rx + 10*dt, ry))
    bgLeft:setPosition(cc.p(lx +10*dt, ly))

    rx, ry = bgRight:getPosition()
    -- 若右边跑到窗口外，就和左边的对调下
    if rx > display.width then
        local lx, ly = bgLeft:getPosition()
        bgRight:setPosition(cc.p(lx - 1176, ly))

        bgRight, bgLeft = bgLeft, bgRight
    end
end

function SceneStart:onCreate()
    -- 加载界面
    self.node_ = cc.CSLoader:createNode("ccs/LayerStart.csb")
    --print(self.node_)
    self:addChild(self.node_)

    -- 设置定时器
    self.timer_ = cc.GameUtil.startTimer(handler(self, self.moveBg), 0)
    
    -- 按钮处理
    -- Node
    -- switch, slider : Control
    -- 进入游戏按钮
    local enterButton = self.node_:getChildByName("Button_7")
    
    -- 强制转换（将node转换成ui的button）
    enterButton = tolua.cast(enterButton, "ccui.Button")
    
    -- 添加触摸
    enterButton:addTouchEventListener(handler(self, self.btnCallback))
end

function SceneStart:btnCallback(btn, ev)
    cc.GameArgs.RoleId = 20002    --暂时放在这
    self.app_:enterScene("SceneSelectMap")
end

return SceneStart
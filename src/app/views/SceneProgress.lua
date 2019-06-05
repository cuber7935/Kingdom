
local SceneProgress = class("SceneProgress", cc.load("mvc").ViewBase)

local prefix = [[
    local config = {}
    local scenes = {}
    local skill = {}
    local soldier = {}
    local task = {}
]]

local suffix = [[
    cc.GameArgs.config = config
    cc.GameArgs.scenes = scenes
    cc.GameArgs.skill = skill
    cc.GameArgs.soldier = soldier
    cc.GameArgs.task = task
]]

local xmlPaths = {
    "xml/BaseFormation.xml",
    "xml/DailyTasks.xml",
    "xml/LoginReward.xml",
    "xml/ModelConfig.xml",
    "xml/Recharge.xml",
    "xml/Role.xml",
    "xml/Scenes.xml",
    "xml/Skill.xml",
    "xml/Soldier.xml",
    "xml/SystemConfig.xml",
    "xml/Tips.xml",
    "xml/Title.xml",
    "xml/TreasureBowl.xml",
    "xml/Vip.xml",
    "xml/WheelOfFortune.xml"
}

--添加背景
function SceneProgress:addBgSources()
    --加载精灵帧
    self.spriteFrameCache_ = cc.SpriteFrameCache:getInstance()
    self.spriteFrameCache_ :addSpriteFrames("ui/loadingScene/loadingScene.plist")
    self.spriteFrameCache_ :addSpriteFrames("ui/loadingScene/loading_fire.plist")

    --加载背景1
    self.spriteBg1_ = cc.Sprite:createWithSpriteFrameName("loadingScene_role.png")
    self:addChild(self.spriteBg1_);
    self.spriteBg1_:setPosition(display.center)

    --加载背景2
    self.spriteBg2_ = cc.Sprite:createWithSpriteFrameName("loadingScene_logo.png")
    self:addChild(self.spriteBg2_);
    self.spriteBg2_:setPosition(display.center)

    --加载背景3
    self.spriteBg3_= cc.Sprite:createWithSpriteFrameName("loadingScene_frame.png")
    self:addChild(self.spriteBg3_)
    self.spriteBg3_:setPosition(cc.p(display.cx, display.cy/2))
end

--添加进度条
function SceneProgress:addProgressTimer()
     --创建进度条
    self.bar_ = cc.Sprite:createWithSpriteFrameName("loadingScene_bar.png")

    self.progressTimer_ = cc.ProgressTimer:create(self.bar_)
    self:addChild(self.progressTimer_ )
    self.progressTimer_:setPosition(cc.p(self.spriteBg3_:getPosition()))

    --设置进度条属性
    self.progressTimer_:setType(1)                     --类型
    self.progressTimer_:setMidpoint(cc.p(0, 0))        --从左往右
    self.progressTimer_:setBarChangeRate(cc.p(1, 0))   --步伐

    -- 获取进度条的大小
    self.barSize_ = self.bar_:getContentSize()
    --创建一个球精灵
    self.ball_ = cc.Sprite:createWithSpriteFrameName("loading_fire_0000.png")
    --将球加在背景3上
    self.spriteBg3_:addChild(self.ball_)
    --设置球的位置
    self.ball_:setPosition(cc.p(0, self.barSize_.height/2+3))
    --设置球的zorder
    self.ball_:setGlobalZOrder(1)
end

--增加动画
function SceneProgress:addAnimation()
        -- 动画
    local spriteFrames = {}
    for i = 0, 3 do 
        local spriteFrame = self.spriteFrameCache_ :getSpriteFrame("loading_fire_000" .. i .. ".png")
        table.insert(spriteFrames, spriteFrame)
    end
    local animation = cc.Animation:createWithSpriteFrames(spriteFrames, 0.1)
    local animate = cc.Animate:create(animation)
    local rep = cc.RepeatForever:create(animate)
    self.ball_:runAction(rep)
end

--解析多国语言
function SceneProgress:parseLanguage()
   --解析language文档
    local strPath = cc.FileUtils:getInstance():fullPathForFilename("language/conf_lang.txt")
    --print(strPath)
    local f = io.open(strPath, "r")
    local str = f:read("*a")
    f:close()

    str = string.sub(str, 4)
    --print(str)

    local str1  = prefix .. str .. suffix
    --print(str1)
    local loadLanguageFunc = loadstring(str1)
    loadLanguageFunc()
end

function SceneProgress:onEnter()
    --1.添加背景
    self:addBgSources()
    --2.添加进度条
    self:addProgressTimer()
    --3.解析多国语言
    self:parseLanguage()
    --4.启动定时器解析xml，并设置进度条
    self.idx_ = 1
    self.timerEntry_ = self.scheduler_:scheduleScriptFunc(handler(self, self.loadXML), 0, false)
  
end

function SceneProgress:onExit()
end

--加载XML
function SceneProgress:loadXML()
    --获取xml文件
    local path = xmlPaths[self.idx_]     
    --获取key
    local tableKey = string.sub(path, 5, -5);
    --解析XML
    parseXML(path, tableKey)
    --根据key获取子表
    local t = cc.GameArgs[tableKey]
    --遍历子表
    for _, subT in pairs(t) do
        if(type(subT) == "table") then 
            for key, value in pairs(subT) do
                if type(value) == "string" then
                    local func = loadstring(value)
                    --print(value)
                    --if fun ~= nil then
                        subT[key] = func()
                    --end
                end
            end
        end
    end

    --设置进度条
    local percent = self.idx_/#xmlPaths
    self.progressTimer_:setPercentage(percent * 100)

    self.ball_:setPosition(cc.p(percent*self.barSize_.width, self.barSize_.height/2+3))

    if self.idx_ == #xmlPaths then 
        -- 停止定时器
        self.scheduler_:unscheduleScriptEntry(self.timerEntry_)
--[[
        for key, value in pairs(cc.GameArgs.ModelConfig) do
            print(key)
        end
]]--        
        self.app_:enterScene("SceneGame")
        return 
    end
    self.idx_ = self.idx_ + 1
end

return SceneProgress

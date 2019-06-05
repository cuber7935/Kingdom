
cc.GameUtil = cc.GameUtil or {}

local spriteFrameCache = cc.SpriteFrameCache:getInstance()
local animationCache = cc.AnimationCache:getInstance()
local director = cc.Director:getInstance()

--加载动画
cc.GameUtil.loadAnimations = function (plistFile, aniName, roleId, delay)
    spriteFrameCache:addSpriteFrames(plistFile)  --加载精灵帧
    local ani = animationCache:getAnimation(plistFile)
   
    if ani then
        return ani
    end

    delay = delay or 0

    local spriteFrames = {}
    local idx = 0
    while true do 
        local spriteFrameName = string.format("%d_%s_000%d.png",roleId, aniName, idx) 
        local frame = spriteFrameCache:getSpriteFrame(spriteFrameName) 
        if frame == nil then
            break
        end
        table.insert(spriteFrames, frame)
        idx = idx + 1
        if idx == 8 then
            break
        end
    end

    ani = cc.Animation:createWithSpriteFrames(spriteFrames, delay)
    animationCache:addAnimation(ani, plistFile)
   
    return ani
end

--启动定时器
cc.GameUtil.startTimer = function(callback, dt)
    return director:getScheduler():scheduleScriptFunc(callback, dt, false)
end

--关闭定时器
cc.GameUtil.killTimer = function(entry)
    director:getScheduler():unscheduleScriptEntry(entry)
end

--判断文件不存在
cc.GameUtil.file_exists = function(path)
    local file = io.open(path, "rb")
    if file ~= nil then
        file:close() 
        return true
    end
    return false
end

--执行动画
cc.GameUtil.getAnimation = function(plist, formatf, startIdx, delay)
    local ani = animationCache:getAnimation(plist)  --加载plist文件
    if ani then return ani end            --若存在则返回动画

    spriteFrameCache:addSpriteFrames(plist)  --加载精灵帧

    delay = delay or 0

    local spriteFrames = {}
    local idx = startIdx
    while true do 
        local spriteFrameName = string.format(formatf, idx) 
        local frame = spriteFrameCache:getSpriteFrame(spriteFrameName)  
        if frame == nil then break end
        
        table.insert(spriteFrames, frame)
        idx = idx + 1
    end

    ani = cc.Animation:createWithSpriteFrames(spriteFrames, delay)
    animationCache:addAnimation(ani, plist)
   
    return ani
end
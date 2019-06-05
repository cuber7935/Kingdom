
cc.GameUtil = cc.GameUtil or {}

local spriteFrameCache = cc.SpriteFrameCache:getInstance()
local animationCache = cc.AnimationCache:getInstance()
local director = cc.Director:getInstance()

--���ض���
cc.GameUtil.loadAnimations = function (plistFile, aniName, roleId, delay)
    spriteFrameCache:addSpriteFrames(plistFile)  --���ؾ���֡
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

--������ʱ��
cc.GameUtil.startTimer = function(callback, dt)
    return director:getScheduler():scheduleScriptFunc(callback, dt, false)
end

--�رն�ʱ��
cc.GameUtil.killTimer = function(entry)
    director:getScheduler():unscheduleScriptEntry(entry)
end

--�ж��ļ�������
cc.GameUtil.file_exists = function(path)
    local file = io.open(path, "rb")
    if file ~= nil then
        file:close() 
        return true
    end
    return false
end

--ִ�ж���
cc.GameUtil.getAnimation = function(plist, formatf, startIdx, delay)
    local ani = animationCache:getAnimation(plist)  --����plist�ļ�
    if ani then return ani end            --�������򷵻ض���

    spriteFrameCache:addSpriteFrames(plist)  --���ؾ���֡

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
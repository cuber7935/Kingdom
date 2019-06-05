--阵型
local LayerFormation = class("LayerFormation", cc.load("mvc").ViewBase)

function LayerFormation:ctor(data)
    --保存阵型相关数据
    self.formation_ ={}

    --存放创建好的NPC
    self.npcData_ = data

    --场景id
    self.ScenesIdx_ = 40000 + cc.GameArgs.sceneIdx+0

    self.hei_ = display.height/8    --高度
    self.col_ = 0                   --列
    self.row_ = 0                   --行

    --阵型类型
    self.types_ = 0

    --阵型速度
    self.speed_ = 0

    --阵型id们
    self.ids_ = nil

    --初始化各种的数据
    self:initData()
end

function LayerFormation:initData()
    self:getFormationInfo()
    self:getConfigInfo()
    self:createFormation()
end

--获取阵型相关数据
function LayerFormation:getFormationInfo()
    local form = string.split(cc.GameArgs.Scenes[self.ScenesIdx_].baseFormationIds, "|")
    local sub = string.split(form[1], "_")
    local sub2 = string.split(form[2], "_")

    for k, v in ipairs(sub) do
        table.insert(self.formation_, v+0)
    end
    for k, v in ipairs(sub2) do
        table.insert(self.formation_, v+0)
    end
end

--获取配置信息
function LayerFormation:getConfigInfo()
    --随机获取id
    local formatIdx = math.random(1, #self.formation_)
    local formatId = self.formation_[formatIdx]

    --根据id，获取阵们的配置信息
    local formConfig = cc.GameArgs.BaseFormation[formatId+0]

    --获取id们
    self.ids_ = formConfig.formation
    --获取速度
    self.speed_ = formConfig.speed
    --获取阵型的名字
    local name = formConfig.name
    --获取阵型的类型
    self.types_ = formConfig.type
end

--根据配置信息创建阵型
function LayerFormation:createFormation()
    local vec = nil
    local idx = 0
    local subIdsCol = string.split(self.ids_, "_0_")
    local index = 0
    for _, v in ipairs(subIdsCol) do
        local subIdsInCol = string.split(v, "_")
      
        for k, v in ipairs(subIdsInCol) do
            if  0 == v+0 or v == nil then
                index = index + 1
                table.remove(subIdsInCol, k)
            end
        end
        print(subIdsInCol, #subIdsInCol)

        if self.types_ == 1 then
            vec = cc.p(1, 0)
            self:createFormationNpc(subIdsInCol, vec)
            idx = idx + 1
        else
            vec = cc.p(-1, 0)
            self:createFormationNpc(subIdsInCol, vec)
            idx = idx + 1
        end
    end 
    print(idx)
    print("index=", index)
end

--创建阵型npc
function LayerFormation:createFormationNpc(subIdsInCol, vec)
    if #subIdsInCol == 1 then
        self:createNpcByNum(subIdsInCol, vec, 1)
    elseif #subIdsInCol == 2 then
        self:createNpcByNum(subIdsInCol, vec, 2)
    elseif #subIdsInCol == 3 then
        self:createNpcByNum(subIdsInCol, vec, 3)
    elseif #subIdsInCol == 4 then
        self:createNpcByNum(subIdsInCol, vec, 4) 
    elseif #subIdsInCol == 5 then
        self:createNpcByNum(subIdsInCol, vec, 5)
    elseif #subIdsInCol == 8 then
       self:createNpcByNum(subIdsInCol, vec, 8)
    else
        print("*****++++#####",#subIdsInCol)
    end
end

--根据每一排id个数创建npc
function LayerFormation:createNpcByNum(subIdsInCol, vec, num)
    for _, v in ipairs(subIdsInCol) do
        self:createNpc(v, self.speed_, vec, num)
    end
end

function LayerFormation:createNpc(id, spd, vec, num)
    local npc = require("app.views.NPC"):create(id+0)
    self:addChild(npc)
    npc.speed_ = spd
    table.insert(self.npcData_, npc)

    --设置npc x的位置
    self:setPtXByVec(npc, vec)

    --设置npc y的位置
    self:setPtYByNum(npc, num)
end

--通过vec设置npc阵，移动方向
function LayerFormation:setPtXByVec(npc, vec)
    if vec.x == 1 then     --从左往右
        npc:setMoveVec(vec)
        npc:setPositionX(-200)
        npc:setPositionX(npc:getPositionX() - 50 * self.col_)
    else
        npc:setMoveVec(vec)
        npc:setPositionX(display.width-200)
        npc:setPositionX(npc:getPositionX() + 50 * self.col_)
    end

    --防止npc跑一半没了
    npc.maxMoveDistance_ =  npc.maxMoveDistance_ + 50 * self.col_
    self.col_ = self.col_ + 1
end

--根据列，换行
function LayerFormation:lineWrapByColumn(num)
    if self.row_ == num then
        self.col_ = self.col_+ 1
        self.row_ = 0
    end
end

--根据id格式，设置npc y方向的位置
function LayerFormation:setPtYByNum(npc, num)
    if num == 1 then
        npc:setPositionY(display.cy/2)
        self.col_ = self.col_+ 1
        self:lineWrapByColumn(num)
    elseif num == 2 then
        npc:setPositionY(self.hei_*self.row_+50)
        self.row_ = self.row_+1
        self:lineWrapByColumn(num)
    elseif num == 3 then
        npc:setPositionY(self.hei_* self.row_+50)
        self.row_ = self.row_+1
        self:lineWrapByColumn(num)
    elseif num == 4 then
        npc:setPositionY(self.hei_* self.row_+20)
        self.row_ = self.row_+1
        self:lineWrapByColumn(num)
    elseif num == 5 then
        npc:setPositionY(self.hei_* self.row_/1.5)
        self.row_ = self.row_+1
        self:lineWrapByColumn(num)
    elseif num == 8 then
        npc:setPositionY(self.hei_* self.row_/1.8)
        self.row_ = self.row_+1
        self:lineWrapByColumn(num)
    else
        print("not found")
    end
end

return LayerFormation

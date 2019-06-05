
local SceneSelectMap = class("SceneSelectMap", cc.load("mvc").ViewBase)

--存放格子
local cells ={}
local cellNames = {}

function SceneSelectMap:onCreate()
    self:showScene()
end


function SceneSelectMap:showScene()
    --创建tableview
    local tableView = cc.TableView:create(display.size)
    --设置滚动方向  SCROLLVIEW_DIRECTION_VERTICAL是垂直滚动   SCROLLVIEW_DIRECTION_HORIZONTAL 是水平滚动
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)    
    tableView:setPosition(display.size)
    --设置代理
    tableView:setDelegate()
    self:addChild(tableView)

    for i=1, 6 do
        local name = string.format("ui/chapter/miniMaps/mini_4000%d.png", i)
        cellNames[i] = name
    end

    --列表项的尺寸  
    tableView:registerScriptHandler( handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX);
    --创建列表项  
    tableView:registerScriptHandler( handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX);
    --列表项的数量  
    tableView:registerScriptHandler( handler(self, self.numberOfCellsInTableView),
        cc.NUMBER_OF_CELLS_IN_TABLEVIEW); 
    --触摸列表项cell的回调
    tableView:registerScriptHandler( handler(self, self.tableCellTouched), cc.TABLECELL_TOUCHED); 
    
    --加载tableView的所有列表数据
    tableView:reloadData();  
end

--子视图大小 view是tableview,idx是每个子项的索引
function SceneSelectMap:cellSizeForTable(view, idx)
    return display.center.x, display.center.y
end

--子视图数目  返回的个数是tableview的高度/单个子项的高度+1
function SceneSelectMap:numberOfCellsInTableView(view)
    return 6
end

--获取子视图
function SceneSelectMap:tableCellAtIndex(view, idx)
    local index = idx +1
    if nil == cells[index] then
        local cell = cc.TableViewCell:create()
        cells[index] = cell   
        cc.Sprite:create(cellNames[index]):move(display.center):addTo(cell)
        return cell
    end
    return cells[index]
end

function SceneSelectMap:tableCellTouched(view, cell)
    cc.GameArgs.sceneIdx = cell:getIdx()+1
    --切换场景
    self.app_:enterScene("SceneProgress")
end

return SceneSelectMap

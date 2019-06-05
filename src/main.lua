
cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "cocos.init"
require "GameUtil"

local function main()
    cc.GameArgs={}
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end

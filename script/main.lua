package.path = "script/?.lua;"..package.path

local base = require "base"
print("hello")



-- print("external:"..EXTERNAL(0,"test.lua"))

-- print("external:"..EXTERNAL(4, "GET", "www.baidufdsf.com"))

-- M.httpReq(method, host, path, param, cb)
base.Time(2, 2000, 1, function(tid)
    print("time out:"..tid)
end
)
-- base.httpReq("GET", "www.baidu.com", "", "", function(msg)
--     print(msg)
-- end
-- )
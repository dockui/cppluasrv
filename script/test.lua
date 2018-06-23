package.path = "script/?.lua;"..package.path
package.cpath = "luaclib/?.so;"..package.cpath

local base = require "base"
local cjson = require "cjson"

local sampleJson = [[
    {
        "file":"run test.lua"
    }
]];
local data = cjson.decode(sampleJson);
print(data["file"]);

-- print("external:"..EXTERNAL(0,"test.lua"))

-- print("external:"..EXTERNAL(4, "GET", "www.baidufdsf.com"))
-- local tcnt = 1
-- M.httpReq(method, host, path, param, cb)
-- base.Time(2, 5000, 0, function(tid)
--     tcnt = tcnt + 1

--     print("time out:"..tid..";cnt:"..tcnt)
    
-- end
-- )

--base.CreateLvm("script/test.lua")
-- base.httpReq("GET", "www.baidu.com", "", "", function(msg)
--     print(msg)
-- end
-- )
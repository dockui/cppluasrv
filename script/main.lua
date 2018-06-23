package.path = "script/?.lua;"..package.path
package.cpath = "luaclib/?.so;"..package.cpath

local CMD = require "cmd"
local base = require "base"


-- print("external:"..EXTERNAL(0,"test.lua"))

-- print("external:"..EXTERNAL(4, "GET", "www.baidufdsf.com"))
local tcnt = 1
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

base.RegCmdCB(CMD.LVM_CMD_CLIENT_MSG, function(wid, msg)
    print("LVM_CMD_CLIENT_MSG:"..wid..";msg:"..msg)
    local backMsg = "from server:"..msg
    base.SendToClient(wid, backMsg, #backMsg)
end)

base.RegCmdCB(CMD.LVM_CMD_CLIENT_CONN, function(wid, msg)
    print("LVM_CMD_CLIENT_CONN:"..wid)
   
end)

base.RegCmdCB(CMD.LVM_CMD_CLIENT_DISCONN, function(wid, msg)
    print("LVM_CMD_CLIENT_DISCONN:"..wid)
   
end)

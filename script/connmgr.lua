local CMD = require "cmd"
local BASE = require "base"
local log = require "log"
local json = require "json"

local ConnMgr = class("connmgr")
function ConnMgr:ctor(obj,data)
    log.info("ConnMgr:ctor()")
    if self.init then self:init(data) end
end
function ConnMgr:init(data)
    log.info("ConnMgr:init()")


    BASE.RegCmdCB(CMD.LVM_CMD_CLIENT_CONN, function(wid, msg)
        print("LVM_CMD_CLIENT_CONN:"..wid)
    end)
    
    BASE.RegCmdCB(CMD.LVM_CMD_CLIENT_DISCONN, function(wid, msg)
        print("LVM_CMD_CLIENT_DISCONN:"..wid)
    end)

end
function ConnMgr:print()
end

return ConnMgr
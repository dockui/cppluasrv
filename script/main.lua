package.path = "script/?.lua;script/utils/?.lua;script/common/?.lua;"..package.path
package.cpath = "luaclib/?.so;"..package.cpath

local CMD = require "cmd"
local BASE = require "base"

local log = require "log"
local json = require "json"
require "functions"

local connmgr = require "connmgr"


local Main = class("Main")

function Main:ctor(obj,data)
    log.info("Main:ctor()")
    if self.init then self:init(data) end
end
function Main:init(data)
    log.info("Main:init()")

    self.connMgr = connmgr:new()

    BASE.RegCmdCB(CMD.LVM_CMD_CLIENT_MSG, handler(self, self.OnMessage))
end

function Main:OnMessage(wid, msg)
    print("LVM_CMD_CLIENT_MSG:"..wid..";msg:"..msg)
    local backMsg = "from server:"..msg
    if msg == "quit" then
        base.CloseClient(wid)
        return
    end

    BASE.SendToClient(wid, backMsg, #backMsg)
end

AppMain = Main:new("main")



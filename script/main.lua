package.path = "script/?.lua;script/utils/?.lua;script/common/?.lua;"..package.path
package.cpath = "luaclib/?.so;"..package.cpath

-- package.path = "/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/lualibs/mobdebug/?.lua;"..package.path
-- package.path = "/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/lualibs/?.lua;"..package.path
-- package.cpath = "/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/bin/clibs53/?.dylib;"..package.cpath
-- package.cpath = "/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/bin/clibs53/?/?.dylib;"..package.cpath
-- require("mobdebug").start()

local CMD = require "cmd"
local BASE = require "base"

local log = require "log"
local json = require "json"
require "functions"

local connmgr = require "connmgr"
local roommgr = require "roommgr"


local Main = class("Main")

function Main:ctor(obj,data)
    log.info("Main:ctor()")
    if self.init then self:init(data) end
end
function Main:init(data)
    log.info("Main:init()")

    self.loginServerId = BASE.CreateLvm("script/m_login.lua")
    self.roomMgr = roommgr:new()

    self.connMgr = connmgr:new({
        loginServerId=self.loginServerId,
        roomMgr = self.roomMgr
        }
    )


end


AppMain = Main:new("main")



package.path = "script/game/?.lua;script/?.lua;script/utils/?.lua;script/common/?.lua;"..package.path
package.cpath = "luaclib/?.so;"..package.cpath
--/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/lualibs/mobdebug
--/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/bin/clibs53
package.path = "/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/lualibs/mobdebug/?.lua;"..package.path
package.path = "/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/lualibs/?.lua;"..package.path
package.cpath = "/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/bin/clibs53/?.dylib;"..package.cpath
package.cpath = "/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/bin/clibs53/?/?.dylib;"..package.cpath
require("mobdebug").start()

require "functions"
local CMD = require "cmd"
local BASE = require "base"
local log = require "log"
local json = require "json"

local mjlib = require "cs.mjlib"

local Room = class("Room")
function Room:ctor(obj,data)
    log.info("Room:ctor()")
    if self.init then self:init(data) end
end
function Room:init(data)
    log.info("Room:init()")
    self.lst_user = {}

    BASE.RegCmdCB(CMD.REQ_ENTERTABLE, handler(self, self.OnEnterTable))
end

function Room:GetUser(uid)
    for i, v in ipairs(self.lst_user) do
        if v.uid == uid then
            return v
        end
    end
    return nil
end

function Room:OnEnterTable(msg)
    log.info("Room:OnEnterTable() "..msg)
    local msg = json.decode(msg)
    local userinfo = self:GetUser(msg.uid)
    if userinfo then
        userinfo.fid = msg.fid
    else
        self.lst_user[#self.lst_user+1] = msg
        if #self.lst_user == 1 then
            msg.zhu = 1
            msg.zhuang = 1
        end
    end

    self:StartGame()
end

function Room:StartGame()

    self.cardsAll = mjlib.create()
    local num_tbl = mjlib.getNumTable(self.cardsAll)
    log.info(mjlib.getNumTableStr(num_tbl))
end


objRoom = Room:new()
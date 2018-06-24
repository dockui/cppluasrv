package.path = "script/?.lua;script/utils/?.lua;script/common/?.lua;"..package.path
package.cpath = "luaclib/?.so;"..package.cpath

require "functions"
local CMD = require "cmd"
local BASE = require "base"
local log = require "log"
local json = require "json"
local ECODE = require "errorcode"


local Login = class("Login")
function Login:ctor(obj,data)
    log.info("Login:ctor()")
    if self.init then self:init(data) end
end
function Login:init(data)
    log.info("Login:init()")

    BASE.RegCmdCB(CMD.REQ_LOGIN, handler(self, self.OnLogin))

end
function Login:OnLogin(msg, fid, sid)
    log.info("Login:OnLogin:")

    local T_USER = {
        zhaosan = 1,
        lisi = 2,
        wangwu = 3,
        zhaoliu = 4
    }
    local msg = json.decode(msg)

    local username = msg.data.username
    local uid = T_USER[username]
    local ret 
    if uid ~= nil then
        ret = {
            cmd = CMD.RES_LOGIN,
            error = 0,
            data = {
                uid = uid
            }
        }
    else
        ret = {
            cmd = CMD.RES_LOGIN,
            error = ECODE.ERR_NOT_EXIST_USER,
            data = "user not found"
        }
    end
    BASE.RetMessage(fid, json.encode(ret), sid)
end


objLogin = Login:new()
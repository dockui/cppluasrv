local CMD = require "cmd"
local log = require "log"

local TS = {
    SESSION_ID = 0,
    SessionCB={},
    TIMER_CB={},
    REG_CMD_CB={},
    MSG_CB=nil,
}

function TS.NewSID()
    TS.SESSION_ID = 0
    repeat  
        TS.SESSION_ID = TS.SESSION_ID + 1
        if TS.SessionCB[TS.SESSION_ID] == nil then
            return TS.SESSION_ID
        end
    until (false)
    -- error
end

function TS.Reg(sid, cb)  
    TS.SessionCB[sid] = cb
end

function TS.RegTM(tid, once, cb)  
    TS.TIMER_CB[tid] = {cb=cb, once=once}
end
function TS.UnRegTM(tid)
    TS.TIMER_CB[tid] = nil
end

function TS.RegCmdCB(cmd, cb)  
    TS.REG_CMD_CB[cmd] = cb
end
function TS.UnCmdCB(cmd)
    TS.REG_CMD_CB[cmd] = nil
end

function TS.Dispatch(cmd, msg, fid, sid)  
    local cb = TS.SessionCB[sid]
    if cb then
        cb(msg, fid, sid)
        TS.SessionCB[sid] = nil
    elseif TS.MSG_CB then
         TS.MSG_CB(cmd, msg, fid, sid)
    end
end

function TS.DPTM(tid)  
    log.info("TS.DPTM:"..tid)
    local dt = TS.TIMER_CB[tid]
    if dt and dt.cb then
        dt.cb(tid)
        if dt.once ~= 0 then
            TS.TIMER_CB[tid] = nil
        end
    end
end

local M = {
}

function M.Dispatch(fid, sid, cmd, msg)  
    local cmd_cb = TS.REG_CMD_CB[cmd]
    if cmd_cb then
        cmd_cb(msg, fid, sid)
        return
    end

    if cmd == CMD.LVM_CMD_ONTIMER then
        -- local tid = (string.unpack("i",msg))
        TS.DPTM(sid)
    else 
        TS.Dispatch(cmd, msg, fid, sid)        
    end
end

function M.Time(tid, elapse, once, cb) 
    log.info("M.Time:"..tid)
    TS.RegTM(tid, once, cb)
    EXTERNAL(CMD.LVM_CMD_SETTIMER, 0, tid, elapse, once)
    return true
end

function M.KillTime(tid) 
    log.info("M.KillTime:"..tid)
    TS.UnRegTM(tid)
    EXTERNAL(CMD.LVM_CMD_KILLTIMER, 0, tid)
    return true
end

function Dispatch(fid, sid, cmd, msg)  
    -- local m = (string.unpack("i",msg))
    log.info("dispatch fid="..fid..";sid="..sid.. ";cmd="..cmd..";msg="..(msg or ""))
    return M.Dispatch(fid, sid, cmd, msg)
end

function M.RegCmdCB(cmd, cb)
    TS.RegCmdCB(cmd, cb)
end

function M.RegMsgCB(cb)
    TS.MSG_CB = cb
end

--method, host, path, param
function M.HttpReq(method, host, path, param, cb)

    local sid = TS.NewSID()  
    TS.Reg(sid, cb)
    
    EXTERNAL(CMD.LVM_CMD_HTTP_REQ, sid, method, host, path, param)
    return true
end


function M.CreateLvm(file)   
    log.info("CreateLvm beg:"..file)
    local id = EXTERNAL(CMD.LVM_CMD_CREATLVM, 0, file)
    log.info("CreateLvm end:"..file.."; id:"..id)
    return id
end

function M.DelLvm(vid)   
    log.info("LVM_CMD_DELLVM beg:"..vid)
    local ret = EXTERNAL(CMD.LVM_CMD_CREATLVM, 0, vid)
    return ret
end


function M.SendToClient(wid, msg, len)   
    log.info("SendToClient beg:"..wid..", msg:"..msg..";len:"..len)
    EXTERNAL(CMD.LVM_CMD_CLIENT_MSG_BACK, 0, wid, msg, len)
end

function M.CloseClient(wid)   
    log.info("CloseClient beg:"..wid)
    EXTERNAL(CMD.LVM_CMD_CLIENT_CLOSE, 0, wid)
end

-- CMD.LVM_CMD_MSG
function M.PostMessage(dest, cmd, msg, cb)  
    local sid = 0
    if cb then
        sid = TS.NewSID()  
        TS.Reg(sid, cb)
    end
    EXTERNAL(CMD.LVM_CMD_MSG, sid, cmd, dest, msg, #msg)
end

-- CMD.LVM_CMD_MSG_RET
function M.RetMessage(dest, msg, sid)  
    sid = sid or 0
    EXTERNAL(CMD.LVM_CMD_MSG_RET, sid, CMD.LVM_CMD_MSG_RET, dest, msg, #msg)
end

return M
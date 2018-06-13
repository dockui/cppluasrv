local CMD = require "cmd"

local TS = {
    SESSION_ID = 0,
    C={},
    TM={},
    RC={}
}

function TS.NewSID()
    repeat
        if TS.SESSION_ID >= 0xFFFFFFFF then
            TS.SESSION_ID = 0
        end     
        TS.SESSION_ID = TS.SESSION_ID + 1
        if TS.C[TS.SESSION_ID] == nil then
            return TS.SESSION_ID
        end
    until (false)
    -- error
end

function TS.Reg(sid, cb)  
    TS.C[sid] = cb
end

function TS.RegTM(tid, once, cb)  
    TS.TM[tid] = {cb=cb, once=once}
end
function TS.UnRegTM(tid)
    TS.TM[tid] = nil
end

function TS.RegCmdCB(cmd, cb)  
    TS.RC[cmd] = cb
end
function TS.UnCmdCB(cmd)
    TS.RC[cmd] = nil
end

function TS.DP(sid, msg)  
    local cb = TS.C[sid]
    if cb then
        cb(msg)
        TS.C[sid] = nil
    end
end

function TS.DPTM(tid)  
    print("TS.DPTM:"..tid)
    local dt = TS.TM[tid]
    if dt and dt.cb then
        dt.cb(tid)
        if dt.once ~= 0 then
            TS.TM[tid] = nil
        end
    end
end

local M = {
}

function M.DP(sid, cmd, msg)  
    local cmd_cb = TS.RC[cmd]
    if cmd_cb then
        cmd_cb(sid, msg)
        return
    end

    if cmd == CMD.LVM_CMD_ONTIMER then
        local tid = (string.unpack("i",msg))
        TS.DPTM(tid)
    else 
        TS.DP(sid, msg)        
    end
end

function M.Time(tid, elapse, once, cb) 
    print("M.Time:"..tid)
    TS.RegTM(tid, once, cb)
    EXTERNAL(CMD.LVM_CMD_SETTIMER, 0, tid, elapse, once)
    return true
end

function M.KillTime(tid) 
    print("M.KillTime:"..tid)
    TS.UnRegTM(tid)
    EXTERNAL(CMD.LVM_CMD_KILLTIMER, 0, tid)
    return true
end

function DP(sid, cmd, msg)  
    -- local m = (string.unpack("i",msg))
    print("dispatch sid=",sid, "cmd=", cmd, ";msg=", msg)
    M.DP(sid, cmd, msg)
end

function M.RegCmdCB(cmd, cb)
    TS.RegCmdCB(cmd, cb)
end

--method, host, path, param
function M.HttpReq(method, host, path, param, cb)

    local sid = TS.NewSID()  
    TS.Reg(sid, cb)
    
    EXTERNAL(CMD.LVM_CMD_HTTP_REQ, sid, method, host, path, param)
    return true
end

function M.CreateLvm(file)   
    print("CreateLvm beg:"..file)
    local id = EXTERNAL(CMD.LVM_CMD_CREATLVM, 0, file)
    print("CreateLvm end:"..file.."; id:"..id)
    return id
end

function M.SendToClient(sid, msg, len)   
    print("SendToClient beg:"..sid..", msg:"..msg..";len:"..len)
    EXTERNAL(CMD.LVM_CMD_CLIENT_MSG_BACK, 0, sid, msg, len)
end


return M
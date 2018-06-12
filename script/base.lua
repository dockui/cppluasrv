local CMD = require "cmd"

local TS = {
    SESSION_ID = 0,
    C={},
    TM={}
}

function TS.NewSID()  
    if TS.SESSION_ID >= 0xFFFFFFFF then
        TS.SESSION_ID = 0
        TS.C = {}
    end
    TS.SESSION_ID = TS.SESSION_ID + 1
    return TS.SESSION_ID
end

function TS.Reg(sid, cb)  
    TS.C[sid] = cb
end

function TS.RegTM(tid, cb)  
    TS.TM[tid] = cb
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
    local cb = TS.TM[tid]
    if cb then
        cb(tid)
        TS.TM[tid] = nil
    end
end

local M = {
    TM=nil,
}
function M.DP(sid, cmd, msg)  
    if cmd == CMD.LVM_CMD_ONTIMER then
        local tid = (string.unpack("i",msg))
        TS.DPTM(tid)
    else 
        TS.DP(sid, msg)        
    end
end

function M.Time(tid, elapse, once, cb) 
    print("M.Time:"..tid)
    TS.RegTM(tid, cb)
    EXTERNAL(CMD.LVM_CMD_SETTIMER, 0, tid, elapse, once)
    return true
end

function DP(sid, cmd, msg)  
    -- local m = (string.unpack("i",msg))
    print("dispatch sid=",sid, "cmd=", cmd, ";msg=", msg)
    M.DP(sid, cmd, msg)
end



--method, host, path, param
function M.httpReq(method, host, path, param, cb)

    local sid = TS.NewSID()  
    TS.Reg(sid, cb)
    
    EXTERNAL(CMD.LVM_CMD_HTTP_REQ, sid, method, host, path, param)
    return true
end

return M
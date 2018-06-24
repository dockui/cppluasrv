local CMD = require "cmd"
local ECODE = require "errorcode"
local BASE = require "base"
local log = require "log"
local json = require "json"

local RoomMgr = class("RoomMgr")

function RoomMgr:ctor(obj,data)
    log.info("RoomMgr:ctor()")
    if self.init then self:init(data) end
end
function RoomMgr:init(data)
    log.info("RoomMgr:init()")

    self._list_room = {}
end

function RoomMgr:FindUser(userid)
    for _,v in pairs(self._list_room) do
        for i,u in pairs(v) do
            if u == userid then
                return v
            end
        end
    end
    return nil
end

function RoomMgr:AddUser(roomid, userid)
    
    local room = self:FindUser(userid)
    if room ~= nil then
        return ECODE.CODE_SUCCESS, room.roomid
    end

    local room = self._list_room[roomid]
    if room == nil then
        return ECODE.ERR_NOT_EXIST
    end

    if #room.user >= room.count then
        return ECODE.ERR_ROOM_FULL
    end

    room.user[#room.user + 1] = userid
    return ECODE.CODE_SUCCESS, roomid
end

function RoomMgr:JoinRoom(roomid, fid, uid)
    local roominfo = self._list_room[roomid]
    if nil == roominfo then
        -- (roominfo.lvm_roomid)
        return ECODE.ERR_NOT_EXIST
    end

    BASE.PostMessage(roominfo.lvm_roomid, CMD.REQ_ENTERTABLE, json.encode({
        fid = fid,
        uid = uid
    })) 
end

function RoomMgr:IsExistRoom(roomid)
    return self._list_room[roomid] ~= nil
end

function RoomMgr:RemoveRoom(roomid)
    local roominfo = self._list_room[roomid]
    if roominfo then
        BASE.DelLvm(roominfo.lvm_roomid)
    end
    self._list_room[roomid] = nil
end

function RoomMgr:CreateRoom(vid, count)
    log.info("RoomMgr:CreateRoom()")
    
    local lvm_roomid = BASE.CreateLvm("script/game/room.lua")

    local newid = self:AllocNewId()
    self._list_room[newid] = {
        lvm_roomid = lvm_roomid,
        roomid = newid,
        vid=vid,
        count=count,
        user={}
    }
    return newid
end

function RoomMgr:AllocNewId()
    local ROOM_BEG = 6261234
    repeat  
        ROOM_BEG = ROOM_BEG + 1
        if self._list_room[ROOM_BEG] == nil then
            return ROOM_BEG
        end
    until (false)
    --unreachable
    return ROOM_BEG
end

return RoomMgr
local M = {
    CODE_SUCCESS = 0,
    ERR_NOT_EXIST = 1010,
    ERR_ROOM_FULL = 1020,
    ERR_NOT_EXIST_USER = 1030,
    ERR_VERIFY_FAILURE = 1040,
}
local Desc = {
    CODE_SUCCESS = "success",
    ERR_NOT_EXIST = "not exist",
    ERR_ROOM_FULL = "room is full",
    ERR_NOT_EXIST_USER = "user not exist",
    ERR_VERIFY_FAILURE = "user verify failure",  
}
function M.ErrDesc(code)
    return Desc[code] or "not found"
end
return M
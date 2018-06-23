
local log = require "log"
local json = require "json"
require "functions"

local Test = class("Test")
function Test:ctor(obj,data)
    log.info("Test:ctor()")
    if self.init then self:init(data) end
end
function Test:init(data)
    log.info("Test:init()")
end
function Test:print()
    print(json.encode({start="print"}))
end

local Sub = class("Sub", Test)
function Sub:init(data)
    log.info("Sub:init()")
end
-- function Sub:print()
--     print(json.encode({start=" Subprint"}))
-- end

local obj = Test:new("dt")
obj:print()
local obj_sub = Sub:new("dt")
obj_sub:print()

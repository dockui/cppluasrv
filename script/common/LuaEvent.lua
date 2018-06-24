
local LuaEvent = class("LuaEvent")

local m_instance = nil

function LuaEvent.getInstance()
    if m_instance == nil then
        m_instance = LuaEvent:new()
    end
    return m_instance
end
function LuaEvent:ctor()
	self.m_events = {}
    self.m_cmds = {}
end


-- 派发事件
-- eventName：事件名
-- obj：参数，可缺省
-- atOnce：是否立即执行，否则下一帧执行。。缺省为立即执行
function LuaEvent:dispatchEvent(eventName, obj, notOnce)
    if notOnce then
        table.insert(self.m_cmds, {eventName, obj})
    else
         local funcs = self.m_events[eventName]
        if funcs then
            local func
            for i, v in ipairs(funcs) do
                func = handler(v[1], v[2])
                func(obj)
            end
        end
    end
end

-- 添加事件监听
function LuaEvent:addEventListener(eventName, obj, func)
    if obj == nil or func == nil then
        print(debug.traceback())
        os.execute("pause")
    end

    local funcs = self.m_events[eventName]
    if not funcs then
        funcs = {}
        self.m_events[eventName] = funcs
    end

    table.insert(funcs, {obj, func})
end

-- 删除事件监听
function LuaEvent:removeEventListener(eventName, obj, func)
    local funcs = self.m_events[eventName]
    for i,v in ipairs(funcs) do
        if v[1] == obj and v[2] == func then
            table.remove(funcs, i)
            break
        end
    end
end

function LuaEvent:update()
    if #self.m_cmds > 0 then
        local cmd = table.remove(self.m_cmds, 1)
        self:dispatchEvent(cmd[1], cmd[2])
    end
end

function LuaEvent:release()

end

return LuaEvent.getInstance()

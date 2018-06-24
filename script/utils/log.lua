#!/usr/bin/lua

-- level 打印等级，4是开启所有打印，0是关闭所有打印
-- output 打印输出位置，stdout(标准输出)，file(输出到文件)
-- path 日志输出路径
-- package.loaded["log"] = log, require "log"返回module名log

local M = {
    level = 4, 
    output = "NAT", 
    path = "./log"
}

log = M

function M.configure(level, output, path)
    if level ~= nil then M.level = level end
    if output ~= nil then M.output = output end
    if path ~= nil then M.path = path end
end

function M.debug(fmt, ...)
    if (M.level >= 4) then
        M.generalPrint(1, fmt, ...)
    end
end

function M.info(fmt, ...)
    if (M.level >= 3) then
        M.generalPrint(2, fmt, ...)
    end
end

function M.warn(fmt, ...)
    if (M.level >= 2) then
        M.generalPrint(3, fmt, ...)
    end
end

function M.error(fmt, ...)
    if (M.level >= 1) then
        M.generalPrint(4, fmt, ...)
    end
end

function M.generalPrint(level, fmt, ...)
    if (level >= 0) and (level <= 4) then
        if (select("#", ...) > 0) then 
            local t = {}
            for i=1, select("#", ...) do
                t[i] = tostring(select(i, ...))
            end
            s = string.format(fmt, unpack(t))
        else
            s = fmt
        end
        
        local line = debug.getinfo(3).currentline 
        local file = string.gsub(debug.getinfo(3).short_src, ".+/", "") 
        local func = debug.getinfo(3).name or "G_FUN"
        local timenow = os.date("%Y-%m-%d %H:%M:%S")
        local str    

        str = string.format("[LUA] %s =>[%s(line:%s){%s}",
            tostring(s), tostring(file), tostring(line), tostring(func))
    
        if log.output == "NAT" then
            EXTERNAL(150, 0, level, str, #str)
        elseif log.output == "file" then
            local f = assert(io.open(log.path, 'a+'))
            f:write(str)
            f:close()
        elseif log.output == "stdout" then
            print(str)
        end
    end
end

return log
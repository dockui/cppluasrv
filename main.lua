

function DP(cmd,msg)  
    local m = (string.unpack("i",msg))
    print("dispatch cmd=", cmd, ";msg=", m)
end

-- print("external:"..EXTERNAL(0,"test.lua"))

print("external:"..EXTERNAL(4, "GET", "www.baidufdsf.com"))

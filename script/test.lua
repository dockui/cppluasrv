package.path = "script/?.lua;"..package.path
package.cpath = "luaclib/?.so;"..package.cpath

local base = require "base"
local cjson = require "cjson"

local sampleJson = [[
    {
        "file":"run test.lua"
    }
]];
local data = cjson.decode(sampleJson);
print(data["file"]);


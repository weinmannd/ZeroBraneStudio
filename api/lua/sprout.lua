-- Read sprout.json, transform it to json format and return it

lfs = require('lfs')
json = require('json')

local file = io.open(lfs.currentdir().."/api/lua/sprout.json", "r")
local contents = file:read( "*a" )
local oDocumentation = json.decode(contents)
io.close(file)

return oDocumentation
local Unbroken = require('.').Unbroken
local Server = require('.').Server

local config = require('./config/dnode-alt')


for _, branch in pairs(config.branches) do
  local server = Server:new()
  local client = Unbroken:new(config)
  client:build(branch, function(d, done)
    print('[' .. config.name .. '] building branch: ' .. branch)

    d:pipe(server)
    server:pipe(d)
    done()
  end)
end

--[[
-- weird bug, if server isnt reset the
-- client's remote build method is called more
-- than once.
local server = Server:new()
local client = Unbroken:new(config)
client:build('develop', function(d, done)
  d:pipe(server)
  server:pipe(d)
  done()
end)
]]

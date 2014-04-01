local unbroken = require('..') -- require('unbroken')
local Unbroken = unbroken.Unbroken

local DNode = Unbroken:new({
	name = 'dnode',
	url = 'https://github.com/pauldub/luvit-dnode',
	scm = 'git',
  publishers = {
    echo = unbroken.publishers.echo
  }
})

function DNode:onBuild(build, done)
  build:copyFile('database.yml', 'config/datbase.yml')
  build:run('lui')
  build:run('modules/bourbon/bin/bourbon -p test')
  build:run('modules/bourbon/bin/bourbon -p test/server')

  self:done(false, "build passed")
end

local utils = require('utils')
local dnode = require('dnode')
local Server = unbroken.Server

function DNode:testBuild()
  local server = Server:new()

  DNode:build('master', function(client, cb)
    client:pipe(server)
    server:pipe(client)
  end)
end

return DNode


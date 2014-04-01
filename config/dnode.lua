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
  -- project:copyFile('database.yml', 'config/datbase.yml')
  build:run('lui')
  build:run('modules/bourbon/bin/bourbon -p test')
  build:run('modules/bourbon/bin/bourbon -p test/server')

  done(false, "build passed")
end

return DNode


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

function DNode:test(project, done)
  -- project:copyFile('database.yml', 'config/datbase.yml')
  project:cmd('lui')
  project:cmd('modules/bourbon/bin/bourbon -p test')
  project:cmd('modules/bourbon/bin/bourbon -p test/server')

  done(false, "build passed")
end

return DNode


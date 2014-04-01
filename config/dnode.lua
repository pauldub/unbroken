local Unbroken = require('..') -- require('unbroken')

local DNode = Unbroken:new({
	name = 'dnode',
	url = 'https://github.com/pauldub/luvit-dnode',
	scm = 'git',
  publish = {
    echo = unbroken.publishers.echo
  }
})

function DNode:test(project, done)
  -- project:copyFile('database.yml', 'config/datbase.yml')
  project:cmd('lui')
  project:cmd('modules/bourbon/bin/bourbon -p test')
  project:cmd('modules/bourbon/bin/bourbon -p test/server')
end

return DNode


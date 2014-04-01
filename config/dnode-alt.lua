local unbroken = require('..')

local utils = require('utils')
local dnode = require('dnode')
local Server = unbroken.Server

local config = {
	name = 'dnode',

	url = 'https://github.com/pauldub/luvit-dnode',
	scm = 'git',

  -- both aren't used yet.
  language = 'luvit',
  branches = {'master'},

  -- I like having publishers on client
  -- side so clients can do whatever 
  -- config they want and server just
  -- don't care.
  --
  -- Maybe we can have remote publishers too?
  -- but would not be that useful to me.
  publishers = {
    echo = unbroken.publishers.echo
  },

  -- Install dependencies of required packages.
  -- 
  -- before install callback, runs in build context
  -- before anything else
  -- code is already checked out.
  beforeInstall = function(self, remote)
    remote:run('apt-get install -y luajit')
    remote:run('apt-get install -y luarocks')

    self:done() 
  end,
  
  -- Install required packages.
  install = function(self, remote)
    remote:run({
      'mkdir bin/',
      'curl http://luvit.io/dist/latest/ubuntu-latest/x86_64/luvit-bundled -o bin/luvit',
      'chmod +x bin/luvit',
      'curl https://github.com/dvv/luvit-lui/raw/master/lui --location -o bin/lui',
      'chmod +x bin/lui',
    })

    self:done() 
  end,

  beforeScript = function(self, remote)
    -- Maybe in that scenario we want to
    -- write remote file content directly? 
    -- So we can use variables setup earlier (test db crendentials, etc.)
    -- or setup by plugins?

    remote:copyFile('database.yml', 'config/datbase.yml')
    remote:run('lui') 

    -- Here I would like to set remote env vars. 
    -- export PATH=$PATH:$PWD/bin
  end,

  script = function(self, remote)
    remote:run('modules/bourbon/bin/bourbon -p test')
    remote:run('modules/bourbon/bin/bourbon -p test/server')

    self:done()
  end,

  -- this will be implemented by bin/unbroken probably
  -- maybe not the connect callback, should it be 
  -- configurable per project, globally or both 
  -- should it be  overridable?
  -- we can call it with like:
  --
  -- local project = Unbroken:new(config)
  -- or 
  -- local project = require('config/dnode-alt.lua')
  -- project.instance.testBuild(project)
  -- 
  -- This because instance is the actual
  -- the client to the server and it is
  -- just my repl helper.
  testBuild = function(self)
    -- Simple local runner ;)
    local server = Server:new()

    self:build('master', function(client, done)
      client:pipe(server)
      server:pipe(client)
      -- not sure this is usefull as 
      -- we bind the 'remote' event
      done()
    end)
  end
}

return unbroken.Unbroken:new(config)

--[[ 

# Travis config for dnode-luvit

branches:
  only:
    - master

before_install:
  - sudo apt-get install luajit
  - sudo apt-get install luarocks

install:
  - mkdir bin/
  - curl http://luvit.io/dist/latest/ubuntu-latest/x86_64/luvit-bundled -o bin/luvit
  - chmod +x bin/luvit
  - curl https://github.com/dvv/luvit-lui/raw/master/lui --location -o bin/lui
  - chmod +x bin/lui

before_script:
  - lui || true

script: 
  - "modules/bourbon/bin/bourbon -p test/"
  - "modules/bourbon/bin/bourbon -p test/server"

]]

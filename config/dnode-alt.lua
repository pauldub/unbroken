local unbroken = require('..')

local config = {
  name = 'dnode',

  url = 'https://github.com/pauldub/luvit-dnode',
  scm = 'git', -- not used

  language = 'luvit',
  branches = {'master', 'develop'}, -- used by run.lua for now

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

  beforeScript = function(remote, done)
    -- Maybe in that scenario we want to
    -- write remote file content directly? 
    -- So we can use variables setup earlier (test db crendentials, etc.)
    -- or setup by plugins?

    remote:copyFile('database.yml', 'config/database.yml')

    done()
  end,

  script = function(remote, done)
    remote:run('modules/bourbon/bin/bourbon -p test')
    remote:run('modules/bourbon/bin/bourbon -p test/server')

    done()
  end,
}

return config

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

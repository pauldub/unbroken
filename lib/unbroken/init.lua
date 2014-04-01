local Object = require('core').Object
local Emitter = require('core').Emitter

local table = require('table')
local utils = require('utils')

local async = require('async')
local dnode = require('dnode')

-- escape commands before running them

local GitRepo = Object:extend()
function GitRepo:initialize(url)
  self.url = url
end

function GitRepo:clone(path)
  self.path = path
  print('git clone ' .. self.url .. ' ' .. path)
end

function GitRepo:checkout(revision)
  if type(self.path) ~= 'string' or path == '' then
    error('this repository doesn\'t have a path.')
  else
    print('cd ' .. self.path .. ' && git checkout ' .. revision)
  end
end

-- TODO: Refactor table class initialization to objects
local Server = { }
function Server:new()
  self = dnode:new(function(d, client)
    return {
      -- Just setup the environment for the build
      -- we can get informations about the project
      -- from the client.
      build = function(reply)
        local build_path = 'test/unb' -- build path, mktemp probably
        local repo = GitRepo:new(client.url)
      
	      -- the clone / checkout part could be refactored
        repo:clone(build_path)

        -- ???
        if revision then
          repo:checkout(revision)
        end
        
        local builder = {
          path = build_path,
          -- executes in build path 
          run = function(self, cmd)
            if type(cmd ) == 'table' then
              cmd = table.concat(cmd, '\n')
            end
            print('execute ' .. 'cd ' .. self.path .. ' && ' .. cmd) 
          end,
          
          -- helper to copy a file from client to server build path  
          -- server grabs file content from the client.
          copyFile = function(self, client_path, path)
            client:readFile(client_path, function(err, content)
              if err then
                error(err)
              end
              print('ok writing ' .. content .. ' to ' .. self.path .. '/' .. path)
            end)
          end
          -- these two could easily be implemented, to run
          -- in docker containers for example ;)
          -- we could 
        }

	      -- pass the builder we just setup to the client
	      -- so he can run commands etc.
	      -- and simply return 	
        -- more callback maybe implemented
        -- (probably the same as for travis-ci)
        local steps = { 
          'beforeInstall',
          'install',
          'beforeScript',
          'script'
        }

        async.forEachSeries(steps, function(current_step, next_step)
          -- create the call back function
          -- so it updates the client instance?
          --
          -- it is a weird use of callbacks, but dnode
          -- makes it possible and I find it funny to
          -- call object methods.
          client.done = function(self, err, res)
            client = self 
            -- print newline right after running ;)
            print()
            -- and then call the iterator with any error
            next_step(err)
          end

          print('[' .. client.name .. '] ' .. current_step)

          local step = client[current_step]
          -- we could also inform client of the failed step?
          -- does he or we handle errors? I think we should,
          -- but maybe client could be notified in some way?
          -- like attach a callback? as with "done"?
          step(client, builder)
        end, reply)
  
      end,
    }
  end)

  return self
end

-- Not ure about the name.
local Unbroken = Emitter:extend() 
function Unbroken:initialize(options)
  self.instance = options
end

function Unbroken:build(revision, connect)
  local instance = self.instance
  -- Create callback so server can read files from config dir
  -- a bit ugly, I like better the fact that functions in config/dnode.lua
  -- are accessible ! :)
  instance.readFile = function(self, path, reply)
    reply(false, 'foo content')
  end

  local client = dnode:new(instance)

  client:on('remote', function(remote)
    remote.build(function(err, result)
      -- call publishers  with the project and the result of the build
      for publisher, handler in pairs(instance.publishers) do
        if type(handler) == 'function' then
          handler(instance, err or result)
        end
      end
    end) 
  end)

  connect(client, function(err)
    if (err) then  
      error(err) 
    end
  end)
end

return { 
  Unbroken = Unbroken,
  GitRepo = GitRepo,
  Server = Server,
  publishers = { echo = function(project, result)
      if result then
        print('[' .. project.name .. '] ' .. result)
      end
    end
  }
}

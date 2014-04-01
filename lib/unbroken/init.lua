local Object = require('core').Object
local Emitter = require('core').Emitter

local utils = require('utils')

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
        local build_path = 'test/unb'
        local repo = GitRepo:new(client.url)
      
        repo:clone(build_path)

        -- ???
        if revision then
          repo:checkout(revision)
        end
        
        local builder = {
          path = build_path,
          -- executes in build path
          run = function(self, cmd)
            print('execute ' .. 'cd ' .. self.path .. ' && ' .. cmd) 
          end,
          
          copyFile = function(self, client_path, path)
            client:readFile(client_path, function(err, content)
              if err then
                error(err)
              end
              print('ok writing ' .. content .. ' to ' .. self.path .. '/' .. path)
            end)
          end
        }

        client:onBuild(builder, function(err, res)
          reply(err, res)
        end)
      end,
    }
  end)
  return self
end



local Unbroken = Emitter:extend() 
function Unbroken:initialize(options)
  self.options = options
  self.url = options.url or error('options.url is missing')
  self.name = options.name or ''
  self.repo = GitRepo:new(options.url) -- well, first we'll use git
  self.publishers = options.publishers or {}
end

function Unbroken:build(revision, connect)
  local self_copy = self
  -- Create callback so server can read files from config dir
  -- a bit ugly, I like better the fact that functions in config/dnode.lua
  -- are accessible ! :)
  self_copy.readFile = function(self, path, reply)
    reply(false, 'foo content')
  end

  local client = dnode:new(self)

  client:on('remote', function(remote)
    remote.build(function(err, result)
      -- call publishers  with the project and the result of the build
      for publisher, handler in pairs(self.publishers) do
        if type(handler) == 'function' then
          handler(self, err or result)
        end
      end
    end) 
  end)

  connect(client, function(err)
    if (err) then  
      error(err) 
    end
    -- build path, mktemp probably
  end)
end

return { 
  Unbroken = Unbroken,
  GitRepo = GitRepo,
  Server = Server,
  publishers = { echo = function(project, result)
      print('[' .. project.name .. '] ' .. result)
    end
  }
}

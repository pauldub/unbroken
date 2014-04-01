local Object = require('core').Object
local Emitter = require('core').Emitter
local utils = require('utils')

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

local Unbroken = Emitter:extend() 
function Unbroken:initialize(options)
  self.options = options
  self.url = options.url or error('options.url is missing')
  self.name = options.name or ''
  self.repo = GitRepo:new(options.url) -- well, first we'll use git
  self.publishers = options.publishers or {}
end

function Unbroken:build(revision)
  -- build path, mktemp probably
  local build_path = 'test/unb'
  local repo = GitRepo:new(self.url)

  -- things interesting to have in order
  -- to test the build that will already be 
  -- checked out.
  local context = {
    repo = repo,
    path = build_path,
    -- executes in build path
    run = function(self, cmd)
      print('execute ' .. 'cd ' .. build_path .. ' && ' .. cmd .. ' at ' .. revision)
    end 
  }

  repo:clone('test/unb')
  
  -- ???
  if revision then
    repo:checkout(revision)
  end

  self:onBuild(context, function(err, res)
    -- call publishers  with the project and the result of the build
    for publisher, handler in pairs(self.publishers) do
      if type(handler) == 'function' then
        handler(self, err or res)
      end
    end
  end) 
end

return { Unbroken = Unbroken,
  publishers = {
    echo = function(project, result)
      print('[' .. project.name .. '] ' .. result)
    end
  }
}

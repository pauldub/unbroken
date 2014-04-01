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
  self.name = options.name or ''
  self.publishers = options.publishers or {}
  self.scm = GitRepo:new(options.url)
end

function Unbroken:build(revision)
  -- build path, mktemp probably
  local build_path = 'test/unb'

  local context = {
    -- executes in build path
    cmd = function(self, cmd)
      print('execute ' .. 'cd ' .. build_path .. ' && ' .. cmd .. ' at ' .. revision)
    end 
  }

  self.scm:clone('test/unb')
  
  if revision then
    self.scm:checkout(revision)
  end

  self:test(context, function(err, res)
    for publisher, handler in pairs(self.publishers) do
      if type(handler) == 'function' then
        handler(self, err ~= false and err or res)
      end
    end

    if err ~= false then
      error(err)
    end
  end) 
end

return {
  Unbroken = Unbroken,
  publishers = {
    echo = function(project, result)
      print('[' .. project.name .. '] ' .. result)
    end
  }
}

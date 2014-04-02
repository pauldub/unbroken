local utils = require('utils')

local Emitter = require('core').Emitter

local dnode = require('dnode')

local publishers = require('./publishers')

local Server = require('./server')

-- escape commands before running them

-- Not ure about the name.
local Unbroken = Emitter:extend() 
function Unbroken:initialize(options)
  self.instance = options
end

-- The signature of this function is really bad.
function Unbroken:build(revision, connect, cb)
  local instance = self.instance
  -- Create callback so server can read files from config dir
  -- a bit ugly, I like better the fact that functions in config/dnode.lua
  -- are accessible ! :)
  -- Maybe a pluggable imlementation just like publishers?
  instance.readFile = function(self, path, reply)
    reply(false, 'foo content')
  end

  local d = dnode:new(instance)

  d:once('remote', function(remote)
    remote.build(function(err, result)
      -- call publishers  with the project and the result of the build
      for publisher, handler in pairs(instance.publishers) do
        if type(handler) == 'function' then
          handler(instance, err or result)
        end
      end
      if type(cb) == 'function' then
        cb(err, result)
      end
    end) 
  end)

  self.d = d

  -- ugly and useless
  connect(d, function(err)
    if (err) then  
      error(err) 
    end
  end)
end

return { 
  Unbroken = Unbroken,
  Server = require('./server'),
  publishers = publishers
}

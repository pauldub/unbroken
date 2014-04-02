local table = require('table')
local Emitter = require('core').Emitter

local async = require('async')

function table.join(t1, t2)
  for _, v in ipairs(t2) do
    table.insert(t1, v)
  end
end

local SimpleBuilder = Emitter:extend()
function SimpleBuilder:initialize(client)
  local commands = { }
  self.commands = commands

  self.context = {
    path = client.build_path,

    -- Add commands to be run this step.
    run = function(self, cmd)
      if type(cmd) == 'table' then
        table.join(commands, cmd)
      elseif type(cmd) == 'string' then
        table.insert(commands, cmd)
      end
    end,
  
    -- helper to copy a file from client to server build path  
    -- server grabs file content from the client.
    copyFile = function(self, client_path, path)
      table.insert(commands, function(done)
        client:readFile(client_path, function(err, content)
          if err then
            return done(err)
          end
          print('ok writing ' .. content .. ' to ' .. self.path .. '/' .. path)
          return done()
        end)
      end)
    end,
    -- these two could easily be implemented, to run
    -- in docker containers for example ;)
    -- we could 
  }

  self:on("run", function(client, done)
    -- print commands to terminal and execute callbacks.
    async.forEachSeries(self.commands, function(cmd, next_command)
      if type(cmd) == 'function' then
        cmd(next_command)
      elseif type(cmd) == 'string' then
        print('[' .. client.name .. '] run: ' .. cmd)
        next_command()
      else
        next_command('invalid command')
      end
    end, done) 
  end)
end

return SimpleBuilder

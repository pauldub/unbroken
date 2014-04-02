local dnode = require('dnode')
local async = require('async')

local languages = require('./languages')

local GitRepo = require('./git_repo')
local Builder = require('./builders/simple')

-- Validates that a language has a valid structure
local function validLanguage(language)
  return language and language.name and language.steps
end

-- Returns a client step based on current_step == { 'step_type', 'step_name ' }
local function getStep(client, current_step)
  local step
  local step_type = current_step[1]
  if step_type == 'language' and validLanguage(client.language) then
    step = client.language.steps[current_step[2]]
  elseif step_type == 'client' and type(client[current_step[2]]) == 'function' then
    step = client[current_step[2]]
  end
  return step
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
        local language = languages[client.language]
        if type(language) ~= 'table' then
          return reply('Unsupported language: ' .. client.language or '')
        end

        client.language = language

        local build_path = 'foo/bar'
        client.build_path = build_path

        local repo = GitRepo:new(client.url)
      
	      -- the clone / checkout part could be refactored
        repo:clone(build_path)

        -- ???
        if revision then
          repo:checkout(revision)
        end

        local steps = { 
          -- Maybe: 
          -- { 'repo', 'checkout' }
          -- { 'repo', 'clone' }
          { 'language', 'beforeInstall' },
          { 'client', 'beforeInstall' },
          { 'language', 'install' },
          { 'client', 'install' },
          { 'language', 'beforeScript' },
          { 'client', 'beforeScript' },
          { 'client', 'script' }
        }

        -- each step is executed in serie, build fails if any step
        -- returns an error.
        async.forEachSeries(steps, function(current_step, next_step)
          Server.runStep(self, client, current_step, next_step)
        end, reply)
  
      end,
    }
  end)

  return self
end

function Server:runStep(client, current_step, next_step)
  print('[' .. client.name .. '] step: ' .. current_step[1] .. ' - ' .. current_step[2])

  local step = getStep(client, current_step)
  if type(step) ~= 'function' then
    return next_step()
  end

  -- Commands to run this step.
  local commands = { }

  -- How inefficient it is to build this every step?
  -- -- the builder passed to each step should be controlled.
  -- the run command populates an array that will run them in
  -- series too (configurable?) before calling the next step.
  -- maybe a specific run command will allow parallel execution.
  local builder = Builder:new(client)

  -- run the step with the builder context and
  step(builder.context, function(self, err, res)
    if err then
      return next_step(err)
    end

    -- now let the builder run
    builder:emit('run', client, next_step)
  end)
end

return Server


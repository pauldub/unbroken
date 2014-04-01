#!/usr/bin/env luvit

local fs = require('fs')
local table = require('table')
local Path = require('path')
local debugm = require('debug')
local fmt = require('string').format

local options = require('options')
local async = require('async')

local argv = options
  .usage('Usage: ./unrboken build PROJECT | buildall | list | status')
  .describe('c', 'path to the config directory')
  .alias ({ c = 'config' })
  .demand({ 'c' })
  .argv("c:")

local utils = require('utils')

function run()
  -- set the exitCode to error in case we trigger some
  -- bug that causes us to exit the loop early
  process.exitCode = 1

  local args = argv.args._
  local config_dir = argv.args.c 

  print(utils.dump(args))

  if args[1] == 'build' then
    local name = args[2]
  elseif args[1] == 'buildall' then
    print('build all projects')
  elseif args[1] == 'list' then
    print('project list')
  elseif args[1] == 'status' then
    print('project status')
  end

  testsPath = Path.resolve(process.cwd(), config_dir)

  fs.readdir(testsPath, function(err, files)
    local paths = {}, file

    if err then
      p(err)
      return
    end

    for i=1, #files do
      file = files[i]

      if file:find('.lua$') then
        table.insert(paths, Path.join(testsPath, file))
      end
    end

    print(utils.dump(paths))
  end)
end

run()

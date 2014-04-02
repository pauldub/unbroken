local Object = require('core').Object

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

return GitRepo

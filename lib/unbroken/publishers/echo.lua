local function echo(project, result)
  if result then
    print('[' .. project.name .. '] ' .. result)
  end
end

return echo

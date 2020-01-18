luaplayground = {
  path = os.getenv("PWD"),

  load = function(new_path)
    if new_path then luaplayground.path = new_path end
    local file = io.open(luaplayground.path.."/"..".luaplayground", "r")
    if file then loadstring(file:read("*all"))() file:close() file = nil end
    if not _G[".luaplayground"] then _G[".luaplayground"] = {} end

    local files = {}
    for file_name, meta in pairs(_G[".luaplayground"]) do
      file = io.open(luaplayground.path.."/"..file_name, "r")
      if file then
        files[file_name] = { name = meta.name, type = meta.type, file = file }
      end
    end

    while next(files) do
      for file_name, data in pairs(files) do
        if _G[data.type] then
          _G[data.type](data)
          files[file_name] = nil
        end
      end
    end
  end,

  save = function(meta, file_name, skip_config)
    -- run without args to save all
    if not skip_config then
      -- save config!
    end
    if meta then
      file_name = file_name or meta.name
      _G[".luaplayground"][file_name] = meta
      local t = _G[meta.name]
      local _save = _G[meta.type.."_save"]
      if _save then
        return _save(t, file_name)
      end
      local file = io.open(luaplayground.path.."/"..file_name, "w")
      if file then
        file:write("--"..tostring(t.type).."\n")
        file:write("--"..tostring(t.name).."\n")
        file:write(t.str or t)
        file:close()
        return true
      end
    else
      for file_name, meta in pairs(_G[".luaplayground"]) do
        luaplayground.save(meta, file_name, true)
      end
    end
  end
}

_G["function"] = function(data)
  local str = data.file:read("*all")
  data.file:close()
  local fn = loadstring(str)
  local t = { str = str, name = data.name, type = data.type }
  setmetatable(t, { __call = function(_, ...) return fn(...) end })
  _G[t.name] = t
  return t
end

_G["function_save"] = function(t, file_name)
  local file = io.open(luaplayground.path.."/"..file_name, "w")
  if file then file:write(t.str) file:close() return true end
end

luaplayground.load()

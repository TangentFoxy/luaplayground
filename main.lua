--function
--main

-- opens all numerically indexed files starting at 1,
--  loads all types by functions specified by type name

-- get all file handles
local files = {}
local path = os.getenv("PWD")
local i = 1
repeat
  local file = io.open(path.."/"..i, "r")
  table.insert(files, file)
  i = i + 1
until not file
print("Opened "..tostring(i - 2).." files.")

-- copy data and close file handles
local data = {}
local loader
for i, file in ipairs(files) do
  local _type = file:read("*line")
  local name = file:read("*line")
  if _type and name then
    local t = { type = _type:sub(3), name = name:sub(3), file = i }
    t.str = file:read("*all")
    table.insert(data, t)
    if t.name == "function" then
      loader = loadstring(t.str)
    end
  end
  file:close()
end
files = nil

-- load functions and keep track of other types
local others = {}
for _, t in ipairs(data) do
  if t.type == "function" then
    loader(t.name, t.str)
  else
    table.insert(others, t)
  end
end
data = nil

-- load other types, printing any errors encountered
--  unloaded files are stored in _UNLOADED, probably shouldn't overwrite these
for _, t in ipairs(others) do
  if _G[t.type] then
    _G[t.type](t.name, t.str)
  else
    print("Unable to load type \""..t.type.."\" from file "..t.file..".")
    if not _UNLOADED then _UNLOADED = {} end
    _UNLOADED[t.file] = true
  end
end

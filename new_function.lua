-- [global name (string)], function (string)
local args = {...}
local name
if #args > 1 then
  name = table.remove(args, 1)
  if #name < 1 then name = tostring(#_G + 1) end
end
local str = table.remove(args, 1)
local fn = loadstring(str)
local t = { str = str, name = name, type = "function" }
setmetatable(t, { __call = function(_, ...) return fn(...) end })
_G[name] = t
luaplayground.save({ name = name, type = "function" }, name)
return t

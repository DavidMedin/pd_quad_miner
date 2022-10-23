-- Properties, in Lua

--[[
    Example:
   do
   local prop = property {
      get = function(prop)
         return prop.val
      end,

      set = function(prop, value)
         prop.val = value + 1
      end
   }
   -- <<= to set property, # to read.
   prop <<= 3
   print("property : " .. #prop)
end
]]
function property(funcs)
    local tab = {val=nil}
    setmetatable(tab, {__len=function() if funcs.get then return funcs.get(tab) else return tab.val end end,__shl=function(tab,value) if funcs.set then funcs.set(tab,value);return tab else tab.val = value;return tab end end})
    return tab
end
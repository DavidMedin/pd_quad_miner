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


function enum(en)
   local new_tab = {}
   local i = 1
   for k,v in ipairs(en) do
      new_tab[v] = i
      i += 1
   end

   return new_tab
end

--[[
   Tests for enum
]]

if __debug then
   local enu = enum{
      "rose","jim","sword"
   }
   assert(enu.rose == 1, "failed enum test")
   assert(enu.jim == 2, "failed enum test")
   assert(enu.sword == 3, "failed enum test")
end


function enum_map(src_1,src_2)
   local map = {}
   for k,v in pairs(src_1) do
      for k2,v2 in pairs(src_2) do
         if k == k2 then
            map[v] = v2
         end
      end
   end
   return map
end

if __debug then
   -- tests for enum_map
   local enum1 = enum {
      "yolo",
      "gun",
      "stone",
      "rose"
   }
   local enum2 = enum {
      "gun",
      "water",
      "board",
      "table",
      "rose"
   }

   local map = enum_map(enum1,enum2)

   assert(map[enum1.gun] == 1, "failed enum test")
   assert(map[enum1.gun] == enum2.gun, "failed enum test")
   assert(map[enum1.rose] == enum2.rose, "failed enum test")
   
end

function table.keyOfValue(tabl,value)
   for k,v in pairs(tabl) do
      if value == v then return k end
   end
end
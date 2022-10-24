--[[
    author : David Medin
    file : resources.lua
    date : Oct 23 2022 3:00 PM
    liscense : The Don't Ask Me About it Liscense
]]
-- I don't know how useful this is, but here it is.
-- class("store").extends()
-- function store:init()
--     store.super.init(self)

--     self.objs = {}
--     setmetatable(self.objs)
-- end
-- function store:set(name,object,weak)
--     assert(self.objs[name] == nil, "Attempted to make duplicate resource!")
--     if weak == nil then weak = true end
--     self.objs[name] = object

--     if weak then
--         return self:weak_get(name)
--     else
--         return self:get(name)
--     end
-- end
-- function store:get(name)
--     return self.objs[name]
-- end
-- function store:weak_get(name)
--     local pkg = setmetatable({value=self.objs[name]}, {__mode="v"})
--     return pkg
-- end


-- global_store = store() -- Put resources here!

--================= Weak Storage
-- Stores weak refs, distributes strong refs
function weak_store()
    return {
        objects = setmetatable({}, {__mode='v'}),
        funcs = {},
        set = function(self,name, func)
            assert(self.funcs[name] == nil, "Attempted to overwrite init function (weak_store).")
            self.funcs[name] = func
        end,
        get = function(self,name)
            assert(self.funcs[name] ~= nil, "Attempted to get resource that doesn't have a function.")
            if self.objects[name] == nil then
                local strong_ref = self.funcs[name]()
                if __debug then assert("Failed to load resource '"..name.."'!") end
                self.objects[name] = strong_ref
                return strong_ref
            end

            return self.objects[name]
        end,
        
    }
end
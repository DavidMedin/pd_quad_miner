ENTITIES = {}
---@class entity

---@class component : Object
---@field super Object
---@field entity entity
---@field visible boolean ### I do not know what this does.
component = nil
class("component",{entity=nil,visible=true}).extends()
---Creates a component
---@param entity entity
function component:init(entity) -- Parent is the relationship between component to entity.
   component.super.init(self)
   self.entity = entity
end

---@class entity : Object
---@field super Object
entity=nil
class("entity", {}).extends()

function entity:init()
   entity.super.init(self)
   table.insert(ENTITIES, self)
end

function entity:addComponent(comp,...)
   self[comp.className] =  comp(self,...)
   return self
end
function entity:add(comp,...)
   self[comp.className] =  comp(self,...)
   return self
end
function entity:hasComponent(component)
   return self[component.className] ~= nil
end
---@generic T
---@param name `T`
---@return T|nil
function entity:get(name)
   return self[name]
end

function entity:Kill()
   -- call death functions
   for k,v in pairs(self) do
      if v.die ~= nil then
         v:die()
      end
   end

   for k,v in pairs(ENTITIES) do
      if v == self then
         table.remove(ENTITIES,k)
      end
   end
end
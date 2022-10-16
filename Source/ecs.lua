entities = {}
class("component",{entity=nil,visible=true}).extends(Object)
function component:init(entity) -- Parent is the relationship between component to entity.
   component.super.init(self)
   self.entity = entity
end

class("entity", {}).extends(Object)
function entity:init()
   entity.super.init(self)
   table.insert(entities, self)
end

function entity:addComponent(comp,...)
   self[comp.className] =  comp(self,...)

   return self
end
function entity:hasComponent(component)
   return self[component.className] ~= nil
end

function entity:Kill()
   -- call death functions
   for k,v in pairs(self) do
      if v.die ~= nil then
         v:die()
      end
   end

   for k,v in pairs(entities) do
      if v == self then
         table.remove(entities,k)
      end
   end
end
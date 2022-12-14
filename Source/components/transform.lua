import "rot_math.lua"

---@class transform : component
---@field pos vec2
---@field offset vec2
---@field rot number
---@field scale number
---@field parent entity|nil
---@field children entity[]
---@field vel vec2
---@field accel vec2
---@field gravity vec2
---@field colliding boolean
transform=nil
class("transform",
      {
         -- pos,rot,scale,offset,
         -- trans,final_trans,
         -- parent,children
      }
).extends(component)
function transform:init(entity,parent)
   transform.super.init(self,entity)
   
   self.pos = vec2.new(0,0)
   self.offset = vec2.new(0,0)
   self.rot = 0
   self.scale = 1

   self.parent = parent
   self.children = {}

   self.vel = vec2.new(0,0)
   self.accel = vec2.new(0,0)
   self.mass = 1

   self.gravity = vec2.new(0,0)
   self.colliding = false
   self:ComputeTransform()

   if self.parent ~= nil then
      local transform = self.parent--[[@as entity]]:get"transform"
      if __DEBUG then assert(transform) end
      ---@cast transform transform -- guaranteed by __DEBUG
      transform:AddChild(self)
   end

end

---@param force vec2
function transform:ApplyForce(force)
   if __DEBUG then assert(force,force.x,force.y) end

   self.accel += force / self.mass
end

function transform:update()
   self.vel += self.accel + self.gravity/self.mass
   -- self.vel /= 1.3 -- drag
   local air_density = 10
   self.vel -= self.vel / air_density

   -- quick stop
   if self.vel:magnitude() <= 0.2 then
      self.vel = vec2.new(0,0)
   end
   
   self.accel = vec2.new(0,0)

   -- apply
   -- self:Move(self.vel)
end

-- Go to global position
---@param g_pos vec2
function transform:GetGlobal(g_pos)

   -- Get the inverse of the final trans for this object
   local inverse = self.final_trans:copy()
   inverse:invert()

   self.pos = inverse * g_pos

   self:ComputeTransform()
end

function transform:ComputeTransform()
   local rotate = geom.affineTransform.new():rotatedBy(self.rot)
   local translate = geom.affineTransform.new():translatedBy(self.pos.x,self.pos.y)
   local offset = geom.affineTransform.new():translatedBy(self.offset.x,self.offset.y)
   local scale = geom.affineTransform.new():scaledBy(self.scale)

   -- Calculate our transform and our final transform
   self.trans = scale * offset * rotate * translate

   self:ComputeFinalTransform()
end

function transform:ComputeFinalTransform()
   self.final_trans = self.trans

   -- If we have a parent, then use their transform.
   if self.parent ~= nil then
      -- parent *must* have a transform component
      if __DEBUG then assert(self.parent.transform) end

      self.final_trans *= self.parent.transform.final_trans
   end

   -- If the entity has a meatbag, update its sprite's position,
   --  a parent may have moved where things are, and now we need
   --  to move. (Maybe we should direct collision reactions to our
   -- parent?)
   if self.entity:hasComponent(meatbag) then
      local pos = self:GetTranslation()
      self.entity:get"meatbag".sprite:moveTo( GetPoint(pos) )
   end

   -- Update Children's Final Transform
   for i,child in pairs(self.children) do
      local transform = child:get"transform"
      if __DEBUG then assert(transform) end
      ---@cast transform transform

      transform:ComputeFinalTransform()
   end
end

-- Moves this position and its children.
---@param vec vec2
function transform:MoveCollide(vec)
   
   -- Vec must have these
   local meatbag = self.entity:get"meatbag"
   if __DEBUG then
      assert(vec)
      assert(vec.x)
      assert(vec.y)

      assert(meatbag)
   end
   ---@cast meatbag meatbag

   -- Apply to our parameters
   local goal = self.pos + vec
   local actualX,actualY,collisions,length = meatbag.sprite:moveWithCollisions(goal.x,goal.y)
   local actual = vec2.new(actualX,actualY)
   
   self.pos = actual
   -- The transform point is where the sprite is.
   
   if collisions ~= nil and #collisions ~= 0 then
      self.colliding = true
      -- Velocity is the vector from the last collision point to the end.
      -- local touch = GetVec(collisions[#collisions].touch)
      -- self.vel = actual - touch
      
      -- DEBUG - add touch point to table to indefinatly draw
      -- table.insert(touchy, collisions[#collisons])
      -- for k,v in pairs(collisions) do
      --    table.insert(touchy, v.touch)
      -- end
   -- else
   else
      self.colliding = false
   end
   
   -- Update our transform, final transform, and children's final transforms.
   self:ComputeTransform()
end

function transform:Move(vec)
   
   -- Vec must have these
   assert(vec)
   assert(vec.x)
   assert(vec.y)

   -- Apply to our parameters
   self.pos += vec
   local meatbag  = self.entity:get"meatbag"
   if meatbag ~= nil then
      meatbag.sprite:moveTo( GetPoint(self.pos) )
   end

   -- Update our transform, final transform, and children's final transforms.
   self:ComputeTransform()
end

---@param vec vec2
function transform:Offset(vec)
   if __DEBUG then
      assert(vec)
      assert(vec.x)
      assert(vec.y)
   end

   self.offset = vec
   self:ComputeTransform()
end

-- Rotates this transform and its children.
---@param deg number
function transform:Rotate(deg)
   if __DEBUG then assert(deg) end

   self.rot = (self.rot + deg) % 360

   -- Update our trans, final trans, and our children's final trans.
   self:ComputeTransform()
end

-- Adds child transform.
---@param child transform
function transform:AddChild(child)
   -- These should exist
   if __DEBUG then
      assert(child)
      assert(child.entity)
   end

   --Add the child
   table.insert(self.children, child.entity)
   child.parent = self.entity

   child:ComputeFinalTransform()
end

function transform:GetTranslation()
   return self.final_trans * vec2.new(0,0)
end

-- Recursive function to get rotation of ancestory
function transform:GetRotation()
   if self.parent == nil then
      return self.rot
   end

   assert(self.parent.transform)
   return self.rot + self.parent.transform:GetRotation()
end
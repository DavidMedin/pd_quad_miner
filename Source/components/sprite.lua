-- A sprite derivitive that 'hooks' that component's transform.
---@class compsprite : pd_sprite
---@field super pd_sprite
---@field component component
compsprite=nil
class("compsprite",{component}).extends(gfx.sprite)
function compsprite:init(component,image)
   compsprite.super.init(self)

   -- set the image of the sprite
   self:setImage(image)

   self:moveTo(0,0)
   self:setImageDrawMode(gfx.kDrawModeCopy)

   -- Add sprite to the drawing queue
   self:add()
   
   if component == nil then print("you must supply a component!") end
   self.component = component
end
function compsprite:update()
   compsprite.super.update(self)
   local trans = self.component.entity:get"transform"
   assert(trans)
   local pos = trans:GetTranslation()
   self:moveTo(pos.x,pos.y)
   self:setRotation( trans:GetRotation() )
end


function playdate.graphics.sprite:collisionResponse(other)
   return playdate.graphics.sprite.kCollisionTypeSlide
end
-- A sprite derivitive that 'hooks' that component's transform.
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
   gfx.sprite.update(self)
   local trans = self.component.entity.transform
   local pos = trans:GetTranslation()
   self:moveTo(pos.x,pos.y)
   self:setRotation( trans:GetRotation() )
end


function playdate.graphics.sprite:collisionResponse(other)
   return playdate.graphics.sprite.kCollisionTypeSlide
end
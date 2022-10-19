-- prototype of meatbag 'type'
class("meatbag",
	  {
	     health=100,
        invuln=false,
        invuln_time=1500
}).extends(component)


function meatbag:init(entity)
   -- Initialize the component class (parent)
   meatbag.super.init(self,entity)

   -- set the sprite
   self.sprite = compsprite(self,hero_img)
   -- set the sprite's collision rectangle
   self.sprite:setCollideRect( 0,0,self.sprite:getSize() )
   self.sprite:setGroups({collide_group.hero})
   self.sprite:setCollidesWithGroups(collide_group.stone)
   
   -- Create collidable for the meatbag
   self.polygon = CreateRect(16,16)
end

function meatbag:die()
   self.sprite:remove()
end

function meatbag:draw()

   -- a meatbag needs to have a transform to draw
   if self.entity.transform == nil then
      print("Meatbag entity doesn't have component!")

      -- early return
      return
   end
end

function meatbag:Damage(damage)
   if self.invuln == false then
      domsg("Hit!")
      self.health -= damage
      if self.health <= 0 then
         self.entity:Kill()
         return
      end
   end

   self.invuln=true
   local reset = function(meat)
      meat.invuln=false
   end
   playdate.timer.new(self.invuln_time,reset,self)
end

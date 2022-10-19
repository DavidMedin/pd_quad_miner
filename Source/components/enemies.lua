class("thug", -- Has a knife
      {
}).extends(component)

-- Is an AI component
class("hostile", -- Doesn't like you
      {
	 against=nil, -- Which entities do I not like?
	 speed=0.5,
}).extends(component)
function hostile:init(entity,who)
   hostile.super.init(self,entity)
   self.against = who or {}

   if self.entity.meatbag ~= nil then
      self.entity.meatbag.sprite:setImage(thug_img)
   end
end
function hostile:update()
   local trans = self.entity.transform

   -- Pick a enemy to persue
   local chosen = {}
   for k,enemy in pairs(self.against) do
      local this_point = geom.point.new(trans.pos.x,trans.pos.y)
      local enemy_trans = enemy.transform
      local enemy_point = geom.point.new(enemy_trans.pos.x,enemy_trans.pos.y)
      local dist = this_point:distanceToPoint(enemy_point)

      if chosen.ent == nil or chosen.dist > dist then
	 chosen.ent = enemy
	 chosen.dist = dist
      end
   end
   -- We have the smallest now
   local enemy  = chosen.ent
   if chosen.dist < 10 then
      return
   end
   local diff = enemy.transform.pos - trans.pos
   diff:normalize()
   
   -- Write to the transformation
   trans:ApplyForce(diff*self.speed)
   -- trans.pos += diff * self.speed
   -- trans:ComputeTransform()
end 

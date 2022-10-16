import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/timer"
pd = playdate
gfx = pd.graphics
geom = pd.geometry
vec2 = pd.geometry.vector2D
sin = function(a) return math.sin(math.rad(a)) end
cos = function(a) return math.cos(math.rad(a)) end
asin = function(a) return math.deg(math.asin(a)) end
acos = function(a) return math.deg(math.acos(a)) end
atan = function(a,b) return math.deg(math.atan(a,b)) end

block_kind = {
   air = 0,
   stone = 1
}

collide_group = {
   hero=1,
   stone=2,
   air=3,
}

import "ecs"
import "transform"
import "polygon"
import "meatbag"
import "enemies"
import "sprite"
import "player"
import "camera"
import "quadtree"
import "map_node"

-- ================== Load Resources
waku25 = gfx.font.new("waku25.pft")
waku10 = gfx.font.new("waku10.pft")
sword_img = gfx.image.new("sword.pdi")
hero_img = gfx.image.new("hero.pdi")
thug_img = gfx.image.new("thug.pdi")

__debug = true
screen_size = vec2.new(400,240)
-- =================== Initialize Global Data

msg = {}
function domsg(format,...)
   table.insert(msg,string.format(format,...) )
end

crank_vel=0


map = quadtree(block_kind.air,map_node)
for x=1,math.pow(2,map.max_depth) do
   for y=1, 10 do
      map:change(vec2.new(x, math.pow(2,map.max_depth)/2+y),block_kind.stone)
   end
end
-- =================== Initialize Entities
do
   hero = entity()
   hero:addComponent(transform):addComponent(meatbag):addComponent(player):addComponent(camera)
   hero.transform:Move( vec2.new(math.pow(2,map.max_depth)/2 * block_size - 100 + 8,math.pow(2,map.max_depth)/2 * block_size - 100) )
   hero.transform.gravity = vec2.new(0,1)

   -- Want to know how to make an entity? Look at https://github.com/davidmedin/pd_swords
end
-- ======== Simple Do Msg function and setup =========

-- ============================== Canvas context setup

function DrawBackground()
end

gfx.setColor(gfx.kColorWhite)
gfx.setBackgroundColor(gfx.kColorBlack)
gfx.setImageDrawMode(gfx.kDrawModeCopy)
gfx.setFont(waku25)
gfx.sprite.setBackgroundDrawingCallback(DrawBackground)


-- ======================================== Input functions

function action_change(kind)
   local butt = {pd.buttonIsPressed(pd.kButtonUp),
         pd.buttonIsPressed(pd.kButtonDown),
         pd.buttonIsPressed(pd.kButtonRight),
         pd.buttonIsPressed(pd.kButtonLeft)
      }
      local true_count = 0
      for k,v in ipairs(butt) do if v == true then true_count += 1 end end
      if true_count ~= 1 then
         return
      end

      local hero_grid = vec2.new(math.ceil(hero.transform.pos.x / 20), math.ceil(hero.transform.pos.y/ 20))
      local block_pos = hero_grid
      if butt[1] == true then
         block_pos.y -= 1
      elseif butt[2] == true then
         block_pos.y += 1
      elseif butt[3] == true then
         block_pos.x += 1
      elseif butt[4] == true then
         block_pos.x -= 1
      end

      map:change(block_pos,kind)
end

local hero_control_handles = {
   upButtonDown = function()
      if b_timer ~= nil or hero.transform.colliding == false then return end
      b_timer = pd.timer.new(125, function() b_timer = nil end)
      b_timer.updateCallback = function(timer)
         hero.transform.accel -= vec2.new(0,6)
      end
   end,

   AButtonDown = function()
      action_change(block_kind.air)
   end,
   BButtonDown = function()
      action_change(block_kind.stone)
   end

}

pd.inputHandlers.push(hero_control_handles)


-- ============================== Update function

function playdate.update()
   
   gfx.clear()
   
   -- ========= Updating ==========
   
   for k,entity in pairs(entities) do
      for i, component in pairs(entity) do
         if component.update ~= nil then
            component:update()
         end
      end
   end
   
   -- Apply Velocities
   -- hero.transform.vel.y += 1
   for k,entity in ipairs(entities) do
      if entity.transform ~= nil then

         -- Use MoveCollide if has a meatbag (which has a sprite).
         if entity.meatbag ~= nil then
            entity.transform:MoveCollide(entity.transform.vel)
         else
            entity.transform:Move(entity.transform.vel)
         end

      end
   end

   --========== Drawing ===========
   gfx.sprite.update()
   hero.camera:activate()
   for k,entity in pairs(entities) do
      for i,component in pairs(entity) do
         if component.draw ~= nil and component.visible == true then
            component:draw()
         end
      end
   end
   map:draw()

   -- =========== Display DoMsg ===========
   do
      gfx.pushContext()
      gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

      local msg_prog = 0
      local offset = vec2.new(17,17)
      for k,v in pairs(msg) do
         gfx.drawText(v,0+offset.x,msg_prog+offset.y)
         msg_prog += 17
      end
      msg = {}
      
      gfx.popContext()
   end

   -- Update timer
   playdate.timer.updateTimers()

   -- ====== Update crank acceleration
   local change = playdate.getCrankChange()
   crank_vel = change
end

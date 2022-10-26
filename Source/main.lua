import "prelude"
import "util"
import "resource"
math.randomseed(playdate.getSecondsSinceEpoch())

---@enum block_kind
BLOCK_KIND = {
   air=1,
   stone=2,
   gold=3,
}

---@enum collide_group
COLLIDE_GROUP = {
   hero = 1,
   stone = 2,
   air = 3,
}

DRAW_ID = false
__DEBUG = true
GRAVITY = true
SCREEN_SIZE = vec2.new(400, 240)

-- sword_img = gfx.image.new("images/sword.pdi")

--[[
   TODO: Sounds
   TODO: Better collisions
   TODO: text resizing
   TODO: Scenes
   TODO: quadtree chunk loading-unloading
]]
import "ui"
import "ecs"
import "components/items"
import "components/transform"
import "polygon"
import "components/meatbag"
import "components/sprite"
import "components/player"
import "components/camera"
import "components/inventory"
import "quadtree"
import "map_node"
import "map_gen"
import "sounds"
import "input"

-- ================== Load Resources
WAKU25 = gfx.font.new("fonts/waku25.pft")
WAKU15 = gfx.font.new("fonts/waku15.pft")
WAKU10 = gfx.font.new("fonts/waku10.pft")

IMGUI_ADD_ITEM("gravity", IMGUI_ITEM_KIND.button, function()
   GRAVITY = not GRAVITY
   if GRAVITY then
      HERO.transform.gravity = vec2.new(0, 1)
   else
      HERO.transform.gravity = vec2.new(0, 0)
   end
   -- Also somewhere is
end)

--================ Generate Map=============
MAP = quadtree(BLOCK_KIND.air, map_node)
local map_size = 2 ^ MAP.max_depth
for x = 1, 2 ^ MAP.max_depth do
   for y = 1, 10 do
      MAP:change(vec2.new(x, 2 ^ MAP.max_depth / 2 + y), BLOCK_KIND.stone)
   end
end

ADD_SPHERE(MAP, vec2.new(map_size / 2, map_size / 2), 3)

-- =================== Initialize Entities
do
   HERO = entity()
   HERO:addComponent(transform):addComponent(meatbag):addComponent(player):addComponent(camera):addComponent(inv)
   HERO.transform:Move(vec2.new((2 ^ MAP.max_depth) / 2 * BLOCK_SIZE - 100 + 8 - 50,
      (2 ^ MAP.max_depth) / 2 * BLOCK_SIZE - 100))
   HERO.transform.gravity = vec2.new(0, 1)

   -- Want to know how to make an entity? Look at https://github.com/davidmedin/pd_swords
end

-- ============================== Canvas context setup

function DrawBackground()
   HERO.camera:activate()
   MAP:draw()
end

gfx.setColor(gfx.kColorWhite)
gfx.setBackgroundColor(gfx.kColorBlack)
gfx.setImageDrawMode(gfx.kDrawModeCopy)
gfx.setFont(WAKU25)
gfx.sprite.setBackgroundDrawingCallback(DrawBackground)



-- ============================== Update function

function playdate.update()

   gfx.clear()

   -- ========= Updating ==========

   for k, entity in pairs(ENTITIES) do
      for i, component in pairs(entity) do
         if component.update ~= nil then
            component:update()
         end
      end
   end

   -- Apply Velocities
   for k, entity in ipairs(ENTITIES) do
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
   HERO.camera:activate()
   gfx.sprite.update()
   for k, entity in pairs(ENTITIES) do
      for i, component in pairs(entity) do
         if component.draw ~= nil and component.visible == true then
            component:draw()
         end
      end
   end

   --===================UI DRAWING===========--
   DRAW_UI()

   -- Update timer
   playdate.timer.updateTimers()
end

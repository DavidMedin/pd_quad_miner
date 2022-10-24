--[[
    author : David Medin
    date : Oct 23 2022 3:22 PM
    file : items.lua
]]

local icons = weak_store() -- the icons for each
-- BEWARE! this by default should be the name of your item class!
-- Otherwise, you need to override the get_icon() function of 'item'.
icons:set("pick", function() return gfx.image.new("images/pick.pdi") end )
icons:set("stone", function() return gfx.image.new("images/stone-icon.pdi") end )
icons:set("gold", function() return gfx.image.new("images/gold-icon.pdi") end )

local next_item_id = 1
-- Requires self.name to be set!
class("item").extends(component)
function item:init(ent,init_func)
    if __debug then assert(init_func and type(init_func == "function"),"Item creation requires an init function.") end
    item.super.init(self)

    self.id = next_item_id
    next_item_id += 1

    init_func(self)
    self.icon = icons:get(self.name)
    if __debug then assert(self.icon, "failed to load icon '"..self.name.."'.") end
end
function item:on_use()
    print("Attemped to call 'on_use()' on item '" .. self.name.. "'!")
end


-- ====================== ITEM IMPLEMENTATIONS

--[[
    Available methods:
    required:
    optional:
        on_use()
    
]]


items = enum {
    "air",
    "stone",
    "gold"   
}

--= =========== Helper functions
local function action_change(kind)
    local block_pos = button_dir()    

    local hero_grid = vec2.new(math.ceil(hero.transform.pos.x / 20), math.ceil(hero.transform.pos.y/ 20)) + block_pos

    map:change(hero_grid,kind)
end
--============

function pick_item(self) -- self is an item class.
    self.name = "pick"
    self.kind = block_kind.air
    self.on_use = function(self)
        action_change(self.kind)
    end
end

function stone_item(self)
    self.name = "stone"
    self.kind = block_kind.stone
    self.on_use = function(self)
        action_change(self.kind)
    end
end
function gold_item(self)
    self.kind = block_kind.gold
    self.name = "gold"
    self.on_use = function(self)
        action_change(self.kind)
    end
end

--==========================
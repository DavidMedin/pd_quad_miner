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

    Available fields:
    required:
    optional:
        inv
    
]]


items = enum { -- all must be item function name without '_item'
    "pick",
    "stone",
    "gold"   
}
block_item_map = enum_map(block_kind,items)
--= =========== Helper functions

-- Gets the position of the block that will be changed by the player
local function select_block_pos()
    local block_pos = button_dir()    
    local hero_grid = vec2.new(math.ceil(hero.transform.pos.x / 20), math.ceil(hero.transform.pos.y/ 20)) + block_pos
    return hero_grid
end
local function map_gather(map,inv)
    local node_pos = select_block_pos()

    -- copied from map:change, but different
    local node,parent = map:create_get_node(node_pos)

    if node.kind ~= block_kind.air then
        inv:add_item(entity():add(item, _G[table.keyOfValue(block_kind,node.kind) .. "_item"]  ))
    end
    
    node.kind = block_kind.air
    node:changed_kind()

    map:collapse_from_node(node)
end

local function action_change(kind)
    local hero_grid = select_block_pos()

    map:change(hero_grid,kind)
end
--============

function pick_item(self) -- self is an item class.
    self.name = "pick"
    self.kind = block_kind.air
    self.on_use = function(self)
        map_gather(map,self.inv)
        --action_change(self.kind)
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
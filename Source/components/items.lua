--[[
    author : David Medin
    date : Oct 23 2022 3:22 PM
    file : items.lua
]]

local icons = WEAK_STORE() -- the icons for each
-- BEWARE! this by default should be the name of your item class!
-- Otherwise, you need to override the get_icon() function of 'item'.
icons:set("pick", function() return gfx.image.new("images/pick.pdi") end )
icons:set("stone", function() return gfx.image.new("images/stone-icon.pdi") end )
icons:set("gold", function() return gfx.image.new("images/gold-icon.pdi") end )

local next_item_id = 1
--- Requires self.name to be set!
---@class item : component
---@field name string
---@field id integer
---@field inv inv
---@field on_use fun(self:item)
---@field kind block_kind
item=nil
class("item").extends(component)
---@param ent entity
---@param init_func fun(self:item)
function item:init(ent,init_func)
    if __DEBUG then assert(init_func and type(init_func == "function"),"Item creation requires an init function.") end
    item.super.init(self)

    self.id = next_item_id
    next_item_id += 1

    init_func(self)
    self.icon = icons:get(self.name)
    if __DEBUG then assert(self.icon, "failed to load icon '"..self.name.."'.") end
end
function item:on_use()
    print("Attemped to call 'on_use()' on item '" .. self.name.. "'!")
end

--= =========== Helper functions

-- Gets the position of the block that will be changed by the player
---@return vec2
local function select_block_pos()
    local block_pos = BUTTON_DIR()
    local hero_grid = vec2.new(math.ceil(HERO.transform.pos.x / 20), math.ceil(HERO.transform.pos.y/ 20)) + block_pos
    return hero_grid
end
---@param map quadtree
---@param inv inv
local function map_gather(map,inv)
    local node_pos = select_block_pos()

    -- copied from map:change, but different
    local node,parent = map:create_get_node(node_pos)

    if node.kind ~= BLOCK_KIND.air then
        local tmp = table.keyOfValue(BLOCK_KIND,node.kind) .. "_ITEM"
        inv:add_item(entity():add(item, _G[ string.upper( tmp ) ]  ))
    end

    node.kind = BLOCK_KIND.air
    node:changed_kind(node.kind)


    map:collapse_from_node(node)
end

---@param kind block_kind
---@param inv inv
local function action_change(kind,inv)
    
    local hero_grid = select_block_pos()
    
    _ = MAP:change(hero_grid,kind)
    -- Get the item name of the block.
    local item_name = table.keyOfValue(BLOCK_KIND,kind)
    if item_name == nil then return end -- If the block mined doesn't have an item.
    inv:remove_item(item_name) -- remove from inventory.
end
--============

---@param self item
function PICK_ITEM(self) -- self is an item class.
    self.name = "pick"
    self.kind = BLOCK_KIND.air
    self.on_use = function(item)
        map_gather(MAP,item.inv)
    end
end

---@param self item
function STONE_ITEM(self)
    self.name = "stone"
    self.kind = BLOCK_KIND.stone

    ---@param item item
    self.on_use = function(item)
        action_change(item.kind, item.inv)
    end
end
---@param self item
function GOLD_ITEM(self)
    self.kind = BLOCK_KIND.gold
    self.name = "gold"

    ---@param item item
    self.on_use = function(item)
        action_change(item.kind, item.inv)
    end
end

--==========================
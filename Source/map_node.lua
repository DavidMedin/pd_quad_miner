-- Map resources
local stone_img = gfx.image.new("images/stone.pdi")
local gold_img = gfx.image.new("images/gold.pdi")

---@type {[block_kind]: pd_image}
local kind_images = {
    [BLOCK_KIND.stone]=stone_img,
    [BLOCK_KIND.gold]=gold_img,
}

local air_margin = 5
local air_img = gfx.image.new(20 + 2*air_margin,20 + 2*air_margin, gfx.kColorWhite)

---@class map_node : node
---@field sprite pd_sprite
---@field id integer
map_node=nil
class("map_node").extends(node)

local next_id = 1

-- Called when the node is now the deepest in the tree (has no children. This one should render now).
function map_node:on_deepest(pos,width)
    -- Debug ID
    self.id = next_id
    next_id += 1

    self.sprite = gfx.sprite.new()
    self.sprite:moveTo(pos.x,pos.y)

    self.sprite:setCollideRect(0,0,width,width)

    if self.kind ~= BLOCK_KIND.air then
        self.sprite:setGroups(COLLIDE_GROUP.stone)
    else
        self.sprite:setGroups(COLLIDE_GROUP.air)
    end
    self.sprite:add()
end

function map_node:not_deepest()
    if self.sprite then -- This should fail ONLY during fast-paced construction and destruction (temp)
        self.sprite:remove()
        self.sprite = nil
    end
end


function map_node:changed_kind()
    self.sprite:resetGroupMask()
    if self.kind ~= BLOCK_KIND.air then
        self.sprite:setGroups(COLLIDE_GROUP.stone)
    else
        self.sprite:setGroups(COLLIDE_GROUP.air)
    end
end


function map_node:draw(pos,width,arb)
    -- doesn't have children. Draw itself
    if self.kind == nil then return end
    -- IF arb is 1, then stuff, otherwise, air.
    if self.kind ~= BLOCK_KIND.air and arb == 1 then -- If not air and is time to draw matter
        local block_img = kind_images[self.kind]
        -- if self.kind == block_kind.stone then
        --     block_img = stone_img
        -- elseif self.kind == block_kind.gold then
        --     block_img = gold_img
        -- else
            -- print("uh oh : ", self.kind)
        -- end
        if __DEBUG then assert(block_img, "Missing image for block kind!") end

        local save_mode = gfx.getImageDrawMode()
        gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
        for x=1, width/BLOCK_SIZE do
            for y=1,width/BLOCK_SIZE do
                block_img:draw(pos.x+BLOCK_SIZE*(x-1),pos.y+BLOCK_SIZE*(y-1))
            end
        end
        gfx.setImageDrawMode(save_mode)

    elseif self.kind == BLOCK_KIND.air and arb == 0 then -- Is air and time to draw air
        for x=1, width/BLOCK_SIZE do
            for y=1,width/BLOCK_SIZE do
                air_img:draw(pos.x+BLOCK_SIZE*(x-1) - air_margin,pos.y+BLOCK_SIZE*(y-1) - air_margin)
            end
        end
    end



    if self.id and DRAW_ID == true then
        local old_font = gfx.getFont()
        local col = gfx.getImageDrawMode()
        gfx.setFont(WAKU10)
        gfx.setImageDrawMode(gfx.kDrawModeNXOR)
        gfx.drawText(self.id --[[@as string]],pos.x+width/2-10,pos.y+width/2)
        gfx.setImageDrawMode(col)
        gfx.setFont(old_font)
    end
end
-- Map resources
stone_img = gfx.image.new("images/stone.pdi")
gold_img = gfx.image.new("images/gold.pdi")

local kind_images = {
    [block_kind.stone]=stone_img,
    [block_kind.gold]=gold_img,
}

local air_margin = 5
local air_img = gfx.image.new(20 + 2*air_margin,20 + 2*air_margin, gfx.kColorWhite)

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

    if self.kind ~= block_kind.air then
        self.sprite:setGroups(collide_group.stone)
    else
        self.sprite:setGroups(collide_group.air)
    end
    self.sprite:add()
end

function map_node:not_deepest(pos,width)
    if self.sprite then -- This should fail ONLY during fast-paced construction and destruction (temp)
        self.sprite:remove()
        self.sprite = nil
    end
end


function map_node:changed_kind()
    self.sprite:resetGroupMask()
    if self.kind ~= block_kind.air then
        self.sprite:setGroups(collide_group.stone)
    else
        self.sprite:setGroups(collide_group.air)
    end
end


function map_node:draw(pos,width,arb)
    -- doesn't have children. Draw itself
    if self.kind == nil then return end
    -- IF arb is 1, then stuff, otherwise, air.
    if self.kind ~= block_kind.air and arb == 1 then -- If not air and is time to draw matter
        local block_img = kind_images[self.kind]
        -- if self.kind == block_kind.stone then
        --     block_img = stone_img
        -- elseif self.kind == block_kind.gold then
        --     block_img = gold_img
        -- else
            -- print("uh oh : ", self.kind)
        -- end
        if __debug then assert(block_img, "Missing image for block kind!") end

        local save_mode = gfx.getImageDrawMode()
        gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
        for x=1, width/block_size do
            for y=1,width/block_size do
                block_img:draw(pos.x+block_size*(x-1),pos.y+block_size*(y-1))
            end
        end
        gfx.setImageDrawMode(save_mode)

    elseif self.kind == block_kind.air and arb == 0 then -- Is air and time to draw air
        for x=1, width/block_size do
            for y=1,width/block_size do
                air_img:draw(pos.x+block_size*(x-1) - air_margin,pos.y+block_size*(y-1) - air_margin)
            end
        end
    end



    if self.id and draw_id == true then
        local old_font = gfx.getFont()
        local col = gfx.getImageDrawMode()
        gfx.setFont(waku10)
        gfx.setImageDrawMode(gfx.kDrawModeNXOR)
        gfx.drawText(self.id,pos.x+width/2-10,pos.y+width/2)
        gfx.setImageDrawMode(col)
        gfx.setFont(old_font)
    end
end
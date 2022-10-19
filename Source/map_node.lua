-- Map resources
local node_img = gfx.image.new("./stone.pdi")
local air_margin = 5
local air_img = gfx.image.new(20 + 2*air_margin,20 + 2*air_margin, gfx.kColorWhite)

class("map_node").extends(node)

-- local next_id = 0

function map_node:init(kind)
    map_node.super.init(self,kind)

end

-- Called when the node is now the deepest in the tree (has no children. This one should render now).
function map_node:on_deepest(pos,width)
    -- self.id = next_id
    -- next_id += 1

    self.sprite = gfx.sprite.new()
    self.sprite:moveTo(pos.x,pos.y)

    self.sprite:setCollideRect(0,0,width,width)

    if self.kind == block_kind.stone then
        self.sprite:setGroups(collide_group.stone)
    else
        self.sprite:setGroups(collide_group.air)
    end
    self.sprite:add()
end

function map_node:not_deepest(pos,width)
    self.sprite:remove()
    self.sprite = nil
end


function map_node:changed_kind()
    self.sprite:resetGroupMask()
    if self.kind == block_kind.stone then
        self.sprite:setGroups(collide_group.stone)
    else
        self.sprite:setGroups(collide_group.air)
    end
end


function map_node:draw(pos,width,arb)
    -- doesn't have children. Draw itself
    if self.kind == nil then return end
    -- IF arb is 1, then stuff, otherwise, air.
    if self.kind == block_kind.stone and arb == 1 then
        local save_mode = gfx.getImageDrawMode()
        gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
        for x=1, width/block_size do
            for y=1,width/block_size do
                node_img:draw(pos.x+block_size*(x-1),pos.y+block_size*(y-1))
            end
        end
        gfx.setImageDrawMode(save_mode)

    -- else
        -- Draw wireframe for non-solid blocks
    -- gfx.drawRoundRect(pos.x,pos.y,width,width,3)
    elseif self.kind == block_kind.air  and arb == 0 then
        for x=1, width/block_size do
            for y=1,width/block_size do
                air_img:draw(pos.x+block_size*(x-1) - air_margin,pos.y+block_size*(y-1) - air_margin)
            end
        end
    end

    -- Draw its ID in the middle of the block.
    -- if self.id then
    --     local old_font = gfx.getFont()
    --     local col = gfx.getImageDrawMode()
    --     gfx.setFont(waku10)
    --     gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    --     gfx.drawText(self.id,pos.x+width/2-10,pos.y+width/2)
    --     gfx.setImageDrawMode(col)
    --     gfx.setFont(old_font)
    -- end

end
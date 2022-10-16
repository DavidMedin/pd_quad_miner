class("map_node").extends(node)

-- local next_id = 0

function map_node:init(kind)
    map_node.super.init(self,kind)

end


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


function map_node:draw(pos,width)
    -- doesn't have children. Draw itself
    if self.kind == nil then return end
    if self.kind == block_kind.stone then
        for x=1, width/block_size do
            for y=1,width/block_size do
                gfx.fillRoundRect(pos.x+block_size*(x-1),pos.y+block_size*(y-1),block_size,block_size,3)
            end
        end
    else
        gfx.drawRoundRect(pos.x,pos.y,width,width,3)
    end

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
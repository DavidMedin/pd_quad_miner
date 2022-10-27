--[[
    if children's size not zero, there *MUST* be four children.
    If the kind is nil, then the node is a parent of four children.

    If the kind is not nil, then there are no children.
]]

-- Size of blocks in pixels.
BLOCK_SIZE = 20

---@class node
---@field super Object
---@field kind block_kind
---@field deep boolean A value to indicate to call the OnDeepest or NotDeepest callback.
---@field children node[]|nil I don't know if this is right notation
node=nil
class("node",{}).extends()
---@param kind block_kind
---@param parent node
function node:init(kind,parent)
    node.super.init(self)

    if __DEBUG == true then assert(kind) end
    self.kind = kind
    self.deep = true
    self.parent = parent
end
---If it can, creates its four children.
---@param node_type node Is really a class thing. Not intended as an object.
function node:split(node_type)
    if self.children ~= nil then return end
    self.children = {node_type(self.kind,self),node_type(self.kind,self),node_type(self.kind,self),node_type(self.kind,self)}
    self.kind = nil
    self.deep = false
end

--- You may pass nothing when .deep is absolutly false.
---@param pos vec2|nil
---@param width integer|nil
function node:check_deep(pos,width)
    if self.deep == true then
        if __DEBUG then assert(type(pos) == "userdata" and type(width == "number")) end
        ---@cast pos vec2
        ---@cast width integer
        self:on_deepest(pos,width)
    elseif self.deep == false then
        self:not_deepest()
    end

    self.deep = nil
end

-- called when this node is the exposted, the bottom of the tree, whatever
---A template for a callback. Will be called whenever this node is the deepest.
---@param pos vec2
---@param width integer
function node:on_deepest(pos,width)
end

--- called when this function was deepest, and is no longer deep.
function node:not_deepest()
end

---A callback for when the kind has been changed.
---@param kind block_kind
function node:changed_kind(kind)
end

---A function to recurse from this node to a max depth, calling a function and giving arb(itrary) to it.
---@param pos vec2
---@param depth integer
---@param max_depth integer
---@param last boolean --- Whether only the deepest nodes should have func called on them.
---@param func fun(self:node,pos:vec2,width:integer,arb:any)
---@param arb any
function node:recurse(pos,depth,max_depth,last,func,arb)
    local width = 2^max_depth / 2 ^depth * BLOCK_SIZE
    --has children
    if self.kind == nil then
        for k,v in ipairs(self.children) do
            if k == 1 then
                v:recurse(pos,depth+1, max_depth,last, func,arb)
            elseif k == 2 then
                v:recurse(pos+vec2.new(width / 2,0),depth+1, max_depth,last, func,arb)
            elseif k == 3 then
                v:recurse(pos+vec2.new(0,width / 2),depth+1, max_depth,last, func,arb)
            else
                v:recurse(pos+vec2.new(width / 2,width / 2),depth+1, max_depth,last, func,arb)
            end
        end

        if last then return end
    end

    func(self,pos,width,arb)
end

---Draws the node. Can be overriden.
---@param pos vec2
---@param width integer
function node:draw(pos,width)
    -- doesn't have children. Draw itself
    -- if self.kind == 1 then
    --     gfx.fillRoundRect(pos.x,pos.y,width,width,3)
    -- else
    --     gfx.drawRoundRect(pos.x,pos.y,width,width,3)
    -- end
end


--=====================================================
--=====================================================
--=====================================================
--=====================================================

---@class quadtree
---@field super Object
---@field max_depth integer
---@field root node
---@field node_type node
---@field rect pd_rect
---@operator call(block_kind): quadtree
quadtree=nil
class("quadtree", {
    max_depth = 4, -- 64 blocks
}).extends()

---@param pos vec2
---@param kind block_kind
---@param node_type node Is really an class, not an object.
function quadtree:init(pos,kind,node_type)
    quadtree.super.init(self)

    self.rect = geom.rect.new(pos.x,pos.y,2^self.max_depth * BLOCK_SIZE,2^self.max_depth * BLOCK_SIZE)
    self.node_type = node_type
    self.root = node_type(kind,nil)
    self.root:recurse(self:get_pos(),0,self.max_depth,false, self.node_type.check_deep)

end

---@return vec2
function quadtree:get_pos()
    return vec2.new(self.rect.x,self.rect.y)
end

--- Return the quadtree's position in blocks.
---@return vec2
function quadtree:get_pos_block()
    return vec2.new(math.floor(self.rect.x/BLOCK_SIZE), math.floor(self.rect.y/BLOCK_SIZE))
end

-- uncompressed coordinate (start at (1,1). )
---Seaches down the tree, and creates node topology until it has gotten deepest.
---@param pos vec2
---@return node,node
function quadtree:create_get_node(pos)
    if __DEBUG == true then assert(pos.x ~= 0 and pos.y ~= 0) end

    local size = 2 ^ self.max_depth
    local offset = vec2.new(0,0)
    local target_node = self.root

    ---@type node
    local target_parent = nil
    for x=0,self.max_depth do
        local children_index = 0
        if pos.x > offset.x + size/ (2^x) /2 then
            children_index += 2
            offset.x += size/(2^x)/2
        else
            children_index += 1
        end

        if pos.y > offset.y+ size/(2^x)/2 then
            children_index += 2
            offset.y += size/(2^x)/2
        end

        if target_node.kind ~= nil and x ~= self.max_depth then
            -- Time to generate resolution
            target_node:split(self.node_type)
            self.root:recurse(self:get_pos(),0,self.max_depth,false, self.node_type.check_deep)

        end

        -- continue
        if x ~= self.max_depth then
            if __DEBUG == true then assert(target_node.kind == nil) end
            target_parent = target_node
            target_node = target_node.children[children_index]
        end

    end

    return target_node, target_parent
end

---returns node,closest_node,node_parent
---first part will be nil if there is no node there. closest_node will
---be the deepest depth over the position.
---@param pos vec2
---@return node|nil,node,node
function quadtree:get_node(pos)
    local size = (2^self.max_depth)
    local offset = vec2.new(0,0)
    local target_node = self.root
    ---@type node
    local target_parent = nil
    for x=0,self.max_depth do
        local children_index = 0
        if pos.x > offset.x + size/(2^x)/2 then
            children_index += 2
            offset.x += size/(2^x)/2
        else
            children_index += 1
        end

        if pos.y > offset.y+ size/(2^x)/2 then
            children_index += 2
            offset.y += size/(2^x)/2
        end

        if target_node.kind ~= nil and x ~= self.max_depth then
            return nil,target_node,target_parent
        end

        -- continue
        if x ~= self.max_depth then
            if __DEBUG == true then assert(target_node.kind == nil) end
            target_parent = target_node
            target_node = target_node.children[children_index]
        end

    end

    return target_node,target_node, target_parent
end

---Changes the kind of the specified block. May collapse the tree.
---@param pos vec2
---@param kind block_kind
---@return block_kind
function quadtree:change(pos,kind)
    local node,parent = self:create_get_node(pos)
    local old_kind = node.kind
    node.kind = kind
    node:changed_kind(kind)

    self:collapse_from_node(node)
    return old_kind
end


-- 'Bubbles' up a collapse
---@param node node
function quadtree:collapse_from_node(node)
    -- Climb the tree until it is okay to cut
    -- local node = node
    local parent = node.parent

    if node.children ~= nil then
        if __DEBUG then assert(node.kind == nil) end
        return
    end

    if node.parent == nil then
        -- is root. Don't do this on root.
        print("attempted to collapse from root")
        return
    end
    
    while parent do

        if parent.children[1].kind == node.kind and parent.children[2].kind == node.kind and parent.children[3].kind == node.kind and parent.children[4].kind == node.kind then
            parent.kind = node.kind

            -- DESTROY THE CHILDREN
            for k,v in pairs(parent.children) do
                v.deep = false
                v:check_deep()
            end
            parent.children = nil
            parent.deep = true
            
            -- recalculate deepest
            node = parent
            parent = node.parent
        else
            break
        end
    end
    self.root:recurse(self:get_pos(),0,self.max_depth,false, self.node_type.check_deep)
end
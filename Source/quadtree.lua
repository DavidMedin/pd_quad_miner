--[[
    if children's size not zero, there *MUST* be four children.
    If the kind is nil, then the node is a parent of four children.

    If the kind is not nil, then there are no children.
]]

-- Size of blocks in pixels.
BLOCK_SIZE = 20
MAX_DEPTH = 4

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
function node:changed_kind()
end

---A function to recurse from this node to a max depth, calling a function and giving arb(itrary) to it.
---@param pos vec2
---@param depth integer
---@param last boolean --- Whether only the deepest nodes should have func called on them.
---@param func fun(self:node,pos:vec2,width:integer,arb:any)
---@param arb any
function node:recurse(pos,depth,last,func,arb)
    local width = 2^MAX_DEPTH / 2 ^depth * BLOCK_SIZE
    --has children
    if self.kind == nil then
        for k,v in ipairs(self.children) do
            if k == 1 then
                v:recurse(pos,depth+1,last, func,arb)
            elseif k == 2 then
                v:recurse(pos+vec2.new(width / 2,0),depth+1,last, func,arb)
            elseif k == 3 then
                v:recurse(pos+vec2.new(0,width / 2),depth+1,last, func,arb)
            else
                v:recurse(pos+vec2.new(width / 2,width / 2),depth+1,last, func,arb)
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
---@field root node
---@field node_type node
---@field rect pd_rect
---@operator call(block_kind): quadtree
quadtree=nil
class("quadtree", {
}).extends()

---@param pos vec2
---@param kind block_kind
---@param node_type node Is really an class, not an object.
function quadtree:init(pos,kind,node_type)
    quadtree.super.init(self)

    self.rect = geom.rect.new(pos.x,pos.y,2^MAX_DEPTH * BLOCK_SIZE,2^MAX_DEPTH * BLOCK_SIZE)
    self.node_type = node_type
    self.root = node_type(kind,nil)
    self.root:recurse(self:get_pos(),0,false, self.node_type.check_deep)

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

    local size = 2 ^ MAX_DEPTH
    local offset = vec2.new(0,0)
    local target_node = self.root

    ---@type node
    local target_parent = nil
    for x=0,MAX_DEPTH do
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

        if target_node.kind ~= nil and x ~= MAX_DEPTH then
            -- Time to generate resolution
            target_node:split(self.node_type)

            --TODO: Rid of this
            self.root:recurse(self:get_pos(),0,false, self.node_type.check_deep)

        end

        -- continue
        if x ~= MAX_DEPTH then
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
    local size = (2^MAX_DEPTH)
    local offset = vec2.new(0,0)
    local target_node = self.root
    ---@type node
    local target_parent = nil
    for x=0,MAX_DEPTH do
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

        if target_node.kind ~= nil and x ~= MAX_DEPTH then
            return nil,target_node,target_parent
        end

        -- continue
        if x ~= MAX_DEPTH then
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
    node:changed_kind()

    self:collapse_from_node(node)
    return old_kind
end

---@param depth integer
---@param child_index integer
---@return vec2 -- Offset in pixels
local function get_child_offset(depth,child_index)
    assert(child_index > 0 and child_index <= 4 and depth <= 3 and depth >= 0, "Bad input for get_child_index")
    local child_size = (2^MAX_DEPTH) / (2^(depth+1)) * BLOCK_SIZE
    if child_index == 1 then
        return vec2.new(0,0)
    elseif child_index == 2 then
        return vec2.new(child_size,0)
    elseif child_index == 3 then
        return vec2.new(0,child_size)
    else
        return vec2.new(child_size,child_size)
    end
end


--- TESTS for get_child_offset
if __DEBUG then
    assert(get_child_offset(0,1) == vec2.new(0,0), "Failed get_child_offset test #1")
    assert(get_child_offset(0,2) == vec2.new(160,0), "Failed get_child_offset test #2")
    assert(get_child_offset(0,3) == vec2.new(0,160), "Failed get_child_offset test #3")
    assert(get_child_offset(0,4) == vec2.new(160,160), "Failed get_child_offset test #4")
    assert(get_child_offset(1,1) == vec2.new(0,0), "Failed get_child_offset test #5")
    assert(get_child_offset(1,2) == vec2.new(80,0), "Failed get_child_offset test #6")
    assert(get_child_offset(1,3) == vec2.new(0,80), "Failed get_child_offset test #7")
    assert(get_child_offset(1,4) == vec2.new(80,80), "Failed get_child_offset test #8")
    
    assert(get_child_offset(2,4) == vec2.new(40,40), "Failed get_child_offset test #9")
    assert(get_child_offset(3,4) == vec2.new(20,20), "Failed get_child_offset test #10")
end

--- A verbose version of change, for speed.
---@param kind block_kind
---@param ... integer
---@return block_kind
function quadtree:change_v(kind,...)
    local indices = {...}
    local node = self.root
    local pos = self:get_pos()
    local depth = 0

    --- # Size of a child (in pixels) of the block of depth 'depth'
    local child_size = 0
    for k,v in ipairs(indices) do
        child_size = (2^MAX_DEPTH) / (2^(depth+1)) * BLOCK_SIZE
        if node.children == nil then
            -- Make children (sex)
            node:split(self.node_type)
            -- Now, node and its children need a check_deep
            -- Except, I know what it will be. gottem
            node:not_deepest()
            node.deep = nil -- false is set by node:split, so set to nil.
            for child_i,node_v in ipairs(node.children) do
                local new_pos = pos + get_child_offset(depth,child_i)
                node_v:on_deepest(new_pos,child_size)
            end

        end
        node = node.children[v]
        pos += get_child_offset(depth,v)
        depth += 1
    end

    if node.children then
        for k,v in ipairs(node.children) do
            v:not_deepest()
        end
        node.children = nil
    end
    local old_kind = node.kind
    node.kind = kind
    node:on_deepest(pos,(2^MAX_DEPTH) / (2^depth) * BLOCK_SIZE)
    node:changed_kind()
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
    self.root:recurse(self:get_pos(),0,false, self.node_type.check_deep)
end
--[[
    if children's size not zero, there *MUST* be four children.
    If the kind is nil, then the node is a parent of four children.

    If the kind is not nil, then there are no children.
]]

block_size = 20

class("node",{}).extends()
function node:init(kind,parent)
    node.super.init(self)

    if __debug == true then assert(kind) end
    self.kind = kind
    self.deep = true
    self.parent = parent
end
function node:split(node_type)
    if self.children ~= nil then return end
    self.children = {node_type(self.kind,self),node_type(self.kind,self),node_type(self.kind,self),node_type(self.kind,self)}
    self.kind = nil
    self.deep = false
end

function node:check_deep(pos,width)
    if self.deep == true then
        self:on_deepest(pos,width)
    elseif self.deep == false then
        self:not_deepest(pos,width)
    end

    self.deep = nil
end

-- called when this node is the exposted, the bottom of the tree, whatever
function node:on_deepest(pos,width)
end

-- called when this function was deepest, and is no longer deep.
function node:not_deepest(pos,width)
end

function node:changed_kind(kind)
end

function node:recurse(pos,depth,max_depth,last,func,arb)
    local width = math.pow(2,max_depth) / math.pow(2,depth) * block_size
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

function node:draw(pos,width)
    -- doesn't have children. Draw itself
    if self.kind == 1 then
        gfx.fillRoundRect(pos.x,pos.y,width,width,3)
    else
        gfx.drawRoundRect(pos.x,pos.y,width,width,3)
    end
end

-- NOTE!: make sure to run a check_deep recurse after this!
function node:collapse_from_here()
    if self.parent ~= nil then -- otherwise, am root
        print("has parent")

        if self.parent.children[1].kind == self.kind and self.parent.children[2].kind == self.kind and self.parent.children[3].kind == self.kind and self.parent.children[4].kind == self.kind then
            print("collapsing")
            self.parent.kind = self.parent.children[1].kind
            for k,v in pairs(self.parent.children) do
                if v.sprite then
                    v.sprite:remove()
                end
            end
            self.parent.children = nil
            -- self.parent:collapse_from_here()
            return true

        -- else
        --     -- this one is weird. If we follow the recursion chain up, when we are done
        --     -- recursing, then the above condition is not met. As a side effect, this
        --     -- will always run.
        end
    end
    return false
end

--=====================================================
--=====================================================
--=====================================================
--=====================================================

class("quadtree", {
    max_depth = 4, -- 64 blocks
}).extends()

function quadtree:init(kind,node_type)
    quadtree.super.init(self)

    self.node_type = node_type
    self.root = node_type(kind,nil)
    self.root:recurse(vec2.new(0,0),0,self.max_depth,false, self.node_type.check_deep)

end

-- uncompressed coordinate (start at (1,1). )
function quadtree:create_get_node(pos)
    if __debug == true then assert(pos.x ~= 0 and pos.y ~= 0) end
    local size = math.pow(2,self.max_depth)
    local offset = vec2.new(0,0)
    local target_node = self.root
    local target_parent = nil
    for x=0,self.max_depth do
        local children_index = 0
        if pos.x > offset.x + size/math.pow(2,x)/2 then
            children_index += 2
            offset.x += size/math.pow(2,x)/2
        else
            children_index += 1
        end

        if pos.y > offset.y+ size/math.pow(2,x)/2 then
            children_index += 2
            offset.y += size/math.pow(2,x)/2
        end

        if target_node.kind ~= nil and x ~= self.max_depth then
            -- Time to generate resolution
            target_node:split(self.node_type)
            self.root:recurse(vec2.new(0,0),0,self.max_depth,false, self.node_type.check_deep)

        end

        -- continue
        if x ~= self.max_depth then
            if __debug == true then assert(target_node.kind == nil) end
            target_parent = target_node
            target_node = target_node.children[children_index]
        end

    end

    return target_node, target_parent
end

-- returns node,closest_node,node_parent
-- first part will be nil if there is no node there. closest_node will
-- be the deepest depth over the position.
function quadtree:get_node(pos)
    local size = math.pow(2,self.max_depth)
    local offset = vec2.new(0,0)
    local target_node = self.root
    local target_parent = nil
    for x=0,self.max_depth do
        local children_index = 0
        if pos.x > offset.x + size/math.pow(2,x)/2 then
            children_index += 2
            offset.x += size/math.pow(2,x)/2
        else
            children_index += 1
        end

        if pos.y > offset.y+ size/math.pow(2,x)/2 then
            children_index += 2
            offset.y += size/math.pow(2,x)/2
        end

        if target_node.kind ~= nil and x ~= self.max_depth then
            return nil,target_node,target_parent
        end

        -- continue
        if x ~= self.max_depth then
            if __debug == true then assert(target_node.kind == nil) end
            target_parent = target_node
            target_node = target_node.children[children_index]
        end

    end

    return target_node,target_node, target_parent
end


function quadtree:change(pos,kind)
    local node,parent = self:create_get_node(pos)
    node.kind = kind
    node:changed_kind()

    self:collapse_from_node(node)
end

function quadtree:draw()
    self.root:recurse(vec2.new(0,0),0,self.max_depth,true,self.node_type.draw,0)
    self.root:recurse(vec2.new(0,0),0,self.max_depth,true,self.node_type.draw,1)
end

-- 'Bubbles' up a collapse
function quadtree:collapse_from_node(node)
    -- Climb the tree until it is okay to cut
    local node = node
    local parent = node.parent

    if node.children ~= nil then
        if __debug then assert(node.kind == nil) end
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
    self.root:recurse(vec2.new(0,0),0,self.max_depth,false, self.node_type.check_deep)
end
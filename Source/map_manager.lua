---@deprecated
local screen_frame = gfx.image.new(SCREEN_SIZE.x,SCREEN_SIZE.y)
---@type quadtree[][]
local chunks = {}

---@type number
local chunk_size = nil -- Set in another file.
local chunk_block_count = 2^MAX_DEPTH

--- Either loads from a file or creates a chunk
---@param pos vec2 In chunk cooridiates.
local function load_chunk(pos)
    local file = pd.file.open("chunk_"..pos.x.."_"..pos.y,pd.file.kFileRead)
    if file == nil then
    else
        -- print(file:readline())
        file:close()
    end

    -- Generate new chunk!
    if chunks[pos.x] == nil then chunks[pos.x] = {} end
    chunks[pos.x][pos.y] = quadtree(pos * chunk_size,BLOCK_KIND.air, map_node)
    local chunk = chunks[pos.x][pos.y]

    -- Some generation garbage.
    chunk:change_v(BLOCK_KIND.stone,3)
    chunk:change_v(BLOCK_KIND.stone,4)
    local map_size = 2 ^ MAX_DEPTH
    
    ADD_SPHERE(chunk, vec2.new(map_size / 2, map_size / 2), 3)

    chunk:bake() -- draw to the internal image.
end

--- Writes the chunk to the filesystem and destroys it.
---@param pos vec2 Coordinates into the 'chunk' table.
local function destroy_chunk(pos)
    if __DEBUG then assert(chunks[pos.x] ~= nil and chunks[pos.x][pos.y] ~= nil, "Tried to destroy chunks that doesn't exist!") end

    local file_name = "chunk_"..pos.x.."_"..pos.y
    local file = pd.file.open(file_name,pd.file.kFileWrite)
    if file == nil then
        print ("failed to open "..file_name)
    else
        -- file:write("test")
        -- Kill all sprites
        print("destroying chunk")
        local chunk = chunks[pos.x][pos.y]
        chunk.root:recurse(chunk:get_pos(),0,false,chunk.node_type.not_deepest)
        chunks[pos.x][pos.y] = nil
        file:close()
    end
end

local load_margin = 50
local loader_rect = geom.rect.new(0,0,SCREEN_SIZE.x + load_margin, SCREEN_SIZE.y + load_margin)

--- Load, destroys, and modifies chunks accordingly.
---@param pos vec2 The position the loader_rect should be at now.
function UPDATE_CHUNKS(pos)
    chunk_size = 2^MAX_DEPTH * BLOCK_SIZE

    loader_rect.x = pos.x - loader_rect.width / 2
    loader_rect.y = pos.y - loader_rect.height / 2
    -- Go through maps to see if any are not colliding.
    -- Also go through neighboring possible chunks.
    --  If any are missing, load them!

    --#region Destroy chunks
    for kx,x in pairs(chunks) do
        if __DEBUG then assert(type(x) == "table") end

        for ky,y in pairs(x) do
            -- see if this chunk should be destroyed
            local ix,iy,iw,ih = geom.rect.fast_intersection(loader_rect.x,loader_rect.y,loader_rect.width,loader_rect.height,
            y.rect.x,y.rect.y,y.rect.width,y.rect.height)
            if ix==0 and iy==0 and iw==0 and ih==0  then
                -- The rectangle is not interstecting the loader rect! kill kill killkill kill kil kill kill kilk kill kill kilkk kill kill
                destroy_chunk(vec2.new(kx,ky))
            end
        end
    end

    --#endregion

    --#region Create chunk
    -- Get the position (in chunks) that the loader_rect is in.
        -- Get the position (in chunks) of the four(actually three) corners.
        -- With those positions, check all inbetween points too.
    local load_points = { vec2.new(loader_rect.x,loader_rect.y), vec2.new(loader_rect.x+loader_rect.width,loader_rect.y),vec2.new(loader_rect.x,loader_rect.y+loader_rect.height)}

    gfx.setColor(gfx.kColorXOR)
    for k,v in ipairs(load_points) do
        -- Snap to top-left of the enclosing chunk position.
        load_points[k] = vec2.new( math.floor(v.x / chunk_size) , math.floor(v.y/chunk_size) )

        gfx.fillCircleAtPoint(load_points[k].x,load_points[k].y,5)
        
    end
    -- Iterate through all the need-to-be loaded chunk positions.
    for x=load_points[1].x,load_points[2].x do
        for y=load_points[1].y, load_points[3].y do
            if chunks[x] == nil or chunks[x][y] == nil then

                load_chunk(vec2.new(x,y))
                
            end
        end
    end

    --#endregion

    --#region Draw Chunks
    -- for kx,x in pairs(chunks) do
    --     for ky,y in pairs(x) do
    --         local pos = y:get_pos()
    --         y.root:recurse(pos,0,true,y.node_type.draw,0)
    --     end
    -- end
    for kx,x in pairs(chunks) do
        for ky,y in pairs(x) do
            y:draw()
            -- local pos = y:get_pos()
            -- y.root:recurse(pos,0,true,y.node_type.draw,1)
        end
    end
    --#endregion
end

--- Returns the chunk(quadtree) that occupies pos.
---@param pos vec2 In Block position.
---@return quadtree | nil
function GET_CHUNK(pos)
    local chunk_pos = vec2.new(math.floor((pos.x-1)/chunk_block_count),math.floor((pos.y-1)/chunk_block_count))
    if chunks[chunk_pos.x] == nil then return nil end
    local quad = chunks[chunk_pos.x][chunk_pos.y]
    return quad
end

---@deprecated
---@param pos vec2
---@param kind block_kind
---@return block_kind|nil
function CHANGE_BLOCK(pos,kind)
    local chunk = GET_CHUNK(pos)
    if chunk then
        return chunk:change(pos - chunk:get_pos(), kind)
    else
        print("failed to get block at position");
        return nil
    end
end
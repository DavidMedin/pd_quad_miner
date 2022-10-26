-- Variables
local ind_width = 20
local ind_pos = vec2.new(SCREEN_SIZE.x-ind_width,SCREEN_SIZE.y-ind_width)

-- Resources
---@class inv : component
---@field show_inv boolean
---@field items {item: entity, count: number,txt_size:vec2}
---@field selected_item integer
---@field gui pd_gridview
---@field cell_size integer[]
---@field border_size integer
---@field content_size integer[]
inv=nil
class("inv").extends(component)
function inv:init(ent)
    inv.super.init(self,ent)
    self.show_inv = false

    -- for each new inventory, create a pickaxe, stone_item, and gold_item
    self.items = { }

    self.selected_item = 1
    self.gui = pd.ui.gridview.new()
    self.gui:setNumberOfSections(1)
    if #self.items == 0 then
        self.gui:setNumberOfColumns(1)
    else
        self.gui:setNumberOfColumns(#self.items)
    end
    self.gui:setNumberOfRows(1)

    self.cell_size = {0,0} -- Must be updated!
    self.border_size = 3
    self.content_size ={20,20}
    self:update_cell_size()

    self:set_content_inset({1,1,2,2})
    self:set_cell_padding({1,1,0,0})
    self.border_width = 3

    self:add_item(entity():add(item,PICK_ITEM)) -- Create item.

    IMGUI_ADD_ITEM("inv-bord",IMGUI_ITEM_KIND.integer,function(new_val)
        self:set_border_size(new_val)
     end,3)
     IMGUI_ADD_ITEM("inset",IMGUI_ITEM_KIND.integer,function(new_val)
        self:set_content_inset {new_val-1,new_val-1,new_val,new_val}
     end,2)


    self.gui.drawCell = function(cell,section, row, column, selected, x, y, width, height)
        gfx.pushContext()
            gfx.setLineWidth(self.border_size)
            if selected then gfx.setColor(gfx.kColorBlack) else gfx.setColor(gfx.kColorWhite) end
            gfx.fillRoundRect(x+self.border_size,y+self.border_size,self.content_size[1],self.content_size[1],4)
            gfx.setColor(gfx.kColorBlack)
            local border_offset = math.floor(self.border_size/2)
            gfx.drawRoundRect(x+border_offset,y+border_offset,width-border_offset*2,height-border_offset*2,4)

            local entry = self.items[column]
            local item = entry.item
            local img_w,img_h = item.item.icon:getSize()
            if selected then gfx.setImageDrawMode(gfx.kDrawModeInverted) else gfx.setImageDrawMode(gfx.kDrawModeCopy) end
            
            -- TODO: draw count of item
            item.item.icon:draw(x + width/2 - img_w/2,y+ height/2 - img_h/2)
            gfx.setImageDrawMode(gfx.kDrawModeNXOR)

            WAKU10:drawText(tostring(entry.count),x + width/2 - img_w/2 + (self.content_size[1] - entry.txt_size.x),y+ height/2 - img_h/2 + (self.content_size[2]-entry.txt_size.y))
        gfx.popContext()
    end--drawCell
end-- init

---@param value integer
function inv:set_border_size(value)
    self.border_size = value
    self:update_cell_size()
end
---@param value integer[]
function inv:set_content_size(value)
    self.content_size = value
    self:update_cell_size()
end
---@param value integer[]
function inv:set_content_inset(value)
    self.content_inset = value
    self.gui:setContentInset( table.unpack(value) )
end
---@param value integer[]
function inv:set_cell_padding(value)
    self.cell_padding = value
    self.gui:setCellPadding( table.unpack(value) )
end

---@return {item: entity, count: number}
function inv:get_selected_item()
    return self.items[self.selected_item]
end


-- Please only give this function an item has one reference, thank you!
---@param item entity
function inv:add_item(item)
    for k,v in ipairs(self.items) do
        -- May want a stronger way of checking equality (for unique items)
        if v.item:get"item".name == item:get"item".name then
            v.count += 1
            v.txt_size.x = WAKU10:getTextWidth(v.count)
            return
        end
    end

    -- Item is not already in, push it.
    item:get"item".inv = self
    table.insert(self.items,{item=item,count=1,txt_size= vec2.new( WAKU10:getTextWidth("1"),WAKU10:getHeight()) })

    self.gui:setNumberOfColumns(#self.items)
end

---@param item_name string
function inv:remove_item(item_name)
    for k,v in pairs(self.items) do
        if v.item:get"item".name == item_name then
            v.count -= 1;
            if v.count == 0 then
                local new_item_count = #self.items - 1
                if new_item_count == 0 then new_item_count = 1 end
                self.gui:setNumberOfColumns(new_item_count)

                self.selected_item = 0 -- Require user input to change item.

                table.remove(self.items,k)
            else
                v.txt_size.x = WAKU10:getTextWidth(v.count)
            end
        end
    end
end


function inv:update_cell_size()
    local border_add = self.border_size * 2
    -- local border_add = math.floor(#self.border_size/2) * 2
    self.cell_size[1] = self.content_size[1] + border_add
    self.cell_size[2] = self.content_size[2] + border_add
    self.gui:setCellSize( table.unpack(self.cell_size) )
end

-- Returns the size of the menu
function inv:get_size()
    local item_count = #self.items
    if item_count == 0 then item_count = 1 end

    local menu_width = item_count * ( self.cell_padding[1] + self.cell_padding[2] +self.cell_size[1] )
        + self.content_inset[1] + self.content_inset[2] -- Fun border math.
    local menu_height = 1 * ( self.cell_padding[3] + self.cell_padding[4] + self.cell_size[2] )
        + self.content_inset[3] + self.content_inset[4]
    
    return menu_width,menu_height
end

-- Returns the top left corner of the menu.
function inv:get_bounds()
    local menu_width,menu_height = self:get_size()
        
    local x = SCREEN_SIZE.x/2 - menu_width/2
    local y = SCREEN_SIZE.y/2 - menu_height/2

    return x,y,menu_width,menu_height
end


function inv:get_control()
    print "Inventory taking control!"
    pd.inputHandlers.push({
        BButtonDown = function()
            self:close_inv()
        end,
        AButtonDown = function()
            local section,row,column = self.gui:getSelection()
            if column < 1 or column > #self.items then return end
            self.selected_item = column
            self:close_inv()
        end,
        leftButtonDown = function()
            self.gui:selectPreviousColumn(true)
        end,
        rightButtonDown = function()
            self.gui:selectNextColumn(true)
        end,
    },true)
end

function inv:close_inv()
    pd.inputHandlers.pop()
    self.show_inv = false
end
function inv:open_inv()
    self.show_inv = true
    self:get_control()
end


function inv:draw_inv()
    if self.show_inv == true then
        local x,y,w,h = self:get_bounds()
        local border_width = 3 -- frame border size
        local half_border = math.floor(border_width/2)
        local width_add = half_border * 2
        gfx.pushContext()
        gfx.setLineWidth(border_width)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(x-half_border,y-half_border,w+width_add,h+width_add,4)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRoundRect(x-half_border,y-half_border,w+width_add,h+width_add,4)
        gfx.popContext()
        self.gui:drawInRect(x,y,w,h)
    end
end


function inv:draw_indicator()
    gfx.setLineWidth(self.border_width)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(ind_pos.x,ind_pos.y,ind_width,ind_width,4)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(ind_pos.x,ind_pos.y,ind_width,ind_width,4)

    if self.selected_item ~= 0 and #self.items ~= 0 then
        local item = self.items[self.selected_item].item
        item.item.icon:draw(ind_pos.x,ind_pos.y)
    end
end


function inv:draw()
    gfx.pushContext()
    gfx.setDrawOffset(0,0)

    self:draw_indicator()
    self:draw_inv()

    gfx.popContext()
end
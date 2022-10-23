-- Variables
local ind_pos
local ind_width = property {
    set = function(tabl,value)
        tabl.val = value
        ind_pos = vec2.new(screen_size.x-value,screen_size.y-value)
    end
}
ind_width <<= 20

imgui_add_item("inv-ind",imgui_item_kind.integer,function(new_val)
    ind_width <<= new_val
 end,#ind_width)


-- Resources
local pick_img = gfx.image.new("images/pick.pdi")

class("inv").extends(component)
function inv:init(entity)
    inv.super.init(self,entity)
    self.show_inv = false

    self.items = {{img=pick_img,kind=block_kind.air},{img=stone_img,kind=block_kind.stone},{img=gold_img,kind=block_kind.gold}}
    self.selected_item = 1
    self.gui = pd.ui.gridview.new()
    self.gui:setNumberOfSections(1)
    self.gui:setNumberOfColumns(3)
    self.gui:setNumberOfRows(1)

    self.border_size = property {
        set = function(prop,value)
            prop.val = value
            self:update_cell_size()
        end
    }
    self.content_size = property {
        set = function(prop,value)
            prop.val = value
            self:update_cell_size()
        end
    }
    self.content_inset = property {
        set = function(prop,value)
            prop.val = value
            self.gui:setContentInset( table.unpack(prop.val) )
        end
    }
    self.cell_padding = property {
        set = function(prop,value)
            prop.val = value
            self.gui:setCellPadding( table.unpack(prop.val) )
        end
    }
    self.cell_size = {0,0} -- Must be updated!
    self.border_size.val = 3 -- <-----both must be defined for cell size. (ignore prop) 
    self.content_size <<= {20,20}--<-|

    self.content_inset <<= {1,1,2,2}
    self.cell_padding <<= {1,1,0,0}
    self.border_width = 3

    imgui_add_item("inv-bord",imgui_item_kind.integer,function(new_val)
        self.border_size <<= new_val
     end,3)
     imgui_add_item("inset",imgui_item_kind.integer,function(new_val)
        self.content_inset <<= {new_val,new_val,new_val,new_val}
     end,0)


    self.gui.drawCell = function(cell,section, row, column, selected, x, y, width, height)
        gfx.pushContext()
            gfx.setLineWidth(#self.border_size)
            if selected then gfx.setColor(gfx.kColorBlack) else gfx.setColor(gfx.kColorWhite) end
            gfx.fillRoundRect(x+#self.border_size,y+#self.border_size,(#self.content_size)[1],(#self.content_size)[1],4)
            gfx.setColor(gfx.kColorBlack)
            local border_offset = math.floor(#self.border_size/2)
            gfx.drawRoundRect(x+border_offset,y+border_offset,width-border_offset*2,height-border_offset*2,4)

            local item = self.items[column]
            local img_w,img_h = item.img:getSize()
            if selected then gfx.setImageDrawMode(gfx.kDrawModeInverted) else gfx.setImageDrawMode(gfx.kDrawModeCopy) end
            
            item.img:draw(x + width/2 - img_w/2,y+ height/2 - img_h/2)
        gfx.popContext()
    end--drawCell
end-- init


function inv:update_cell_size()
    local border_add = #self.border_size * 2
    -- local border_add = math.floor(#self.border_size/2) * 2
    self.cell_size[1] = (#self.content_size)[1] + border_add
    self.cell_size[2] = (#self.content_size)[2] + border_add
    self.gui:setCellSize( table.unpack(self.cell_size) )
end

-- Returns the size of the menu
function inv:get_size()
    local item_count = #self.items
    if item_count == 0 then item_count = 1 end

    local menu_width = item_count * ( (#self.cell_padding)[1] + (#self.cell_padding)[2] +self.cell_size[1] )
        + (#self.content_inset)[1] + (#self.content_inset)[2] -- Fun border math.
    local menu_height = 1 * ( (#self.cell_padding)[3] + (#self.cell_padding)[4] + self.cell_size[2] )
        + (#self.content_inset)[3] + (#self.content_inset)[4]
    
    return menu_width,menu_height
end

-- Returns the top left corner of the menu.
function inv:get_bounds()
    local menu_width,menu_height = self:get_size()
        
    local x = screen_size.x/2 - menu_width/2
    local y = screen_size.y/2 - menu_height/2

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
    gfx.fillRoundRect(ind_pos.x,ind_pos.y,#ind_width,#ind_width,4)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(ind_pos.x,ind_pos.y,#ind_width,#ind_width,4)

    self.items[self.selected_item].img:draw(ind_pos.x,ind_pos.y)
end


function inv:draw()
    gfx.pushContext()
    gfx.setDrawOffset(0,0)

    self:draw_indicator()
    self:draw_inv()

    gfx.popContext()
end
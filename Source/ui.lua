-- file variables
local imgui_width = screen_size.x * 0.30
local control_layers = 0
local font_size = 15

-- Enums
imgui_item_kind = {
    button=1,
    integer=2,
    float=3,
    drop_down=4,
    text=5
}

-- ================ Playdate Menu
menu = pd.getSystemMenu()
local in_menu = false

class("gui").extends()
function gui:init(pos,size)
    gui.super.init(self)

    if __debug then assert(pos.x,pos.y) end
    self.pos = pos
    self.size = size or vec2.new(imgui_width,screen_size.y)
    self.imgui = pd.ui.gridview.new(0,40)
    self.defer_drop_down = false -- funny property
    self.selected_down = false
    self.content = {}

    self.imgui:setCellPadding(3,3,1,1)
    self.imgui:setContentInset(0,0,2,0)

    self.imgui:setNumberOfRows(1)

    self.imgui:setCellSize(0, font_size)

    -- Selection context
    self.imgui:setSelectedRow(1)

    self.imgui.drawCell = function(cell,section, row, column, selected, x, y, width, height)
        local select_gfx = function(selected)
            -- LOCAL selected. Not drawCell Argument selected.
            if not selected then gfx.setColor(gfx.kColorWhite) else gfx.setColor(gfx.kColorBlack) end
            if selected then gfx.setImageDrawMode(gfx.kDrawModeFillWhite) end
        end
        gfx.pushContext()
            gfx.setLineWidth(2)
            local item = nil
            if #self.content == 0 then
                item = {name="*empty*",kind=imgui_item_kind.text}
            else
                item = self.content[row]
            end

            if self.selected_down and selected then
                select_gfx(false)
                gfx.fillRoundRect(x,y,width,height,5)
                select_gfx(true)
                gfx.drawRoundRect(x,y,width,height,5)

                gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
                if item.kind == imgui_item_kind.integer or item.kind == imgui_item_kind.float  then
                    gfx.drawTextInRect(item.name .. " : " .. item.value,x,y,width,height,nil,nil,kTextAlignment.center,waku15)
                else
                    gfx.drawTextInRect(item.name,x,y,width,height,nil,nil,kTextAlignment.center,waku15)
                end
            elseif selected then
                select_gfx(true)
                gfx.fillRoundRect(x,y,width,height,5)
                if item.kind == imgui_item_kind.integer or item.kind == imgui_item_kind.float  then
                    gfx.drawTextInRect(item.name .. " : " .. item.value,x,y,width,height,nil,nil,kTextAlignment.center,waku15)
                else 
                    gfx.drawTextInRect(item.name,x,y,width,height,nil,nil,kTextAlignment.center,waku15)
                end
            else
                select_gfx(false)
                if item.kind == imgui_item_kind.integer or item.kind == imgui_item_kind.float  then
                    gfx.drawTextInRect(item.name .. " : " .. item.value,x,y,width,height,nil,nil,kTextAlignment.center,waku15)
                else
                    gfx.drawTextInRect(item.name,x,y,width,height,nil,nil,kTextAlignment.center,waku15)
                end
            end

        gfx.popContext()
        -- end of drawCell
    end

    -- end of init
end

--button : func arbitrary_data
--integer : func default_val
--float : func default_val
--text : text
--drop_down : {options}
function gui:add_item(name,kind,...)
    local args = {...}
    local item = {name=name,kind=kind}
    if item.kind == imgui_item_kind.button then
        item.func = args[1]
        item.arb = args[2]
    end
    if item.kind == imgui_item_kind.integer or item.kind == imgui_item_kind.float then
        item.func = args[1]
        item.value = args[2] or 0
    end
    if item.kind == imgui_item_kind.drop_down then
        if __debug then assert(type(args[1]) == "table") end
        item.options = args[1]
    end
    table.insert(self.content, item)
    self.imgui:setNumberOfRows(#self.content or 1)
end

function gui:draw()

    local draw_offset = {gfx.getDrawOffset()}
    gfx.setDrawOffset(0,0)

    gfx.fillRoundRect(self.pos.x,self.pos.y,self.size.x,self.size.y, 5)
    gfx.pushContext()
        gfx.setColor(gfx.kColorBlack)
        gfx.setLineWidth(3)
        gfx.drawRoundRect(self.pos.x,self.pos.y,self.size.x,self.size.y,5)
    gfx.popContext()

    -- draw IMGUI to image
    local frame = gfx.image.new(self.size.x,self.size.y)
    gfx.pushContext(frame)
        self.imgui:drawInRect(0,0,self.size.x,self.size.y)
    gfx.popContext()

    -- -- funny mods

    -- -- draw IMGUI to screen
    frame:draw(self.pos.x,self.pos.y)
    

    gfx.setDrawOffset(table.unpack(draw_offset))

    if self.defer_drop_down == true then
        local section,row,column = self.imgui:getSelection()
        local item = self.content[row]
        local x,y,width,height = self.imgui:getCellBounds(section,row,1,imgui_width)

        -- Create new UI
        self.drop_down = gui(vec2.new(imgui_width,y), vec2.new(imgui_width,#item.options*(font_size+2)  + 4))
        for k,v in ipairs(item.options) do -- populate with data
            self.drop_down:add_item(v.name,imgui_item_kind.button,v.func,k)
        end
        -- become the interactee
        self.drop_down:push_controls(true)
        control_layers += 1

        self.defer_drop_down = false
    end

    if self.drop_down then self.drop_down:draw() end
end


function gui:push_controls(drop_down)
    pd.inputHandlers.push( {
        -- Menu controls
        upButtonDown = function()
            self.imgui:selectPreviousRow(true)
        end,
        downButtonDown = function()
            self.imgui:selectNextRow(true)
        end,

        leftButtonUp = function()
            local section,row,column = self.imgui:getSelection()
            local item = self.content[row]
            if item.kind == imgui_item_kind.integer or item.kind == imgui_item_kind.float then
                item.value -= 1
                item.func(item.value)
            end
        end,
        rightButtonUp = function()
            local section,row,column = self.imgui:getSelection()
            local item = self.content[row]
            if item.kind == imgui_item_kind.integer or item.kind == imgui_item_kind.float then
                item.value += 1
                item.func(item.value)
            end
        end,

        cranked = function(change,acceleratedChange)
            local section,row,column = self.imgui:getSelection()
            local item = self.content[row]
            if item.kind == imgui_item_kind.float then
                item.value += acceleratedChange * 0.01 -- subject to change
                item.func(item.value)
            end
        end,

        AButtonDown = function()
            self.selected_down = true
        end,
        AButtonUp = function()
            self.selected_down = false
            -- Do action. Do the function in imgui_context
            local section,row,column = self.imgui:getSelection()
            local item = self.content[row]
            if item.kind == imgui_item_kind.button then
                item.func(item.arb)
            elseif item.kind == imgui_item_kind.drop_down then
                self.defer_drop_down = true
            end
            if drop_down == true then
                pd.inputHandlers.pop()
                control_layers -= 1
                get_imgui().drop_down = nil
            end
        end,

        BButtonDown = function()
            if drop_down then
                pd.inputHandlers.pop()
                control_layers -= 1
                get_imgui().drop_down = nil
            end
        end
    }, true ) -- totally override controls.
end

local imgui = gui(vec2.new(0,0))

function get_imgui()
    return imgui
end
function imgui_add_item(name,kind,...)
    imgui:add_item(name,kind,...)
end
function draw_ui()
    imgui:draw()
end

menu:addMenuItem("Inspector",function()
    -- NOTE: Overrides input.lua's input handler!
    -- NOTE: Can be overriden by drop-down menus!
    if in_menu == false then
        imgui:push_controls()
        control_layers += 1
    else
        for i=1,control_layers do
            pd.inputHandlers.pop()
        end
        control_layers = 0
        imgui.drop_down = nil -- rid of it!
        collectgarbage("collect")
    end
    in_menu= not in_menu
end)

-- TODO: Draw symbols
-- TODO: (Very difficult) arbitrarily combine neighboring cells.
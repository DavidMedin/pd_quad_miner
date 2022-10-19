-- ================ Playdate Menu
menu = pd.getSystemMenu()
local in_menu = false
menu:addMenuItem("Inspector",function()
    -- NOTE: Overrides input.lua's input handler!
    print "Clicked!"

    if in_menu == false then
        pd.inputHandlers.push( {
            -- Menu controls
            upButtonDown = function()
                imgui:selectPreviousRow(true)
            end,
            downButtonDown = function()
                imgui:selectNextRow(true)
            end,
        }, true ) -- Don't use hero controls at all.
    else
        pd.inputHandlers.pop() 
    end
    in_menu= not in_menu
end)

local imgui_width = screen_size.x * 0.20

imgui = pd.ui.gridview.new(0,40)
imgui:setCellPadding(3,3,1,1)
imgui:setContentInset(0,0,2,0)

imgui_content = {"Item 1", "thingy", "variable"}
imgui:setNumberOfRows(#imgui_content)
local font_size = 15
imgui:setCellSize(0, font_size)


-- Selection context
imgui:setSelectedRow(1)



function imgui:drawCell(section,row,column,selected,x,y,width,height)
    gfx.pushContext()
        if selected then gfx.setColor(gfx.kColorWhite) else gfx.setColor(gfx.kColorBlack) end
        gfx.fillRoundRect(x,y,width,height,5)

        if not selected then gfx.setImageDrawMode(gfx.kDrawModeFillWhite) end
        gfx.drawTextInRect(imgui_content[row],x,y,width,height,nil,nil,kTextAlignment.center,waku15)
    gfx.popContext()

end

function draw_ui()

    local draw_offset = {gfx.getDrawOffset()}
    gfx.setDrawOffset(0,0)

    gfx.fillRoundRect(0,0,imgui_width,screen_size.y, 5)
    gfx.pushContext()
        gfx.setColor(gfx.kColorBlack)
        gfx.setLineWidth(3)
        gfx.drawRoundRect(0,0,imgui_width,screen_size.y,5)
    gfx.popContext()

    -- draw IMGUI to image
    local frame = gfx.image.new(imgui_width,screen_size.y)
    gfx.pushContext(frame)
        imgui:drawInRect(0,0,imgui_width,screen_size.y)
    gfx.popContext()

    -- -- funny mods

    -- -- draw IMGUI to screen
    frame:draw(0,0)
    

    gfx.setDrawOffset(table.unpack(draw_offset))
end

-- grid = pd.ui.gridview.new(50,50)
-- grid:setNumberOfColumns(3)
-- grid:setNumberOfRows(2,4,3,5)
-- grid:setSectionHeaderHeight(24)
-- grid:setContentInset(1, 4, 1, 4)
-- grid:setCellPadding(4, 4, 4, 4)
-- grid.changeRowOnColumnWrap = false





-- local menuOptions = {"Sword", "Shield", "Arrow", "Sling", "Stone", "Longbow", "MorningStar", "Armour", "Dagger", "Rapier", "Skeggox", "War Hammer", "Battering Ram", "Catapult"}
-- listview = playdate.ui.gridview.new(0, 10)
-- -- listview.backgroundImage = playdate.graphics.nineSlice.new('hero', 20, 23, 92, 28)
-- listview:setNumberOfRows(#menuOptions)
-- listview:setCellPadding(0, 0, 13, 10)
-- listview:setContentInset(24, 24, 13, 11)

-- function listview:drawCell(section, row, column, selected, x, y, width, height)
--         if selected then
--                 gfx.fillRoundRect(x, y, width, 20, 4)
--                 gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
--         else
--                 gfx.setImageDrawMode(gfx.kDrawModeCopy)
--         end
--         gfx.drawTextInRect(menuOptions[row], x, y+2, width, height, nil, "...", kTextAlignment.center)
-- end
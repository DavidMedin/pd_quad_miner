local input_listeners = {}
setmetatable(input_listeners, {__mode = "v"})

--[[
    User beware!
    This file contains a function, new_input_listeners.
    When you call it, it will return a table of items that
    will change with input. Cool!
]]

function new_input_listener()
    new_tab = {}
    table.insert(input_listeners,new_tab)
    return new_tab
end

 
 local hero_control_handles = {
    
 
    AButtonDown = function()
        for k,v in pairs(input_listeners) do
            v.aDown = true
            if v.aOnDown then
                v.aOnDown()
            end
        end
       
    end,
    AButtonUp = function ()
        for k,v in pairs(input_listeners) do
            v.aDown = false
        end
    end,
    BButtonDown = function()
    --    action_change(block_kind.stone)
        for k,v in pairs(input_listeners) do
            v.bDown = true
        end
    end,
    BButtonUp = function()
        for k,v in pairs(input_listeners) do
            v.bDown = false
        end
    end,
 
    leftButtonDown = function()
        for k,v in pairs(input_listeners) do
            v.leftDown = true
        end
    end,
    leftButtonUp = function()
        for k,v in pairs(input_listeners) do
            v.leftDown = false
        end
    end,

    rightButtonDown = function()
        for k,v in pairs(input_listeners) do
            v.rightDown = true
        end
    end,
    rightButtonUp = function()
        for k,v in pairs(input_listeners) do
            v.rightDown = false
        end
    end,

    upButtonDown = function()
        for k,v in pairs(input_listeners) do
            v.upDown = true
        end
        
        if b_timer ~= nil or hero.transform.colliding == false then return end
        b_timer = pd.timer.new(125, function() b_timer = nil end)
        b_timer.updateCallback = function(timer)
            hero.transform.accel -= vec2.new(0,6)
        end
    end,
    upButtonUp = function()
        for k,v in pairs(input_listeners) do
            v.upDown = false
        end
    end,

    downButtonDown = function()
        for k,v in pairs(input_listeners) do
            v.downDown = true
        end
    end,
    downButtonUp = function()
        for k,v in pairs(input_listeners) do
            v.downDown = false
        end
    end,
 }
 
 -- NOTE! : main.lua's Menu will override these controls!
 pd.inputHandlers.push(hero_control_handles)

 function reset_input()
    hero_control_handles.upButtonUp()
    hero_control_handles.downButtonUp()
    hero_control_handles.AButtonUp()
    hero_control_handles.BButtonUp()
    hero_control_handles.leftButtonUp()
    hero_control_handles.rightButtonUp()
end
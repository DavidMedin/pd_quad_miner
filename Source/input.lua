---@class input_listener
---@field aDown boolean
---@field aUp boolean
---@field aOnDown fun()|nil
---@field bDown boolean
---@field bUp boolean
---@field upDown boolean
---@field upUp boolean
---@field downDown boolean
---@field downUp boolean
---@field leftDown boolean
---@field leftUp boolean
---@field rightDown boolean
---@field rightUp boolean

local input_listeners = {}
setmetatable(input_listeners, {__mode = "v"})

--[[
    User beware!
    This file contains a function, new_input_listeners.
    When you call it, it will return a table of items that
    will change with input. Cool!
]]

---@return input_listener
function NEW_INPUT_LISTENER()
    local new_tab = {}
    table.insert(input_listeners,new_tab)
    return new_tab
end


-- Gets the dpad as a vector. (Only one button can be pressed)
---@return vec2
function BUTTON_DIR()
    local butt = {pd.buttonIsPressed(pd.kButtonUp),
          pd.buttonIsPressed(pd.kButtonDown),
          pd.buttonIsPressed(pd.kButtonRight),
          pd.buttonIsPressed(pd.kButtonLeft)
    }
    local true_count = 0
    for k,v in ipairs(butt) do if v == true then true_count += 1 end end
    if true_count ~= 1 then
        return vec2.new(0,0)
    end

    local block_pos = vec2.new(0,0)
    if butt[1] == true then
        block_pos.y -= 1
    elseif butt[2] == true then
        block_pos.y += 1
    elseif butt[3] == true then
        block_pos.x += 1
    elseif butt[4] == true then
        block_pos.x -= 1
    end

    return block_pos
 end
 
 local b_timer
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
        
        if b_timer ~= nil or HERO.transform.colliding == false then return end
        b_timer = pd.timer.new(125, function() b_timer = nil end)
        b_timer.updateCallback = function(timer)
            HERO.transform.accel -= vec2.new(0,6)
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

 function RESET_INPUT()
    hero_control_handles.upButtonUp()
    hero_control_handles.downButtonUp()
    hero_control_handles.AButtonUp()
    hero_control_handles.BButtonUp()
    hero_control_handles.leftButtonUp()
    hero_control_handles.rightButtonUp()
end
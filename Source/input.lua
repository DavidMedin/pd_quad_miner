local input_listeners = {}
setmetatable(input_listeners, {__mode = "v"})

function new_input_listener()
    new_tab = {}
    table.insert(input_listeners,new_tab)
    return new_tab
end

function action_change(kind)
    local butt = {pd.buttonIsPressed(pd.kButtonUp),
          pd.buttonIsPressed(pd.kButtonDown),
          pd.buttonIsPressed(pd.kButtonRight),
          pd.buttonIsPressed(pd.kButtonLeft)
       }
    local true_count = 0
    for k,v in ipairs(butt) do if v == true then true_count += 1 end end
    if true_count ~= 1 then
        return
    end

    local hero_grid = vec2.new(math.ceil(hero.transform.pos.x / 20), math.ceil(hero.transform.pos.y/ 20))
    local block_pos = hero_grid
    if butt[1] == true then
        block_pos.y -= 1
    elseif butt[2] == true then
        block_pos.y += 1
    elseif butt[3] == true then
        block_pos.x += 1
    elseif butt[4] == true then
        block_pos.x -= 1
    end

    map:change(block_pos,kind)
 end
 
 local hero_control_handles = {
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
 
    AButtonDown = function()
       action_change(block_kind.air)
       mine_sound()
    end,
    BButtonDown = function()
       action_change(block_kind.stone)
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

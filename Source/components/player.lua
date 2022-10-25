---@class player : component
player=nil
class("player",
	{

    }
).extends(component)

function player:init(entity)
    player.super.init(self,entity)

    self.input = NEW_INPUT_LISTENER()

    -- Use selected item on aDown
    self.input.aOnDown = function()
        if self.entity:get "inv" then
            local item_entry = self.entity:get "inv":get_selected_item()
            if item_entry then
                item_entry.item:get "item":on_use()
            end
        end
    end
end

function player:update()
    local x,y  = 0,0
    local speed = 1
    
    if self.input.rightDown == true then
        x += 1
    end
    if self.input.leftDown == true then
        x -= 1
    end

    if self.entity:get "inv" and self.input.bDown == true then
        RESET_INPUT() -- Sets every listener's "rightDown" and such to false.
        self.entity:get"inv":open_inv() -- Will take control of input.
    end

    local vector = vec2.new(x,y)
    vector:normalize()

    ---@diagnostic disable-next-line complaining about *= stuff
    vector *= speed

    
    if self.entity:get"transform" then
        self.entity:get"transform":ApplyForce(vector)
        -- self.entity.transform:Move(vector)
    else
        print("No transform for the player!")
    end

    gfx.drawCircleAtPoint( GetPoint(self.entity:get"transform".pos) , 5)

end


class("player",
	{

    }
).extends(component)

function player:init(entity)
    player.super.init(self,entity)

    self.input = new_input_listener()

    -- Use selected item on aDown
    self.input.aOnDown = function()
        if self.entity.inv then
            local item = self.entity.inv:get_selected_item()
            if item then
                item.item:on_use()
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

    if self.entity.inv and self.input.bDown == true then
        reset_input() -- Sets every listener's "rightDown" and such to false.
        self.entity.inv:open_inv() -- Will take control of input.
    end

    local vector = vec2.new(x,y)
    vector:normalize()
    vector *= speed

    
    if self.entity.transform then
        self.entity.transform:ApplyForce(vector)
        -- self.entity.transform:Move(vector)
    else
        print("No transform for the player!")
    end

    gfx.drawCircleAtPoint( GetPoint(self.entity.transform.pos) , 5)

end
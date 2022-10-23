local function action_change(kind)
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

class("player",
	{

    }
).extends(component)

function player:init(entity)
    player.super.init(self,entity)

    self.input = new_input_listener()
    self.input.aOnDown = function()
        if self.entity.inv then
            action_change(self.entity.inv.items[self.entity.inv.selected_item].kind)
            mine_sound()
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
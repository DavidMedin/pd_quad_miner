class("player",
	{

    }
).extends(component)

function player:init(entity)
    player.super.init(self,entity)


end

function player:update()
    local x,y  = 0,0
    local speed = 1

    -- if pd.buttonIsPressed(pd.kButtonUp) then
    --     y -= 1
    -- end
    -- if pd.buttonIsPressed(pd.kButtonDown) then
    --     y += 1
    -- end
    if pd.buttonIsPressed(pd.kButtonRight) then
        x += 1
    end
    if pd.buttonIsPressed(pd.kButtonLeft) then
        x -= 1
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
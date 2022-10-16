class("camera",{}).extends(component)

function camera:init(entity)
    camera.super.init(self,entity)

    -- modify self
end

function camera:activate()
    local transform = self.entity.transform.pos
    gfx.setDrawOffset(-transform.x + screen_size.x/2,-transform.y + screen_size.y/2)
end

function camera:deactivate()
    gfx.setDrawOffset(0,0)
end
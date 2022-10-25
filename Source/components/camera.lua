---@class camera : component
camera=nil
class("camera",{}).extends(component)

function camera:init(entity)
    camera.super.init(self,entity)

    -- modify self
end

function camera:activate()
    local transform = self.entity:get "transform" .pos
    gfx.setDrawOffset(-transform.x + SCREEN_SIZE.x/2,-transform.y + SCREEN_SIZE.y/2)
end

function camera:deactivate()
    gfx.setDrawOffset(0,0)
end
function WRAP(a,b)
    local q = a % b
    if q < 0 then
        return WRAP(a+b,b)
    end
    return q
end
-- arm
---@class Arm : component
---@field pos vec2
---@field deg number
---@field target_deg number
---@field len number
---@field child? Arm
---@field parent? Arm
---@field size1 number
---@field size2 number
---@field torque number
---@field ang_vel number
Arm = nil
class("Arm",{pos=vec2.new(200,100)
            ,deg=0,target_deg=0
            ,len=40
            -- ,child,parent
            ,size1=20,size2=8
            ,torque=0,ang_vel=0}).extends(component)
print("Arm : " .. tostring(Arm))
function Arm:getArmEnd(angleOffset)
    angleOffset = angleOffset or 0
    return self.pos + vec2.new(cos(self.deg+angleOffset),sin(self.deg+angleOffset))*self.len
end
function Arm:midpoint()
    return self.pos+vec2.new(cos(self.deg)*self.len/2,sin(self.deg)*self.len/2)
end
function Arm:Bechild(child)
    self.child = child
    self.child.parent = self
    self.child.pos = self:getArmEnd()
    self.child.size1 = self.size2
    if self.child.child ~= nil then
        -- fix the grandchildren
        self.child:Bechild(self.child.child)
    end
    return self
end
function Arm:draw(index)
    local angle = self.deg
    gfx.drawArc(self.pos.x,self.pos.y,self.size1,-180+angle,angle)
    local arm_end = self:getArmEnd(0)
    gfx.drawArc(arm_end.x,arm_end.y, self.size2,angle,angle+180)
    local one90 = self.pos + vec2.new(cos(angle + 90) , sin(angle+90)) * self.size1
    local oneN90 = self.pos + vec2.new(cos(angle - 90) , sin(angle-90))* self.size1
    local two90 = arm_end + vec2.new(cos(angle + 90) , sin(angle+90)) * self.size2
    local twoN90 = arm_end + vec2.new(cos(angle - 90) , sin(angle-90))* self.size2
    gfx.drawLine(one90.x,one90.y,two90.x,two90.y)
    gfx.drawLine(oneN90.x,oneN90.y,twoN90.x,twoN90.y)
    if self.child then self.child:draw(index+1) end
end

local function deadZone(offset,angle)
    local diff = ANGLES_DIFF(angle,offset)
    local limit = 40
    if ANGLES_LEFT(offset,angle)  and diff > 180-limit then
        angle = WRAP(offset-180+limit,360)
    end
    if ANGLES_RIGHT(offset,angle) and diff > 180-limit then
        angle = WRAP(offset-180-limit,360)
    end
    return angle
end

function Arm:rotate(change,length)
    self.target_deg += change
    self.target_deg = WRAP(self.target_deg,360)
    
    if self.parent ~= nil then self.target_deg = deadZone(self.parent.deg,self.parent.deg + self.target_deg) - self.parent.deg end
end

local game_scale = 0.6
GRAVITY = 9.8
local grav_togg = false
local elastic_modes = {{friction=0.9,elastic=0.5,name="more-elastic",length=2}
,{friction=0.8,elastic=1.1,name="robotic",length=2}}
local selected_mode = 2
function Arm:update(top)
    --calculate torque from distance from target
    local friction = elastic_modes[selected_mode].friction
    local elastic = elastic_modes[selected_mode].elastic
    local length = elastic_modes[selected_mode].length
    do
       local parent_deg = (self.parent or {deg=0}).deg
       print(parent_deg)
        local target = WRAP( parent_deg + self.target_deg , 360)
        local diff = SIGN_ANGLES_DIFF(target , self.deg)
        
        self.torque = (elastic * diff) / length
    end
    
    -- gravity
    if grav_togg then self.torque += sin(SIGN_ANGLES_DIFF(90,self.deg))*GRAVITY end
    
    self.torque -= self.ang_vel * friction
    
    self.ang_vel += self.torque
    self.deg = WRAP(self.ang_vel+self.deg,360)
    --resolve children movements
    if self.child ~= nil then
        -- -- get midpoint of child
        local mid = geom.point.new(self.child:midpoint():unpack())
        local endPoint = geom.point.new(self:getArmEnd():unpack())
        -- gfx.drawCircleAtPoint(mid,3)
        -- gfx.drawCircleAtPoint(endPoint,3)
        local end_mid_dist = mid:distanceToPoint(endPoint)
        local newAngle = WRAP(atan(  (endPoint-mid).y,(endPoint-mid).x ),360)
        -- gfx.drawLine(mid.x,mid.y,mid.x+cos(newAngle)*40,mid.y+sin(newAngle)*40)
        self.child.deg = WRAP(newAngle-180,360)
        -- local end_pos_dist = endPoint:distanceToPoint(geom.point.new(self.child.pos:unpack()))
        self.child.pos = self:getArmEnd()

        self.child.deg = deadZone(self.deg,self.child.deg)
        
        self.child:update(false)

    end
end

function ANGLES_DIFF(a1,a2)
    local diff = (360+(a1-a2))%360
    local diff1 = (360+(a2-a1))%360
    if diff1 < diff then diff = diff1 end
    return diff
end
function SIGN_ANGLES_DIFF(a1,a2)
    local diff = (360+(a1-a2))%360
    local diff1 = (360+(a2-a1))%360
    if diff1 < diff then diff = -diff1 end
    return diff
end
function BETWEEN_ANGLES(as,p,ae)
    p = WRAP(p-as,360)
    ae = WRAP(ae-as,360)
    as = 0
    if p < ae then return true else return false end
end
function ANGLES_LEFT(a,p)
    return BETWEEN_ANGLES(WRAP(a-180,360),p,a)
end
function ANGLES_RIGHT(a,p)
    return BETWEEN_ANGLES(a,p,WRAP(a+180,360))
end
function math.sign(x)
    if x<0 then
      return -1
    elseif x>0 then
      return 1
    else
      return 0
    end
 end

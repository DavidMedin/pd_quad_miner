function wrap(a,b)
    local q = a % b
    if q < 0 then
        return wrap(a+b,b)
    end
    return q
end

function angles_diff(a1,a2)
    local diff = (360+(a1-a2))%360
    local diff1 = (360+(a2-a1))%360
    if diff1 < diff then diff = diff1 end
    return diff
end
function sign_angles_diff(a1,a2)
    local diff = (360+(a1-a2))%360
    local diff1 = (360+(a2-a1))%360
    if diff1 < diff then diff = -diff1 end
    return diff
end
function between_angles(as,p,ae)
    p = wrap(p-as,360)
    ae = wrap(ae-as,360)
    as = 0
    if p < ae then return true else return false end
end
function angles_left(a,p)
    return between_angles(wrap(a-180,360),p,a)
end
function angles_right(a,p)
    return between_angles(a,p,wrap(a+180,360))
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


 -- Get a point out of anything that has a .x and a .y
 function GetPoint(thing)
    assert(thing.x,thing.y)
    return geom.point.new(thing.x,thing.y)
 end

 -- Get a vec2 out of anything that has a .x and a .y
 function GetVec(thing)
    assert(thing.x,thing.y)
    return vec2.new(thing.x,thing.y)
 end
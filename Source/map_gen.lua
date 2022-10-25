function ADD_SPHERE(map, pos, radius)
    local side = 2^map.max_depth
    assert(side >= pos.x + radius and pos.x-radius >= 0 and
          side >= pos.y + radius and pos.y-radius >= 0, "bad arguments to add_sphere")

    local p1 = geom.point.new(pos.x,pos.y)
    for x=1, side do
        for y=1, side do
            local p2 = geom.point.new(x,y)
            local dist = p1:distanceToPoint(p2)
            if dist < radius then
                map:change(p2,BLOCK_KIND.gold)
            end
        end
    end
end
class("polygon", { points,visible=false } ).extends()
function polygon:init(points,...)
   polygon.super.init(self)
   -- allow for a table input or points as seperate inputs.
   if ... ~= nil then
      local variadic = {...}

      -- must have an even number of arguements
      if (#variadic + 1) % 2 ~= 0 then
         print("Not enough arguments for polygon.init")
         return
      end

      local tmp_points = {}
      points = {points, table.unpack(...)}

      -- turn x,y into points
      for i=1, #variadic+1, 2 do
         table.insert(tmp_points, geom.point.new(points[i],points[i+1]) )
      end

      points = tmp_points
   end
   -- Points is a table of points.

   -- store the points
   self.points = points
   self.shape = geom.polygon.new(points)
   self.shape:close()
end

-- fn(self,polygon) -> bool
-- Takes another polygon, returns if they are intersecting.
function polygon:hit(trans1, polygon, trans2)
   local poly1 = self.shape * trans1
   local poly2 = polygon.shape * trans2

   return poly1:intersects(poly2)
end

-- fn(self)
-- Draws the polygon for debugging.
function polygon:draw(transform)
   if self.visible then 
      gfx.drawPolygon( self.shape * transform )
   end
end

--=========================
-- fn(radius) -> polygon
function CreateCircle(radius)
   local points = {}
   local num_verts = 8
   for i = 1, num_verts do
      local angle = 360/num_verts * i
      local point = geom.point.new( cos(angle) * radius, sin(angle) * radius )

      table.insert(points, point )
   end

   return polygon(points)
end

-- fn(w,h) -> polygon
function CreateRect(w,h)
   local points = {
      geom.point.new( -w/2 , h/2 ),
      geom.point.new( w/2, h/2 ),
      geom.point.new( w/2, -h/2),
      geom.point.new( -w/2, -h/2)
   }

   return polygon(points)
end
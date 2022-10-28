--- This is a library thing for Playdate.

---@enum image_draw_mode
local drawMode = {
    ---@type number
    kDrawModeCopy=gfx.kDrawModeCopy,
    ---@type number
    kDrawModeWhiteTransparent=gfx.kDrawModeWhiteTransparent,
    ---@type number
    kDrawModeBlackTransparent=gfx.kDrawModeBlackTransparent,
    ---@type number
    kDrawModeFillWhite=gfx.kDrawModeFillWhite,
    ---@type number
    kDrawModeFillBlack=gfx.kDrawModeFillBlack,
    ---@type number
    kDrawModeXOR=gfx.kDrawModeXOR,
    ---@type number
    kDrawModeNXOR=gfx.kDrawModeNXOR,
    ---@type number
    kDrawModeInverted=gfx.kDrawModeInverted,
}

---@return image_draw_mode
function gfx.getImageDrawMode() end
---@param draw_mode image_draw_mode
function gfx.setImageDrawMode(draw_mode) end

---@class pd_draw_context Returned from getContext

---@enum pd_color
local playdate_color = {
    kColorBlack=gfx.kColorBlack,
    kColorWhite=gfx.kColorWhite,
    kColorClear=gfx.kColorClear,
    kColorXOR=gfx.kColorXOR
}

---@param color pd_color
function gfx.setColor(color)end
---@return pd_color
function gfx.getColor()end


---@enum pd_text_align
---@diagnostic disable-next-line
kTextAlignment = {
    left=1,
    center=2,
    right=3
}

---@class Object
---@field class Object
---@field className string
---@field init fun(self,...)
---@field extends fun(Parent:Object|nil)


---@generic T
---@param ClassName `T`
---@param properties table|nil
---@param namespace any|nil
function class(ClassName, properties, namespace) end


---@class vec2
---@field x number
---@field y number
---@operator add(vec2): vec2
---@operator add(number): vec2
---@operator sub(vec2): vec2
---@operator sub(number): vec2
---@operator div(vec2): vec2
---@operator div(number): vec2
---@operator mul(vec2): vec2
---@operator mul(number): vec2
--====
vec2 = pd.geometry.vector2D
---@param x number
---@param y number
---@return vec2
function vec2.new(x,y)end

---@return number,number
function vec2:unpack()end
function vec2:normalize() end
---@return number
function vec2:magnitude() end


---@class pd_transform
---@operator mul(pd_transform): pd_transform
---@operator mul(vec2): vec2
---@operator mul(pd_point): pd_point
geom.affineTransform=nil

---@param m11 number
---@param m12 number
---@param m21 number
---@param m22 number
---@param tx number
---@param ty number
---@return pd_transform
function geom.affineTransform.new(m11,m12,m21,m22,tx,ty) end
---@return pd_transform
function geom.affineTransform.new() end
---@return pd_transform
function geom.affineTransform:copy() end
function geom.affineTransform:invert() end
function geom.affineTransform:reset() end
---@param af pd_transform
function geom.affineTransform:concat(af) end
---@param dx number
---@param dy number
function geom.affineTransform:translate(dx,dy) end
---@param dx number
---@param dy number
---@return pd_transform
function geom.affineTransform:translatedBy(dx,dy) end
---@param sx number
---@param sy? number
function geom.affineTransform:scale(sx,sy) end
---@param sx number
---@param sy? number
---@return pd_transform
function geom.affineTransform:scaledBy(sx,sy) end
---@param angle number
---@param x? number
---@param y? number
function geom.affineTransform:rotate(angle,x,y) end
---@param angle number
---@param point? pd_point
---@return pd_transform
function geom.affineTransform:rotatedBy(angle,point)end
---@param p pd_point
function geom.affineTransform:transformPoint(p) end
---@param p pd_point
---@return pd_point
function geom.affineTransform:transformedPoint(p) end


---@class pd_rect
---@field x number
---@field y number
---@field width number
---@field height number



---@class pd_image
gfx.image=nil --- Assosiate gfx.image with pd_image

---@param path string
---@return pd_image
---@overload fun(width:integer,height:integer,bgcolor?:pd_color): pd_image
function gfx.image.new(path) end

---@param self pd_image
---@param x number
---@param y number
---@param flip? boolean
---@param sourceRect? pd_rect
function gfx.image:draw(x,y,flip,sourceRect)end



---@class pd_point
---@field x number
---@field y number


---@class pd_sprite : Object
---@field x integer
---@field y integer
---@field width integer
---@field height integer
gfx.sprite=nil
---Create a sprite
---@param image? pd_image
---@return pd_sprite
function gfx.sprite.new(image) end
---@param self? pd_sprite
function gfx.sprite.update(self) end

---@param image pd_image
---@param flip? boolean
---@param scale? number
---@param yscale? number
function gfx.sprite:setImage(image,flip,scale,yscale) end

function gfx.sprite:getImage() end
function gfx.sprite:add() end
function gfx.sprite:remove() end
---@param sprite pd_sprite
function gfx.sprite:removeSprite(sprite) end
---@param x integer
---@param y integer
function gfx.sprite:moveTo(x,y)end
---@return number,number
function gfx.sprite:getPosition() end
---@param x integer
---@param y integer
function gfx.sprite:moveBy(x,y)end
---@param z integer
function gfx.sprite:setZIndex(z)end
---@return integer
function gfx.sprite:getZIndex()end
---@param flag boolean
function gfx.sprite:setVisible(flag)end
---@return boolean
function gfx.sprite:isVisible()end
---@param x integer
---@param y integer
function gfx.sprite:setCenter(x,y)end
---@return integer,integer
function gfx.sprite:getCenter()end
---@return pd_point
function gfx.sprite:getCenterPoint()end
---@param width integer
---@param height integer
function gfx.sprite:setSize(width,height)end
---@return integer,integer
function gfx.sprite:getSize()end
function gfx.sprite:setImageDrawMode(mode)end
---@param angle number
---@param scale? number
---@param yScale? number
function gfx.sprite:setRotation(angle,scale,yScale)end


---@param x integer
---@param y integer
---@param width integer
---@param height integer
function gfx.sprite:setCollideRect(x,y,width,height) end
---@param groups table|integer
function gfx.sprite:setGroups(groups) end
function gfx.sprite:resetGroupMask() end
---@param callback fun()
function gfx.sprite.setBackgroundDrawingCallback(callback) end


-- Font stuff
---@class pd_font

---@param font pd_font
function gfx.setFont(font)end

---@param text string
---@param x integer
---@param y integer
---@param leadingAdjustment? integer
function gfx.drawText(text,x,y,leadingAdjustment) end


---@class pd_gridview
pd.ui.gridview=nil

---@param cellWidth? integer
---@param cellHeight? integer
---@return pd_gridview
function pd.ui.gridview.new(cellWidth,cellHeight)end
---@param section integer
---@param row integer
---@param column integer
---@param selected integer
---@param x integer
---@param y integer
---@param width integer
---@param height integer
function pd.ui.gridview:drawCell(section,row,column,selected,x,y,width,height)end
---@param x integer
---@param y integer
---@param width integer
---@param height integer
function pd.ui.gridview:drawInRect(x,y,width,height)end
---@param num integer
function pd.ui.gridview:setNumberOfSections(num)end
function pd.ui.gridview:getNumberOfSections()end
---@param section integer
---@param num integer
function pd.ui.gridview:setNumberOfRowsInSection(section,num)end
---@param section integer
function pd.ui.gridview:getNumberOfRowsInSection(section)end
---@param num integer
function pd.ui.gridview:setNumberOfColumns(num)end
---@return integer
function pd.ui.gridview:getNumberOfColumns() end
---@param ... integer
function pd.ui.gridview.setNumberOfRows(...)end
---@param cellWidth integer
---@param cellHeight integer
function pd.ui.gridview:setCellSize(cellWidth,cellHeight)end
---@param left integer
---@param right integer
---@param top integer
---@param bottom integer
function pd.ui.gridview:setCellPadding(left,right,top,bottom)end
---@param left integer
---@param right integer
---@param top integer
---@param bottom integer
function pd.ui.gridview:setContentInset(left,right,top,bottom)end

---@param section integer
---@param row integer
---@param column integer
---@param gridWidth? integer
---@return integer,integer,integer,integer -- x,y,width,height
function pd.ui.gridview:getCellBounds(section,row,column,gridWidth)end
---@param height integer
function pd.ui.gridview:setSectionheaderHeight(height)end
---@return integer
function pd.ui.gridview.getSectionHeaderHeight()end
---@param left integer
---@param right integer
---@param top integer
---@param bottom integer
function pd.ui.gridview:setSectionHeaderPadding(left,right,top,bottom)end
---@param height integer
function pd.ui.gridview:setHorizontalDividerHeight(height)end

-- selection
---@return integer,integer,integer --- section,row,column
function pd.ui.gridview:getSelection() end
---@param wrapSelection boolean
---@param scrollToSelection? boolean
---@param animate? boolean
function pd.ui.gridview:selectPreviousColumn(wrapSelection,scrollToSelection,animate)end
---@param wrapSelection boolean
---@param scrollToSelection? boolean
---@param animate? boolean
function pd.ui.gridview:selectNextColumn(wrapSelection,scrollToSelection,animate)end
---@param wrapSelection boolean
---@param scrollToSelection? boolean
---@param animate? boolean
function pd.ui.gridview:selectPreviousRow(wrapSelection,scrollToSelection,animate)end
---@param wrapSelection boolean
---@param scrollToSelection? boolean
---@param animate? boolean
function pd.ui.gridview:selectNextRow(wrapSelection,scrollToSelection,animate)end
---@param row integer
function pd.ui.gridview:setSelectedRow(row)end
--- There is more stuff
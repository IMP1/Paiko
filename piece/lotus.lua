Piece = {}
Piece.__index = Piece

--------
-- new
------
-- id : unique ID for the tile
------
-- Initialises the piece
function Piece.new(id)
    local this = {}
    setmetatable(this, Piece)
    this.name = "Lotus"
    this.quads = {
        love.graphics.newQuad(3 * TileSize, 0 * TileSize, TileSize, TileSize, PieceImage:getWidth(), PieceImage:getHeight()), -- Player 1
        love.graphics.newQuad(3 * TileSize, 1 * TileSize, TileSize, TileSize, PieceImage:getWidth(), PieceImage:getHeight()), -- Player 2
    }
    this.id = id
    this.x = -1
    this.y = -1
    this.direction = 0 -- 0 = up, 1 = right, 2 = down, 3 = left
    return this
end

----------------
-- isAttacking
--------------
-- x : x (tile) co-ordinate
-- y : y (tile) co-ordinate
--------------
-- Returns if this tile is threatening the square (x, y)
function Piece:isAttacking(x, y)
    return false -- Lotus doesn't attack any tiles
end

----------------
-- isDefending
--------------
-- x : x (tile) co-ordinate
-- y : y (tile) co-ordinate
--------------
-- Returns if this tile covers the square (x, y)
function Piece:isDefending(x, y)
    if self.x == -1 or self.y == -1 then return false end -- Not on the board
    return math.sqrt( math.abs(self.x-x) + math.abs(self.y-y) ) < 1.5
end

------------------
-- canBePlacedAt
----------------
-- x : x (tile) co-ordinate
-- y : y (tile) co-ordinate
----------------
-- Returns if this can be placed at the square (x, y)
function Piece:canBePlacedAt(x, y, player)
    if not Board.onBoard(x, y) then return false end -- Cannot start off the board
    if not Board.emptyTile(x, y) then return false end -- Cannot start on an occupied square
    return true
end

-----------------
-- canShiftTo
---------------
-- x : x (tile) co-ordinate
-- y : y (tile) co-ordinate
---------------
-- Returns if this can shift to the square (x, y)
function Piece:canShiftTo(x, y)
    return false -- Lotus cannot shift
end

---------
-- draw
-------
-- player : player owning this tile
--      x : x (screen) co-ordinate
--      y : y (screen) co-ordinate
-------
-- Draws the tile at either it's tile location or, if x and y parameters are given, at those
function Piece:draw(player, x, y)
    local r = (self.direction % 4 ) * math.pi/2
    if x == nil or y == nil then
        love.graphics.drawq(PieceImage, self.quads[player], Board.x + (self.x * TileSize) + (TileSize / 2), Board.y + (self.y * TileSize) + (TileSize / 2), r, 1, 1, TileSize/2, TileSize/2) 
        -- MAY NEED TO OFFSET X AND Y B/C OFF OFFSET FOR ROTATION
    else
        love.graphics.drawq(PieceImage, self.quads[player], x, y) -- We don't need to worry about direction when not on the board.
    end
end

return Piece
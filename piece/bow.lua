local Piece = {}
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
    this.name = "Bow"
    this.quads = {
        love.graphics.newQuad(1 * TileSize, 0 * TileSize, TileSize, TileSize, PieceImage:getWidth(), PieceImage:getHeight()), -- Player 1
        love.graphics.newQuad(1 * TileSize, 1 * TileSize, TileSize, TileSize, PieceImage:getWidth(), PieceImage:getHeight()), -- Player 2
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
    if self.x == -1 or self.y == -1 then return false end -- Not on the board
    if self.x == x and self.y == y then return false end -- We don't attack our own square
    if self.direction == 0 then -- up
        return x == self.x and (y >= self.y - 4 and y <= self.y - 2)
    elseif self.direction == 1 then -- right
        return y == self.y and (x >= self.x + 2 and x <= self.x + 4)
    elseif self.direction == 2 then -- down
        return x == self.x and (y >= self.y + 2 and y <= self.y + 4)
    elseif self.direction == 3 then -- left
        return y == self.y and (x >= self.x - 4 and x <= self.x - 2)
    end
end

----------------
-- isDefending
--------------
-- x : x (tile) co-ordinate
-- y : y (tile) co-ordinate
--------------
-- Returns if this tile covers the square (x, y)
function Piece:isDefending(x, y)
    return false -- Bow doesn't defend any tiles
end

------------------
-- canBePlacedAt
----------------
-- x : x (tile) co-ordinate
-- y : y (tile) co-ordinate
----------------
-- Returns if this can be placed at the square (x, y)
function Piece:canBePlacedAt(x, y, player)
    if not Board.validTile(x, y) then return false end -- Cannot start off the board or on black squares
    if not Board.emptyTile(x, y) then return false end -- Cannot start on an occupied square
    if Board.threatDanger(x, y, player) > 0 then return false end -- This square is threatened by opponent
    local friendlyThreat = Board.threatFriendly(x, y, player)
    return (friendlyThreat > 0) or Board.isHomeGround(x, y, player)
end

-----------------
-- canShiftTo
---------------
--      x : x (tile) co-ordinate
--      y : y (tile) co-ordinate
-- player : player owning the tile
---------------
-- Returns if this can shift to the square (x, y)
function Piece:canShiftTo(x, y, player)
    if x == -1 or y == -1 then return false end -- Cannot shift from off the board
    if not Board.validTile(x, y) then return false end -- Cannot end up off board or on black square
    if not Board.emptyTile(x, y) then return false end -- Cannot end up at taken square
    if Board.threatDanger(x, y, player) - Board.coverAt(x, y, player) >= 2 then return false end
    if math.abs(x - self.x) + math.abs(y - self.y) > 1 then return false end
    return true
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
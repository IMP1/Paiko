-----------------
-- Board Module
---------------
-- containing screen location constants and static methods

local Board = {
    x = 32,
    y = 96,
    width = 14 * TileSize,
    height = 14 * TileSize,
    homegroundX = {
        32, 256,
    },
    homegroundY = {
        320, 96,
    },
    libraryX = {
        640, 640,
    },
    libraryY = {
        448, 96,
    },
    libraryW = 8,
    libraryH = 3,
    graveX = {
        544, 544,
    },
    graveY = {
        352, 224,
    },
    graveW = 12,
    graveH = 2,
    handX = {
        32, 32,
    },
    handY = {
        576, 32,
    },
    handW = 24,
    handH = 1,
    messageX = {
        336, 336,
    },
    messageY = {
        520, 104,
    },
    messageW = 8 * 32,
    confirmX = {
        336 + 64, 336 + 64,
    },
    confirmY = {
        520 - 64, 104 + 64,
    },
    confirmW = 2 * 32,
    confirmH = 32,
    scoreX = {
        900, 900,
    },
    scoreY = {
        576, 32,
    },
}

---------------
-- tileCoords
-------------
--      x : x (screen) co-ordinate
--      y : x (screen) co-ordinate
--   area : 
-- player : 
-------------
-- return tile co-ordinates from screen co-ordinates
function Board.tileCoords(x, y, area, player)
    assert(type(x) == "number" and x > 0, "x must be a positive number.")
    assert(type(y) == "number" and x > 0, "y must be a positive number.")
    if player == nil then player = scene.playerTurn end
    local i, j = 0, 0
    if area == "board" or area == nil then
        i = math.floor( (x - Board.x) / TileSize )
        j = math.floor( (y - Board.y) / TileSize )
    elseif area == "library" then
        i = math.floor( (x - Board.libraryX[player]) / TileSize )
        j = math.floor( (y - Board.libraryY[player]) / TileSize )
    elseif area == "hand" then
        i = math.floor( (x - Board.handX[player]) / TileSize )
        j = math.floor( (y - Board.handY[player]) / TileSize )
    elseif area == "graveyard" then
        i = math.floor( (x - Board.graveX[player]) / TileSize )
        j = math.floor( (y - Board.graveY[player]) / TileSize )
    end
    return i, j
end


-----------------
-- screenCoords
---------------
--      i : x (tile) co-ordinate
--      j : y (tile) co-ordinate
--   area : 
-- player : 
---------------
-- returns screen co-ordinates from tile co-ordinates
function Board.screenCoords(i, j, area, player)
    if player == nil then player = scene.playerTurn end
    local x, y = i * TileSize, j * TileSize
    if area == "board" or area == nil then
        x = x + Board.x
        y = y + Board.y
    elseif area == "library" then
        x = x + Board.libraryX[player]
        y = y + Board.libraryY[player]
    elseif area == "hand" then
        x = x + Board.handX[player]
        y = y + Board.handY[player]
    elseif area == "graveyard" then
        x = x + Board.graveX[player]
        y = y + Board.graveY[player]
    end
    return x, y
end

--------------
-- mouseOver
------------
-- area : the specified location
------------
-- returns whether the cursor is within the area
function Board.mouseOver(mx, my, area, player)
    if player == nil then player = scene.playerTurn end
    if area == "board" then
        return (
            mx >= Board.x and
            mx <= Board.x + Board.width and
            my >= Board.y and
            my <= Board.y + Board.height
        )
    elseif area == "library" then
        return (
            mx >= Board.libraryX[player] and
            mx <= Board.libraryX[player] + Board.libraryW * TileSize and
            my >= Board.libraryY[player] and
            my <= Board.libraryY[player] + Board.libraryH * TileSize
        )
    elseif area == "hand" then
        return (
            mx >= Board.handX[player] and
            mx <= Board.handX[player] + Board.handW * TileSize and
            my >= Board.handY[player] and
            my <= Board.handY[player] + Board.handH * TileSize
        )
    elseif area == "graveyard" then
        return (
            mx >= Board.graveX[player] and
            mx <= Board.graveX[player] + Board.graveW * TileSize and
            my >= Board.graveY[player] and
            my <= Board.graveY[player] + Board.graveH * TileSize
        )
    elseif area == "confirm" then
        return (
            mx >= Board.confirmX[player] and
            mx <= Board.confirmX[player] + Board.confirmW and
            my >= Board.confirmY[player] and
            my <= Board.confirmY[player] + Board.confirmH
        )
    end
end

------------
-- onBoard
----------
-- x : x (tile) co-ordinate
-- y : y (tile) co-ordinate
----------
-- Returns if a square is on the board at all
function Board.onBoard(x, y)
    if y == 0 or y == 13 then
        return (x >= 6 and x <= 7)
    end
    if y == 1 or y == 12 then
        return (x >= 5 and x <= 8)
    end
    if y == 2 or y == 11 then
        return (x >= 4 and x <= 9)
    end
    if y == 3 or y == 10 then
        return (x >= 3 and x <= 10)
    end
    if y == 4 or y == 9 then
        return (x >= 2 and x <= 11)
    end
    if y == 5 or y == 8 then
        return (x >= 1 and x <= 12)
    end
    if y == 6 or y == 7 then
        return (x >= 0 and x <= 13)
    end
end

--------------
-- validTile
------------
-- x : x (tile) co-ordinate
-- y : y (tile) co-ordinate
------------
-- Returns if a square is on the board and not a black tile
function Board.validTile(x, y)
    local blackTile = (x == 5 and y == 5)
    blackTile = blackTile or (x == 7 and y == 6)
    blackTile = blackTile or (x == 6 and y == 7)
    blackTile = blackTile or (x == 8 and y == 8)
    return Board.onBoard(x, y) and not blackTile
end

-----------------
-- passableTile
---------------
-- x : x (tile) co-ordinate
-- y : y (tile) co-ordinate
---------------
-- Returns if a square is valid and empty
function Board.passableTile(x, y)
    return Board.validTile(x, y) and Board.emptyTile(x, y)
end

--------------
-- emptyTile
------------
-- x : x (tile) co-ordinate
-- y : y (tile) co-ordinate
------------
-- Returns if no tiles currently occupy the square
function Board.emptyTile(x, y)
    for _, piece in pairs(scene.boardTiles[1]) do
        if piece.x == x and piece.y == y then return false end
    end
    for _, piece in pairs(scene.boardTiles[2]) do
        if piece.x == x and piece.y == y then return false end
    end
    return true
end

-----------------
-- threatDanger
---------------
--      x : x (tile) co-ordinate
--      y : y (tile) co-ordinate
-- player : player being *threatened*
---------------
-- Returns the threat level *against* player at the square
function Board.threatDanger(x, y, player)
    if player == nil then player = scene.playerTurn end
    local enemy = (player%2)+1
    local threat = 0
    for _, piece in pairs(scene.boardTiles[enemy]) do
        if piece:isAttacking(x, y) then
            threat = threat + 1
        end
    end
    for _, piece in pairs(scene.boardTiles[player]) do
        if piece:isAttacking(x, y) and piece.name == "Fire" then
            threat = threat + 1
        end
    end
    return threat
end

-------------------
-- threatFriendly
-----------------
--      x : x (tile) co-ordinate
--      y : y (tile) co-ordinate
-- player : player being *threatened*
-----------------
-- Returns the threat level *for* player at the square
function Board.threatFriendly(x, y, player)
    if player == nil then player = scene.playerTurn end
    local threat = 0
    for _, piece in pairs(scene.boardTiles[player]) do
        if piece:isAttacking(x, y) then
            threat = threat + 1
        end
    end
    return threat
end

------------
-- coverAt
----------
--      x : x (tile) co-ordinate
--      y : y (tile) co-ordinate
-- player : player recieving cover
----------
-- Returns the cover level for player at the square
function Board.coverAt(x, y, player)
    if player == nil then player = scene.playerTurn end
    if Board.isHomeGround(x, y, player) then
        return 1 -- cover doesn't stack
    end
    local cover = 0
    for _, piece in pairs(scene.boardTiles[player]) do
        if piece:isDefending(x, y) then
            return 1 -- cover doesn't stack
        end
    end
    return 0
end

-----------------
-- isHomeGround
---------------
--      x : x (tile) co-ordinate
--      y : y (tile) co-ordinate
-- player : player owning the homeground
---------------
-- Returns if a square is a valid square on the player's home ground
function Board.isHomeGround(x, y, player)
    if player == nil then player = scene.playerTurn end
    if not Board.validTile(x, y) then return false end
    if player == 1 then
        return (x < 7 and y > 6)
    elseif player == 2 then
        return (x > 6 and y < 7)
    end
end

return Board
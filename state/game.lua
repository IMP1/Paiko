local State = {}
State.__index = State

function State.new()
    local this = {}
    setmetatable(this, State)
    this.name = "Game"
    this.background = love.graphics.newImage("gfx/background.png")
    this.homegrounds = {
        love.graphics.newImage("gfx/homeground2.png"),
        love.graphics.newImage("gfx/homeground2.png"),
    }
    this:reset()
    return this
end

function State:reset()
    self.boardTiles = {
        {}, -- Player 1
        {}, -- Player 2
    }
    self.handTiles = {
        {}, -- Player 1
        {}, -- Player 2
    }
    self.libraryTiles = {
        {}, -- Player 1
        {}, -- Player 2
    }
    for player, lib in pairs(self.libraryTiles) do
        for i = 1, 3 do
            lib[#lib+1] = Lotus.new()
            lib[#lib+1] = Sai.new()
            lib[#lib+1] = Bow.new()
            lib[#lib+1] = Sword.new()
            lib[#lib+1] = Fire.new()
            lib[#lib+1] = Water.new()
            lib[#lib+1] = Earth.new()
            lib[#lib+1] = Air.new()
        end
    end
    self.graveyardTiles = {
        {}, -- Player 1
        {}, -- Player 2
    }
    self.points = { 0, 0 }
    self.playerTurn = 1
    self.drawAllThreat = false
    self.drawAllCover = false
    self.drawTileThreat = false
    self.drawTileCover = false
    self.stage = "Start" -- Start, Begin, Draw, Place, Shift, Capture, End
    self.tilesToDraw = 7
    self.tilesDrawn = 0
    self.selectedPiece = nil
    self.selectedPieceIndex = -1
    self.shiftLength = -1
    self.actionLog = { "Player 1:" }
end

function State:mouseReleased(mx, my, key)
    if table.contains({"l", "r", "wu"}, key) then
    
        -- Game Start
        if self.stage == "Start" then
            if Board.mouseOver(mx, my, "library", self.playerTurn) then
                self:drawTile(mx, my)
            end
            if self.tilesDrawn == self.tilesToDraw then
                if self.tilesToDraw == 7 then
                    self.tilesToDraw = 9
                    self.playerTurn = 1 + (self.playerTurn % 2)
                    self.actionLog[#self.actionLog+1] = "\nPlayer " .. self.playerTurn .. ":"
                elseif self.tilesToDraw == 9 then
                    self.tilesToDraw = 1
                    self.playerTurn = 1 + (self.playerTurn % 2)
                    self.actionLog[#self.actionLog+1] = "\nPlayer " .. self.playerTurn .. ":"
                elseif self.tilesToDraw == 1 then -- End of Game Start
                    self.tilesToDraw = 0
                    self.stage = "Begin"
                end
                self.tilesDrawn = 0
            end
            
        -- Turn Start
        elseif self.stage == "Begin" then
            if Board.mouseOver(mx, my, "library") then
                local valid = self:drawTile(mx, my)
                if valid then
                    self.stage = "Draw"
                end
            elseif Board.mouseOver(mx, my, "hand") then
                local i, j = Board.tileCoords(mx, my, "hand")
                n = (j * Board.libraryW) + i + 1
                self.selectedPiece = self.handTiles[self.playerTurn][n]
                self.selectedPieceIndex = n
                self.stage = "Place"
            elseif Board.mouseOver(mx, my, "board") then
                local i, j = Board.tileCoords(mx, my)
                local tile = nil
                for _, piece in pairs(self.boardTiles[self.playerTurn]) do
                    if piece.x == i and piece.y == j then
                        tile = piece
                    end
                end
                if tile ~= nil and tile.name ~= "Lotus" and tile.name ~= "Air" then
                    self.selectedPiece = tile
                    self.selectedPieceIndex = tile.id
                    self.stage = "Shift"
                    self.shiftLength = 0
                end
            end
            
        -- Drawing Tiles
        elseif self.stage == "Draw" then
            if Board.mouseOver(mx, my, "library", self.playerTurn) then
                if self.tilesDrawn < 3 then
                    self:drawTile(mx, my)
                end
                if self.tilesDrawn == 3 then
                    self.stage = "Capture"
                    self.tilesDrawn = 0
                end
            elseif Board.mouseOver(mx, my, "confirm", self.playerTurn) then
                self.stage = "Capture"
                self.tilesDrawn = 0
            end
            
        -- Placing Tiles from Hand
        elseif self.stage == "Place" then
            if Board.mouseOver(mx, my, "board") then
                local i, j = Board.tileCoords(mx, my)
                if self.selectedPiece:canBePlacedAt(i, j, self.playerTurn) then
                    self:placeTile(i, j, self.handTiles[self.playerTurn][self.selectedPieceIndex])
                    if self.selectedPiece.name == "Sai" then
                        self.stage = "Shift"
                        self.shiftLength = 0
                    else
                        self.stage = "Rotate"
                    end
                end
            elseif Board.mouseOver(mx, my, "hand") then -- Changing which piece to place
                local i, j = Board.tileCoords(mx, my, "hand")
                local n = (j * Board.handW) + i + 1
                self.selectedPieceIndex = n
                self.selectedPiece = self.handTiles[self.playerTurn][n]
            end
            
        elseif self.stage == "Rotate" then
            local i, j = Board.tileCoords(mx, my)
            if self.selectedPiece.x == i and self.selectedPiece.y == j then
                self.selectedPiece.direction = (self.selectedPiece.direction + 1) % 4
            end
            if Board.mouseOver(mx, my, "confirm", self.playerTurn) then
                self.stage = "Capture"
                self.selectedTile = nil
                self.selectedTileIndex = -1
            end
            
        -- Shifting Tiles on Board
        elseif self.stage == "Shift" then
            local i, j = Board.tileCoords(mx, my)
            if self.selectedPiece:canShiftTo(i, j) then
                self:shiftTile(self.selectedPiece, i, j)
            end
            if Board.mouseOver(mx, my, "confirm", self.playerTurn) then
                self.stage = "Rotate"
                self.selectedTile = nil
                self.selectedTileIndex = -1
            end
            if self.shiftLength >= 2 then
                self.stage = "Rotate"
                self.selectedTile = nil
                self.selectedTileIndex = -1
            elseif self.shiftLength >= 1 and self.selectedPiece.name == "Earth" or self.selectedPiece.name == "Water" then
                self.stage = "Rotate"
                self.selectedTile = nil
                self.selectedTileIndex = -1
            end
        end
    end
end

function State:update(dt)
    -- Capture Phase
    if self.stage == "Capture" then
        self:capturePhase()
        self.stage = "End"
    -- End of Turn
    elseif self.stage == "End" then
        self.playerTurn = 1 + (self.playerTurn % 2)
        self.actionLog[#self.actionLog+1] = "\nPlayer " .. self.playerTurn
        self.stage = "Begin"
    end
end

function State:draw()

    -- Draw Background
    love.graphics.draw(self.background, 0, 0)
    for i = 1, 2 do
        local r = (i - 1) * math.pi
        love.graphics.draw(self.homegrounds[i], Board.homegroundX[i] + 112, Board.homegroundY[i] + 112, r, 1, 1, 112, 112)
    end
    
    -- Draw Library Tiles
    for player, lib in pairs(self.libraryTiles) do
        for n, tile in pairs(lib) do
            local i = TileSize * ((n-1) % Board.libraryW) + Board.libraryX[player]
            local j = TileSize * math.floor((n-1) / Board.libraryW) + Board.libraryY[player]
            tile:draw(player, i, j)
        end
    end
    
    -- Draw Hand Tiles
    for player, hand in pairs(self.handTiles) do
        for n, tile in pairs(hand) do
            local i = TileSize * ((n-1) % Board.handW) + Board.handX[player]
            local j = TileSize * math.floor((n-1) / Board.handW) + Board.handY[player]
            tile:draw(player, i, j)
        end
    end
    
    -- Draw Graveyard Tiles
    for player, grave in pairs(self.graveyardTiles) do
        for n, tile in pairs(grave) do
            local i = TileSize * ((n-1) % Board.graveW) + Board.graveX[player]
            local j = TileSize * math.floor((n-1) / Board.graveW) + Board.graveY[player]
            tile:draw(player, i, j)
        end
    end
    
    -- Draw Board Tiles
    for player, tiles in pairs(self.boardTiles) do
        for _, tile in pairs(tiles) do
            tile:draw(player)
        end
    end
    
    -- Draw Stage Instructions
    if self.stage == "Start" then
        local msg = ""
        if self.tilesToDraw - self.tilesDrawn == 1 then
            msg = "Click on 1 more tile to draw to your hand."
        else
            msg = "Click on " .. (self.tilesToDraw - self.tilesDrawn) .. " more tiles to draw to your hand."
        end
        self:drawMessage(msg)
    end
    
    if self.stage == "Begin" then
        self:drawMessage("Draw up to 3 tiles, or place or shift a tile.")
    end
    
    if self.stage == "Draw" then
        -- Draw the [End] Button
        local i = Board.confirmX[self.playerTurn]
        local j = Board.confirmY[self.playerTurn] + 8
        love.graphics.printf("End", i, j, Board.confirmW, "center")
        love.graphics.rectangle("line", Board.confirmX[self.playerTurn], Board.confirmY[self.playerTurn], Board.confirmW, Board.confirmH)
        
        self:drawMessage("Draw up to " .. (3 - self.tilesDrawn) .. " more tiles or [End] to finish.")
    end
    
    if self.stage == "Place" then
        self:drawMessage("Place on a highlighted square.")
        love.graphics.setColor(255, 255, 255, 32)
        for j = 0, 14 do
            for i = 0, 14 do
                if Board.onBoard(i, j) then
                if self.selectedPiece:canBePlacedAt(i, j) then
                    local x, y = Board.screenCoords(i, j)
                    love.graphics.rectangle("fill", x, y, TileSize, TileSize)
                end
                end
            end
        end
        local x, y = Board.screenCoords( (self.selectedPieceIndex-1) % Board.handW, math.floor((self.selectedPieceIndex-1) / (Board.handW*TileSize)), "hand" )
        love.graphics.rectangle("fill", x, y, TileSize, TileSize)
        love.graphics.setColor(255, 255, 255)
    end
    
    if self.stage == "Rotate" then
        local i = Board.confirmX[self.playerTurn]
        local j = Board.confirmY[self.playerTurn] + 8
        love.graphics.printf("End", i, j, Board.confirmW, "center")
        love.graphics.rectangle("line", Board.confirmX[self.playerTurn], Board.confirmY[self.playerTurn], Board.confirmW, Board.confirmH)
        self:drawMessage("Click to rotate, or [End] to finish.")
        love.graphics.setColor(255, 255, 255, 32)
        local x, y = Board.screenCoords(self.selectedPiece.x, self.selectedPiece.y)
        love.graphics.rectangle("fill", x, y, TileSize, TileSize)
        for j = 0, 14 do
            for i = 0, 14 do
                if Board.onBoard(i, j) then
                    local x, y = Board.screenCoords(i, j)
                    if self.selectedPiece:isAttacking(i, j) then
                        love.graphics.setColor(255, 0, 0, 32)
                        love.graphics.rectangle("fill", x, y, TileSize, TileSize)
                    end
                    if self.selectedPiece:isDefending(i, j) then
                        love.graphics.setColor(0, 0, 255, 32)
                        love.graphics.rectangle("fill", x, y, TileSize, TileSize)
                    end
                end
            end
        end
        love.graphics.setColor(255, 255, 255)
    end
    
    if self.stage == "Shift" then
        local i = Board.confirmX[self.playerTurn]
        local j = Board.confirmY[self.playerTurn] + 8
        love.graphics.printf("End", i, j, Board.confirmW, "center")
        love.graphics.rectangle("line", Board.confirmX[self.playerTurn], Board.confirmY[self.playerTurn], Board.confirmW, Board.confirmH)
        self:drawMessage("Shift to a highlighted square, or [End] to finish.")
        love.graphics.setColor(255, 255, 255, 32)
        for j = 0, 14 do
            for i = 0, 14 do
                if Board.onBoard(i, j) then
                if self.selectedPiece:canShiftTo(i, j) then
                    local x, y = Board.screenCoords(i, j)
                    love.graphics.rectangle("fill", x, y, TileSize, TileSize)
                end
                end
            end
        end
        local x, y = Board.screenCoords(self.selectedPiece.x, self.selectedPiece.y)
        love.graphics.rectangle("fill", x, y, TileSize, TileSize)
        love.graphics.setColor(255, 255, 255)
    end
    
    if self.stage == "Shifted" then
        local i = Board.confirmX[self.playerTurn]
        local j = Board.confirmY[self.playerTurn] + 8
        love.graphics.printf("End", i, j, Board.confirmW, "center")
        love.graphics.rectangle("line", Board.confirmX[self.playerTurn], Board.confirmY[self.playerTurn], Board.confirmW, Board.confirmH)
        self:drawMessage("Click to rotate, or [End] to finish.")
        love.graphics.setColor(255, 255, 255, 32)
        local x, y = Board.screenCoords(self.selectedPiece.x, self.selectedPiece.y)
        love.graphics.rectangle("fill", x, y, TileSize, TileSize)
        love.graphics.setColor(255, 255, 255)
    end
    
    if self.stage == "Capture" then
        self:drawMessage("Determining captured pieces...")
    end
    
    -- Scores
    for player = 1, 2 do
        love.graphics.print( tostring(self.points[player]), Board.scoreX[player], Board.scoreY[player] )
    end
    
end

function State:capturePhase()
    for player = 1, 2 do
        for _, piece in pairs(self.boardTiles[player]) do
            local cover = Board.coverAt(piece.x, piece.y, player)
            local threat = Board.threatDanger(piece.x, piece.y, player)
            if threat - cover >= 2 then
                self:captureTile(piece, player)
            end
        end
    end
end

function State:updateScores()
    for player = 1, 2 do
        self.points[player] = self:getScore(player)
    end
end

function State:getScore(player)
    local enemy = 1 + (player % 2)
    local score = 0
    for _, piece in pairs(self.boardTiles[player]) do
        if piece.name ~= "Lotus" and not Board.isHomeGround(piece.x, piece.y, player) then -- Outside the homeground
            score = score + 1 -- 1 point for neutral ground
            if Board.isHomeGround(piece.x, piece.y, enemy) then score = score + 1 end -- 2 points for enemy ground
        end
    end
    return score
end

function State:placeTile(x, y, tile)
    table.remove(self.handTiles[self.playerTurn], self.selectedPieceIndex)
    local size = #self.boardTiles[self.playerTurn]
    self.boardTiles[self.playerTurn][size+1] = tile
    tile.id = size+1
    tile.x = x
    tile.y = y
    tile.direction = (self.playerTurn - 1) * 2
    self.actionLog[#self.actionLog+1] = "PLACE " .. tile.name
    self:updateScores()
end

function State:captureTile(tile, player)
    local size = #self.graveyardTiles[player]
    self.graveyardTiles[player][size+1] = tile
    table.remove(self.boardTiles[player], tile.id)
    tile.x = -1
    tile.y = -1
    tile.id = nil
    self:updateScores()
end

function State:shiftTile(tile, x, y)
    self.actionLog[#self.actionLog+1] = "SHIFT " .. tile.name .. " [" .. tile.x .. ", " .. tile.y .. "] -> [" .. x .. ", " .. y .. "]"
    tile.x = x
    tile.y = y
    self.shiftLength = self.shiftLength + 1
    self:updateScores()
end

function State:drawTile(mx, my)
    local i, j = Board.tileCoords(mx, my, "library")
    local n = (j * Board.libraryW) + i + 1
    local tile = self.libraryTiles[self.playerTurn][n]
    if tile == nil then return false end -- We clicked on empty space
    local size = #self.handTiles[self.playerTurn]
    self.handTiles[self.playerTurn][size+1] = tile
    table.remove(self.libraryTiles[self.playerTurn], n)
    self.tilesDrawn = self.tilesDrawn + 1
    self.actionLog[#self.actionLog+1] = "DRAW " .. tile.name
    return true
end

function State:drawMessage(msg)
    local x = Board.messageX[self.playerTurn]
    local y = Board.messageY[self.playerTurn]
    love.graphics.printf(msg, x, y, Board.messageW, "left")
end

return State
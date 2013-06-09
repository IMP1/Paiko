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
    self.actionLog = {}
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
                elseif self.tilesToDraw == 9 then
                    self.tilesToDraw = 1
                    self.playerTurn = 1 + (self.playerTurn % 2)
                elseif self.tilesToDraw == 1 then -- End of Game Start
                    self.tilesToDraw = 0
                    self.stage = "Begin"
                end
                self.tilesDrawn = 0
            end
            
        -- Turn Start
        elseif self.stage == "Begin" then
            if Board.mouseOver(mx, my, "library", self.playerTurn) then
                self:drawTile(mx, my)
                self.stage = "Draw"
            elseif Board.mouseOver(mx, my, "hand", self.playerTurn) then
                local i, j = Board.tileCoords(mx, my, "hand")
                n = (j * Board.libraryW) + i + 1
                self.selectedPiece = self.handTiles[self.playerTurn][n]
                self.selectedPieceIndex = n
                self.stage = "Place"
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
            local i, j = Board.tileCoords(mx, my)
            if self.selectedPiece:canBePlacedAt(i, j, self.playerTurn) then
                self:placeTile(i, j, self.handTiles[self.playerTurn][self.selectedPieceIndex])
                self.stage = "Rotate"
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
        self:drawMessage("Place the tile on a highlighted square.")
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
        love.graphics.setColor(255, 255, 255)
    end
    
    if self.stage == "Rotate" then
        local i = Board.confirmX[self.playerTurn]
        local j = Board.confirmY[self.playerTurn] + 8
        love.graphics.printf("End", i, j, Board.confirmW, "center")
        love.graphics.rectangle("line", Board.confirmX[self.playerTurn], Board.confirmY[self.playerTurn], Board.confirmW, Board.confirmH)
        self:drawMessage("Click on the tile to rotate or [End] to finish.")
    end
    
    if self.stage == "Shift" then
    
    end
    
    if self.stage == "Capture" then
        self:drawMessage("Determining captured pieces...")
    end
    
    -- Scores
    for player = 1, 2 do
        love.graphics.print( tostring(self.points[player]), Board.scoreX[player], Board.scoreY[player] )
    end
    
    -- DEBUGGIN'
    for j = 0, 14 do
        for i = 0, 14 do
            if Board.onBoard(i, j) then
                local x, y = Board.screenCoords(i, j)
                local a = tostring( Board.threatFriendly(i, j, self.playerTurn) )
                local b = tostring( Board.threatDanger(i, j, self.playerTurn) )
                love.graphics.print( a .. b, x, y)
            end
        end
    end
    
  
    
end

function State:capturePhase()
    
end

function State:updateScores()

end

function State:placeTile(x, y, tile)
    table.remove(self.handTiles[self.playerTurn], self.selectedPieceIndex)
    local size = #self.boardTiles[self.playerTurn]
    self.boardTiles[self.playerTurn][size+1] = tile
    tile.x = x
    tile.y = y
    tile.direction = (self.playerTurn - 1) * 2
    self:updateScores()
end

function State:shiftTile(x, y, tile)
    self:updateScores()
end

function State:drawTile(mx, my)
    local i, j = Board.tileCoords(mx, my, "library")
    n = (j * Board.libraryW) + i + 1
    local tile = self.libraryTiles[self.playerTurn][n]
    if tile == nil then return end -- We clicked on empty space
    local size = #self.handTiles[self.playerTurn]
    self.handTiles[self.playerTurn][size+1] = tile
    table.remove(self.libraryTiles[self.playerTurn], n)
    self.tilesDrawn = self.tilesDrawn + 1
end

function State:drawMessage(msg)
    local x = Board.messageX[self.playerTurn]
    local y = Board.messageY[self.playerTurn]
    love.graphics.printf(msg, x, y, Board.messageW, "left")
end

return State
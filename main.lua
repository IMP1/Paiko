---------------------
-- Global Constants
-------------------
TileSize = 32
PieceImage = love.graphics.newImage("gfx/pieces.png")
Font = love.graphics.newImageFont("gfx/font.png", "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-,!:()[]{}_|'")
Colours = {
    Background = {  96,  88, 104, 255 },
    Placeable  = { 224, 224, 216,  92 },
    Highlight  = { 224, 224, 216,  92 },
    Shiftable  = {  56,  64,  80,  92 },
    Attacking  = {  96,  40,  40,  92 },
    Defending  = {  64,  80,  64,  92 },
}

------------------
-- PsuedoClasses
----------------

-- Pieces
Lotus = require("piece.lotus")
Sai   = require("piece.sai")
Bow   = require("piece.bow")
Sword = require("piece.sword")
Fire  = require("piece.fire")
Water = require("piece.water")
Earth = require("piece.earth")
Air   = require("piece.air")
-- Scenes
SceneGame = require("state.game")
-- Board
Board = require("class.board")

---------------------
-- Global Variables
-------------------
scene = nil

-------------------
-- load
-----------------
-- Sets initial scene and conditions
function love.load()
    love.graphics.setBackgroundColor(unpack(Colours.Background))
    love.graphics.setFont(Font)
    scene = SceneGame.new()
end

-----------------
-- update
---------------
-- dt : change in time since last frame
---------------
-- Updates the current scene
function love.update(dt)
    local mx, my = love.mouse.getPosition()
    if scene.update then scene:update(dt, mx, my) end
end

--------------------
-- draw
------------------
-- Calls the draw method of the current scene
function love.draw()
    love.graphics.setColor(255, 255, 255)
    if scene.draw then scene:draw() end
end

-------------------
-- keypressed & keyreleased
-----------------
--     key : key that's been pressed/released
-- unicode : player owning the homeground
-----------------
-- Alerts the current scene of a mouse press/release
function love.keypressed(key, unicode)
    if scene.keyPressed then scene:keyPressed(key, unicode) end
end
function love.keyreleased(key)
    if scene.keyReleased then scene:keyPressed(key) end
end

----------------
-- mousepressed & mousereleased
--------------
--   x : x (tile) co-ordinate
--   y : y (tile) co-ordinate
-- key : the mouse button being pressed/released
--------------
-- Alerts the current scene of a mouse press/release
function love.mousepressed(x, y, key)
    if scene.mousePressed then scene:mousePressed(x, y, key) end
end
function love.mousereleased(x, y, key)
    if scene.mouseReleased then scene:mouseReleased(x, y, key) end
end

-----------------
-- focus
---------------
-- gained : whether we are losing or gaining focus
---------------
-- Alerts the current scene of the window losing/gaining focus
function love.focus(gained)
    if gained then
        if scene.focusGained then scene:focusGained() end
    else
        if scene.focusLost then scene:focusLost() end
    end
end

function love.quit()
    for i, line in pairs(scene.actionLog) do
        print(line)
    end
end

-------------
-- contains
-----------
--    t : table to search through
-- item : value to search for
-----------
-- Returns whether a table contains a value (shallow search, O(n))
function table.contains(t, item)
    for k, v in pairs(t) do
        if v == item then return true end
    end
    return false
end
love.graphics.setDefaultFilter("nearest", "nearest")
local Player = require("player")
local Coin = require("coin")
local Spike = require("spike")
local Stone = require("stone")
local Enemy = require("enemy")
local GUI = require("gui")
local Camera = require("camera")
local Map = require("map")
--local Music = require("music")


function love.load()
  Enemy.loadAssets()
  Map:load()
  GUI:load()
  Player:load()
  --Music:load()
end

function love.update(dt)
  World:update(dt)
  Player:update(dt)
  GUI:update(dt)
  Coin.updateAll(dt)
  Spike.updateAll(dt)
  Stone.updateAll(dt)
  Enemy.updateAll(dt)
  Camera:setPosition(Player.x, 0)
  Map:update(dt)
end

function love.draw()
  love.graphics.draw(background)
  Map.level:draw(-Camera.x,-Camera.y,Camera.scale,Camera.scale)
  
  Camera:apply()
  Player:draw()
  Coin.drawAll()
  Spike.drawAll()
  Stone.drawAll()
  Enemy.drawAll()
  Camera:clear()
  
  GUI:draw()
end

function beginContact(a, b, collision)
  if Coin.beginContact(a, b, collision) then return end
  if Spike.beginContact(a, b, collision) then return end
  Enemy.beginContact(a, b, collision)
  Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
  Player:endContact(a, b, collision)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
  
  if key == "z" then
    Player:jump()
  end
  
  if key == "x" then
    Player:shiftWorld()
    Map:changeWorld()
    print(Map.currentWorld)
  end
  
  --[[
  if key == "1" then
    Music:playSynth()
  end
  
  if key == "2" then
    Music:playBeat()
  end
  --]]
end
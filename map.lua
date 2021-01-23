local Map = {}
local STI = require("sti")
local Coin = require("coin")
local Spike = require("spike")
local Stone = require("stone")
local Enemy = require("enemy")
local Player = require("player")

function Map:load()
  self.currentLevel = 1
  World = love.physics.newWorld(0,2000)
  World:setCallbacks(beginContact, endContact)
  
  self:init()
end

function Map:next()
  self:clean()
  self.currentLevel = self.currentLevel + 1
  self:init()
  Player:resetPosition()
end

function Map:clean()
  self.level:box2d_removeLayer("solid")
  Coin:removeAll()
  Stone:removeAll()
  Spike:removeAll()
  Enemy:removeAll()
end

function Map:update(dt)
  if Player.x > MapWidth - 16 then
    self:next()
  end
end

function Map:init()
  self.level = STI("assets/map/"..self.currentLevel..".lua", {"box2d"})
  self.level:box2d_init(World)
  
  self.solidLayer = self.level.layers.solid
  self.mainLayer = self.level.layers.main
  self.entityLayer = self.level.layers.entity
  
  MapWidth = self.mainLayer.width * 16
  self.solidLayer.visible = false
  self.entityLayer.visible = false
  background = love.graphics.newImage("assets/background.png")
  
  self:spawnEntities()
end

function Map:spawnEntities()
  for i,v in ipairs(self.entityLayer.objects) do
    if v.type == "Spike" then
      Spike.new(v.x + v.width / 2, v.y + v.height / 2)
    elseif v.type == "Stone" then
      Stone.new(v.x + v.width / 2, v.y + v.height / 2)
      elseif v.type == "Enemy" then
      Enemy.new(v.x + v.width / 2, v.y + v.height / 2)
    elseif v.type == "Coin" then
      Coin.new(v.x, v.y)
    end
  end
end

return Map
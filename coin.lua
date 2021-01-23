local Coin = {img = love.graphics.newImage("assets/coin.png")}
Coin.width = Coin.img:getWidth()
Coin.height = Coin.img:getHeight()
Coin.__index = Coin
local ActiveCoins = {}
local Player = require("player")

function Coin.new(x,y) --creats new Coin class
  local instance = setmetatable({}, Coin)
  instance.x = x
  instance.y = y
  instance.scaleX = 1
  instance.randomTimeOffset = math.random(0, 100)
  instance.toBeRemoved = false
  
  instance.physics = {}
  instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
  instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
  instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
  instance.physics.fixture:setSensor(true)
  table.insert(ActiveCoins, instance)
end

function Coin:remove() --removes coin when called
  for i,instance in ipairs(ActiveCoins) do
    if instance == self then
      Player:incrementCoins()
      print(Player.coins)
      self.physics.body:destroy()
      table.remove(ActiveCoins, i)
    end
  end
end

function Coin:removeAll()
  for i,v in ipairs(ActiveCoins) do
    v.physics.body:destroy(v)
  end
  
  ActiveCoins = {}
end

function Coin:update(dt)
  self:spin(dt)
  self:checkRemove()
end

function Coin:checkRemove() --potentially self-explanatory
  if self.toBeRemoved then
    self:remove()
  end
end

function Coin:spin(dt) --uses a sine wave to make the coin speen
  self.scaleX = math.sin(love.timer.getTime() * 3 + self.randomTimeOffset)
end

function Coin:draw()
  love.graphics.draw(self.img, self.x, self.y, 0, self.scaleX, 1, self.width / 2, self.height / 2)
end

function Coin.updateAll(dt) --updates each coin
  for i,instance in ipairs(ActiveCoins) do
    instance:update(dt)
  end
end

function Coin.drawAll() --draws each coin
  for i,instance in ipairs(ActiveCoins) do
    instance:draw()
  end
end

function Coin.beginContact(a, b, collision) --checks if coin is colliding with player and removes itself if so
  for i,instance in ipairs(ActiveCoins) do
    if a == instance.physics.fixture or b == instance.physics.fixture then
      if a == Player.physics.fixture or b == Player.physics.fixture then
        instance.toBeRemoved = true
        return true
      end
    end
  end
end

return Coin
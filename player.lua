local Player = {}
function Player:load()  --loads variables and other shit
  self.x = 100
  self.y = 0
  self.startX = self.x
  self.startY = self.y
  self.width = 18
  self.height = 16
  self.xVel = 0
  self.yVel = 100
  self.maxSpeed = 250
  self.acceleration = 4000
  self.friction = 3500
  self.gravity = 1500
  self.jumpAmount = -500
  self.coins = 0
  self.health = {current = 3, max = 3}
  
  self.color = {
    red = 1,
    green = 1,
    blue = 1,
    speed = 3
    }
  
  self.graceTime = 0
  self.graceDuration = 0.1
  
  self.alive = true
  self.grounded = false
  self.jumps = {current = 2, max = 2}
  
  self.shifted = false
  
  self.facingRight = true
  self.state = "idle"
  
  self:loadAssets()
  
  self.physics = {}
  self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
  self.physics.body:setFixedRotation(true)
  self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
  self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
  self.physics.body:setGravityScale(0)
end

function Player:loadAssets()
  self.animation = {timer = 0, rate = 0.1}
  self.animation.run = {total = 4, current = 1, img = {}}
  for i=1,self.animation.run.total do
    self.animation.run.img[i] = love.graphics.newImage("assets/player/run/"..i..".png")
  end
  
  self.animation.idle = {total = 15, current = 1, img = {}}
  for i=1,self.animation.idle.total do
    self.animation.idle.img[i] = love.graphics.newImage("assets/player/idle/"..i..".png")
  end
  
  self.animation.air = {total = 9, current = 1, img = {}}
  for i=1,self.animation.air.total do
    self.animation.air.img[i] = love.graphics.newImage("assets/player/air/"..i..".png")
  end
  
  self.animation.draw = self.animation.idle.img[1]
  self.animation.width = self.animation.draw:getWidth()
  self.animation.height = self.animation.draw:getHeight()
end

function Player:takeDamage(amount) --makes the player take a certain amount of damage when called
  self:tintRed()
  if self.health.current > 0 then
    self.health.current = self.health.current - amount
    
  else
    self.health.current = 0
  end
  if self.health.current == 0 then --stupidest fix ever but putting this in the else statement makes it not work and i don't know why
    self:die()
  end
  print("Player health: "..self.health.current)
end

function Player:die() --unnecessary
  self.alive = false
  self.yVel = 0
end

function Player:respawn() --respawns the player by setting it back to its starting x and y coords
  if not self.alive then
    self:resetPosition()
    self.health.current = self.health.max
    self.alive = true
  end
end

function Player:resetPosition()
  self.physics.body:setPosition(self.startX, self.startY)
end

function Player:tintRed() --tints the player red when called (is tint really a verb?)
  self.color.green = 0
  self.color.blue = 0
end

function Player:incrementCoins() --also unnecessary but slightly less so due to lua not having += (please lua devs just add semicolons it will make everything so much easier and let you implement so many things)
  self.coins = self.coins + 1
end

function Player:update(dt) --updates the functions
  self:unTint(dt)
  self:setState()
  self:setDirection()
  self:animate(dt)
  self:decreaseGraceTime(dt)
  self:syncPhysics()
  self:move(dt)
  self:applyGravity(dt)
  self:respawn()
end

function Player:shiftWorld()
  if self.shifted then
    self.shifted = false
  else
    self.shifted = true
  end
  print(self.shifted)
end

function Player:unTint(dt) --sets player back to original color
  self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
  self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
  self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

function Player:setState() --Changes the player's animation depending on what they are doing
  if not self.grounded then
    self.state = "air"
  elseif self.xVel == 0 then
    self.state = "idle"
  else
    self.state = "run"
  end
end

function Player:setDirection() --sets player's direction
  if self.xVel < 0 then
    self.facingRight = false
  elseif self.xVel > 0 then
    self.facingRight = true
  end
end

function Player:animate(dt) --animates the player by changing the frames at 10fps
  self.animation.timer = self.animation.timer + dt
  if self.animation.timer > self.animation.rate then
    self.animation.timer = 0
    self:setNewFrame()
  end
end

function Player:setNewFrame() --sets the new frame by adding to anim.current until it reaches anim.total
  local anim = self.animation[self.state]
  if anim.current < anim.total then
    anim.current = anim.current + 1
  else
    anim.current = 1
  end
  self.animation.draw = anim.img[anim.current]
end

function Player:decreaseGraceTime(dt) --decreases the grace time (really?)
  if not self.grounded then
    self.graceTime = self.graceTime - dt
  end
end

function Player:applyGravity(dt) --increases the yVel by gravity until the player is on the ground
  if not self.grounded then
    self.yVel = self.yVel + self.gravity * dt
  end
end

function Player:move(dt) --self explanatory
  if love.keyboard.isDown("right") then
    self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed) -- adds acceleration to xVel until it reaches maxSpeed
  elseif love.keyboard.isDown("left") then
    self.xVel = math.max(self.xVel - self.acceleration * dt, -self.maxSpeed) -- subtractacts acceleration to xVel until it reaches -maxSpeed
  else
    self:applyFriction(dt)
  end
end

function Player:applyFriction(dt) --opposite of last function more or less
  if self.xVel > 0 then
    self.xVel = math.max(self.xVel - self.friction * dt, 0)
  elseif self.xVel < 0 then
    self.xVel = math.min(self.xVel + self.friction * dt, 0)
  else
    self.xVel = 0
  end
end

function Player:syncPhysics() --sets the player sprite to the physics body and the physics body to the x and y velocity
  self.x, self.y = self.physics.body:getPosition()
  self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Player:beginContact(a, b, collision) --checks for collision
  if self.grounded == true then return end
  
  local nx, ny = collision:getNormal()
  if a == self.physics.fixture then
    if ny > 0 then
      self:land(collision)
    elseif ny < 0 then
      self.yVel = 0
    end
  elseif b == self.physics.fixture then
    if ny < 0 then
      self:land(collision)
    elseif ny > 0 then
      self.yVel = 0
    end
  end
end

function Player:land(collision) --called when the player lands on the ground, sets everything that is supposed to happen in the air back to normal
  self.currentGroundCollision = collision
  self.yVel = 0
  self.grounded = true
  self.jumps.current = self.jumps.max
  self.graceTime = self.graceDuration
end

function Player:jump() --allows jumping until jumps.current reaches zero
  if self.jumps.current > 0 or self.graceTime == 0 then
    self.jumps.current = self.jumps.current - 1
    self.yVel = self.jumpAmount
    self.graceTime = 0
  end
end

function Player:endContact(a, b, collision) --checks when player is not in contact with a collision mask
  if a == self.physics.fixture or b == self.physics.fixture then
    if self.currentGroundCollision == collision then
      self.grounded = false
    end
  end
end

function Player:draw() --draws player to the screen
  local scaleX = 1
  if not self.facingRight then
    scaleX = -1
  end
  love.graphics.setColor(self.color.red, self.color.green, self.color.blue)
  love.graphics.draw(self.animation.draw, self.x, self.y, 0, scaleX, 1, self.animation.width / 2, self.animation.height / 2)
  love.graphics.setColor(1,1,1,1)
end

return Player
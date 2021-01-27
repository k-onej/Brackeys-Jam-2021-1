--[[
local Music = {}
function Music:load()
  self.lv1 = {}
  self.lv1.beat = love.audio.newSource("assets/mus/lv1/beat.wav", "stream")
  self.lv1.synth = love.audio.newSource("assets/mus/lv1/synth.wav", "stream")
  self.beatPlaying = false
  self.synthPlaying = false
  self.lv1.beat:setLooping(true)
  self.lv1.synth:setLooping(true)
  self.lv1.beat:play()
  self.lv1.synth:play()
end

function Music:update()
  
end

function Music:playBeat()
  if self.lv1.beatPlaying then
    self.lv1.beatPlaying = false
    self.lv1.beat:setVolume(0)
  else
    self.lv1.beatPlaying = true
    self.lv1.beat:setVolume(1)
  end
end

function Music:playSynth()
  if self.lv1.synthPlaying then
    self.lv1.synthPlaying = false
    self.lv1.synth:setVolume(0)
  else
    self.lv1.synthPlaying = true
    self.lv1.synth:setVolume(1)
  end
end

return Music
--]]
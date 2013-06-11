Game = class('Game', Base):include(Stateful)

function Game:initialize()
  Base.initialize(self)

  local Camera = require 'lib/camera'
  self.camera = Camera:new()
  self.camera.bounds = {
    negative_x = -100,
    negative_y = -100,
    positive_x = 100,
    positive_y = 100,
    negative_sx = 0.5,
    negative_sy = 0.5,
    positive_sx = 1.5,
    positive_sy = 1.5
  }

  self.font = g.newFont(16)
  g.setFont(self.font)

  self:gotoState("Loading")
end

function Game:update(dt)
end

function Game:render()
end

function Game:mousepressed(x, y, button)
end

function Game:mousereleased(x, y, button)
end

function Game:keypressed(key, unicode)
end

function Game:keyreleased(key, unicode)
end

function Game:joystickpressed(joystick, button)
  print(joystick, button)
end

function Game:joystickreleased(joystick, button)
  print(joystick, button)
end

function Game:focus(has_focus)
end

function Game:quit()
end

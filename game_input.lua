GameInput = class('GameInput', Base):include(Stateful)
GameInput.static.instance = nil

function GameInput:initialize(game)
  if GameInput.instance then
    return GameInput.instance
  end

  Base.initialize(self)
  GameInput.instance = self

  assert(instanceOf(Game, game))
  self.game = game

  self:gotoState("UIInactive")
end

function GameInput:update(dt)
  local mouse_x, mouse_y = love.mouse.getPosition()
  for key, action in pairs(self.control_map.mouse.update) do
    if love.mouse.isDown(key) then action(self, mouse_x, mouse_y) end
  end
end

function GameInput:mousepressed(x, y, button)
  local action = self.control_map.mouse.pressed[button]
  if is_func(action) then action(self, x, y) end
end

function GameInput:mousereleased(x, y, button)
  local action = self.control_map.mouse.released[button]
  if is_func(action) then action(self, x, y) end
end

function GameInput:keypressed(key, unicode)
  local action = self.control_map.keyboard.pressed[key]
  if is_func(action) then action(self, x, y) end
end

function GameInput:keyreleased(key, unicode)
  local action = self.control_map.keyboard.released[key]
  if is_func(action) then action(self, x, y) end
end

function GameInput:joystickpressed(joystick, button)
end

function GameInput:joystickreleased(joystick, button)
end

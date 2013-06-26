local UIActive = GameInput:addState('UIActive')

function UIActive:enteredState()
  print("active")
  self.control_map = {
    mouse = {
      pressed = {},
      released = {},
      update = {}
    },
    keyboard = {
      pressed = {},
      released = {}
    }
  }
end

function UIActive:exitedState()
end

return UIActive

local Main = Game:addState('Main')

function Main:enteredState()
  Collider = HC(100, self.on_start_collide, self.on_stop_collide)
  self:init_control_map()
end

function Main:update(dt)
  local mouse_x, mouse_y = self.camera:mousePosition(x, y)
  for key, action in pairs(self.control_map.mouse.update) do
    if love.mouse.isDown(key) then action(self, mouse_x, mouse_y) end
  end
end

function Main:render()
  self.camera:set()

  g.circle("fill", 100, 100, 20)

  self.camera:unset()
end

function Main:init_control_map()
  self.control_map = {
    mouse = {
      pressed = {
        r = self.right_mouse_down
      },
      released = {
        r = self.right_mouse_up
      },
      update = {
        r = self.right_mouse_update
      }
    },
    keyboard = {
      pressed = {},
      released = {}
    }
  }
end

function Main:right_mouse_down(x, y)
  self.right_mouse_down_pos = {x = x, y = y}
end

function Main:right_mouse_up(x, y)
  self.right_mouse_down_pos = nil
end

function Main:right_mouse_update(x, y)
  if self.right_mouse_down_pos then
    local down = self.right_mouse_down_pos
    -- x, y = self.camera:mousePosition(x, y)
    self.camera:setPosition(down.x - x, down.y - y)
  end
end

function Main:mousepressed(x, y, button)
  local mouse_x, mouse_y = self.camera:mousePosition(x, y)
  local action = self.control_map.mouse.pressed[button]
  if is_func(action) then action(self, mouse_x, mouse_y) end
end

function Main:mousereleased(x, y, button)
end

function Main:keypressed(key, unicode)
end

function Main:keyreleased(key, unicode)
end

function Main:joystickpressed(joystick, button)
end

function Main:joystickreleased(joystick, button)
end

function Main:focus(has_focus)
end

-- shape_one and shape_two are the colliding shapes. mtv_x and mtv_y define the minimum translation vector,
-- i.e. the direction and magnitude shape_one has to be moved so that the collision will be resolved.
-- Note that if one of the shapes is a point shape, the translation vector will be invalid.
function Main.on_start_collide(dt, shape_one, shape_two, mtv_x, mtv_y)
  local object_one, object_two = shape_one.parent, shape_two.parent

  if object_one and is_func(object_one.on_collide) then
    object_one:on_collide(dt, shape_one, shape_two, mtv_x, mtv_y)
  end

  if object_two and is_func(object_two.on_collide) then
    object_two:on_collide(dt, shape_one, shape_two, mtv_x, mtv_y)
  end
end

function Main.on_stop_collide(dt, shape_one, shape_two)
end

function Main:exitedState()
  Collider:clear()
  Collider = nil
end

return Main

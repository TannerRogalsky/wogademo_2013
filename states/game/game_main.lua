local Main = Game:addState('Main')

function Main:enteredState()
  local tile_size = 25

  Collider = HC(tile_size, self.on_start_collide, self.on_stop_collide)
  self:init_control_map()

  self.map = Map:new(0, 0, 50, 30, tile_size, tile_size)
  self.entity = MapEntity:new(self.map, 1, 1)
  self.map:add_entity(self.entity)
  self.entity.render = function(this) g.rectangle("fill", this.world_x, this.world_y, this.width * self.map.tile_width, this.height * self.map.tile_height) end
end

function Main:update(dt)
  local mouse_x, mouse_y = love.mouse.getPosition()
  for key, action in pairs(self.control_map.mouse.update) do
    if love.mouse.isDown(key) then action(self, mouse_x, mouse_y) end
  end
end

function Main:render()
  self.camera:set()
  g.setColor(COLORS.white:rgb())

  self.map:render()

  g.setColor(COLORS.blue:rgb())
  if self.selection_box then
    g.rectangle("line", unpack(self.selection_box))
  end

  for k,v in pairs(Collider:shapesInRange(-100, -100, 700, 700)) do
    v:draw("line")
  end

  self.camera:unset()
end

function Main:init_control_map()
  self.control_map = {
    mouse = {
      pressed = {
        l = self.left_mouse_down,
        r = self.right_mouse_down,
        wu = self.mouse_wheel_up,
        wd = self.mouse_wheel_down
      },
      released = {
        l = self.left_mouse_up,
        r = self.right_mouse_up
      },
      update = {
        l = self.left_mouse_update,
        r = self.right_mouse_update
      }
    },
    keyboard = {
      pressed = {
        up = function(self) self.entity:move(Direction.NORTH:unpack()) end,
        down = function(self) self.entity:move(Direction.SOUTH:unpack()) end,
        left = function(self) self.entity:move(Direction.WEST:unpack()) end,
        right = function(self) self.entity:move(Direction.EAST:unpack()) end
      },
      released = {}
    }
  }
end

function Main:left_mouse_down(x, y)
  -- local grid_x, grid_y = self.map:world_to_grid_coords(self.camera:mousePosition(x, y))
  -- print(self.map.grid:g(grid_x, grid_y):has_contents())
  local camera_x, camera_y = self.camera:mousePosition(x, y)
  self.left_mouse_down_pos = {x = camera_x, y = camera_y}
end

function Main:right_mouse_down(x, y)
  self.right_mouse_down_pos = {x = x, y = y}
end

function Main:left_mouse_up(x, y)
  if self.selection_box then
    local x, y, w, h = unpack(self.selection_box)
    local shapes = Collider:shapesInRange(x, y, x + w, y + h)
    for k,v in pairs(shapes) do
      print(v.parent)
    end
  end
  self.left_mouse_down_pos = nil
  self.selection_box = nil
end

function Main:right_mouse_up(x, y)
  self.right_mouse_down_pos, self.last_mouse_pos = nil, nil
end

function Main:mouse_wheel_up(x, y)
  self.camera:setScale(1, 1)
end

function Main:mouse_wheel_down(x, y)
  self.camera:setScale(1.25, 1.25)
end


function Main:left_mouse_update(x, y)
  if self.left_mouse_down_pos then
    local camera_x, camera_y = self.camera:mousePosition(x, y)
    local down = self.left_mouse_down_pos
    self.selection_box = {down.x, down.y, camera_x - down.x, camera_y - down.y}
  end
end

function Main:right_mouse_update(x, y)
  if self.right_mouse_down_pos and self.last_mouse_pos then
    local last = self.last_mouse_pos
    self.camera:move(last.x - x, last.y - y)
  end
  self.last_mouse_pos = {x = x, y = y}
end

function Main:mousepressed(x, y, button)
  local action = self.control_map.mouse.pressed[button]
  if is_func(action) then action(self, x, y) end
end

function Main:mousereleased(x, y, button)
  local action = self.control_map.mouse.released[button]
  if is_func(action) then action(self, x, y) end
end

function Main:keypressed(key, unicode)
  local action = self.control_map.keyboard.pressed[key]
  if is_func(action) then action(self, x, y) end
end

function Main:keyreleased(key, unicode)
  local action = self.control_map.keyboard.released[key]
  if is_func(action) then action(self, x, y) end
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

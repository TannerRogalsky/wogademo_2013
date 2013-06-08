local Main = Game:addState('Main')

function Main:enteredState()
  local tile_size = 25

  Collider = HC(tile_size, self.on_start_collide, self.on_stop_collide)
  self:init_control_map()

  self.map = Map:new(0, 0, 50, 30, tile_size, tile_size)

  -- this is all just debug stuff from here on down
  self.entity = MapEntity:new(self.map, 1, 1, 1, 1)
  self.map:add_entity(self.entity)
  self.entity.render = function(this) g.rectangle("fill", this.world_x, this.world_y, this.width * self.map.tile_width, this.height * self.map.tile_height) end

  local entity = MapEntity:new(self.map, 3, 2, 1, 1)
  self.map:add_entity(entity)
  entity.render = function(this) g.rectangle("fill", this.world_x, this.world_y, this.width * self.map.tile_width, this.height * self.map.tile_height) end

  entity = MapEntity:new(self.map, 3, 5, 1, 1)
  self.map:add_entity(entity)
  entity.render = function(this) g.rectangle("fill", this.world_x, this.world_y, this.width * self.map.tile_width, this.height * self.map.tile_height) end

  -- local path = self.map:find_path(self.entity.x, self.entity.y, 17, 25)
  -- self.entity:follow_path(path, 0.3)

  local function clear(gun) gun:clear_target() end

  local gun = Gun:new(self.map, 10, 13, 1, 1)
  self.map:add_entity(gun)
  gun:shoot_at(self.entity)
  cron.after(5, clear, gun)

  gun = Gun:new(self.map, 15, 24, 2, 2)
  self.map:add_entity(gun)
  gun:shoot_at(self.entity)
  cron.after(7, clear, gun)

  local tower = TowerRoom:new(self.map, 15, 15, 5, 5)
  self.map:add_entity(tower)
  tower = TowerRoom:new(self.map, 20, 15, 5, 5)
  self.map:add_entity(tower)
  tower = TowerRoom:new(self.map, 20, 10, 5, 5)
  self.map:add_entity(tower)
  tower = TowerRoom:new(self.map, 15, 10, 5, 5)
  self.map:add_entity(tower)
end

function Main:update(dt)
  local mouse_x, mouse_y = love.mouse.getPosition()
  for key, action in pairs(self.control_map.mouse.update) do
    if love.mouse.isDown(key) then action(self, mouse_x, mouse_y) end
  end

  Collider:update(dt)

  for id,bullet in pairs(Bullet.instances) do
    bullet:update(dt)
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

  for id,bullet in pairs(Bullet.instances) do
    bullet:render()
  end

  g.setColor(COLORS.blue:rgb())
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
        right = function(self) self.entity:move(Direction.EAST:unpack()) end,
        [" "] = function(self) self.entity:cancel_follow_path() end
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
  local grid_x, grid_y = self.map:world_to_grid_coords(self.camera:mousePosition(x, y))
  local tile = self.map.grid:g(grid_x, grid_y)

  -- did you click on a room?
  local room = tile:get_first_content_of_type(TowerRoom)

  -- move selected entities to a given room if it's been clicked, otherwise deselect them
  if self.selected_entities and room then

    local index = 1
    -- we may have multiple entities selected at once
    for id,entity in pairs(self.selected_entities) do

      -- don't try to put more crew than there are spaces for in a room
      while index <= room.max_crew do
        local target = room.crew_positions[index]

        -- there's nothing in that position, let's move to it!
        if room.occupied_crew_positions[target] == nil then
          room.occupied_crew_positions[target] = entity

          -- clear out the tile we're currently on
          local current_tile = self.map.grid:g(entity.x, entity.y)
          local current_room = current_tile:get_first_content_of_type(TowerRoom)
          if current_room then
            current_room.occupied_crew_positions[current_tile] = nil
          end

          -- go!
          local path = self.map:find_path(entity.x, entity.y, target.x, target.y)
          entity:follow_path(path)

          -- we're moving so we stop looking for a spot
          index = index + 1
          break
        end

        index = index + 1
      end
    end
  else
    self.selected_entities = nil
  end
end

function Main:left_mouse_up(x, y)
  if self.selection_box then
    local x, y, w, h = unpack(self.selection_box)
    local shapes = Collider:shapesInRange(x, y, x + w, y + h)
    self.selected_entities = {}
    for _,shape in pairs(shapes) do
      local entity = shape.parent
      if is_func(entity.follow_path) then
        self.selected_entities[entity.id] = entity
      end
    end
  end
  self.left_mouse_down_pos = nil
  self.selection_box = nil
end

function Main:right_mouse_up(x, y)
  self.right_mouse_down_pos, self.last_mouse_pos = nil, nil
end

function Main:mouse_wheel_up(x, y)
  self.camera:scale(0.9, 0.9)
end

function Main:mouse_wheel_down(x, y)
  self.camera:scale(1.1, 1.1)
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
  print(object_one, object_two)

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

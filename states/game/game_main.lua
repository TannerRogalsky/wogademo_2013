local Main = Game:addState('Main')

function Main:enteredState()
  local tile_size = 25

  Collider = HC(tile_size, self.on_start_collide, self.on_stop_collide)
  self:init_control_map()

  self.map = Map:new(0, 0, 80, 50, tile_size, tile_size)
  self.selected_entities = {}

  local cx, cy = (g.getWidth() - self.map.width * self.map.tile_width) / 2, (g.getHeight() - self.map.height * self.map.tile_height) / 2
  self.camera:setPosition(-cx, -cy)

  -- this is all just debug stuff from here on down
  local num_room_x, num_room_y = 3, 3
  local room_width, room_height = 3, 3
  for i=0,num_room_x - 1 do
    for j=0,num_room_y - 1 do
      -- center the rooms on the map
      local x = math.floor(self.map.width / 2) - math.floor(num_room_x * room_width / 2) + room_width * i
      local y = math.floor(self.map.height / 2) - math.floor(num_room_y * room_height / 2) + room_height * j
      local room = TowerRoom:new(self.map, x, y, room_width, room_height)
      self.map.rooms[room.id] = room
      self.map:add_entity(room)
    end
  end
  for id,room in pairs(self.map.rooms) do
    room:set_traversal_costs()
    local gun = Gun:new(self.map, room.x, room.y, room.width, room.height)
    room.emplacements[gun.id] = gun
    self.z = 1
    self.map:add_entity(gun)
  end

  for _,room in pairs(self.map.rooms) do
    for i=1,1 do
      local target = room:get_first_unoccupied_position()
      local entity = Crew:new(self.map, target.x, target.y)
      room:set_position(entity, target)
      room:add_crew(entity)
      self.map:add_entity(entity)
    end
  end

  cron.every(0.1, function()
    local enemy = self.map:spawn_enemy(Enemy)
    local target = self.map:get_closest_room(enemy.x, enemy.y)
    enemy:gotoState("Moving", target)
  end)
end

function Main:update(dt)
  local mouse_x, mouse_y = love.mouse.getPosition()
  for key, action in pairs(self.control_map.mouse.update) do
    if love.mouse.isDown(key) then action(self, mouse_x, mouse_y) end
  end

  Collider:update(dt)

  for id,room in pairs(self.map.rooms) do
    room:update(dt)
  end

  for id,bullet in pairs(Bullet.instances) do
    bullet:update(dt)
  end

  for id,enemy in pairs(Enemy.instances) do
    enemy:update(dt)
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

  -- g.setColor(COLORS.blue:rgb())
  -- for k,v in pairs(Collider:shapesInRange(-100, -100, 700, 700)) do
  --   v:draw("line")
  -- end

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
  -- local tile = self.map.grid:g(grid_x, grid_y)
  local camera_x, camera_y = self.camera:mousePosition(x, y)
  self.left_mouse_down_pos = {x = camera_x, y = camera_y}

  self:clear_selected_entities()
end

function Main:right_mouse_down(x, y)
  self.right_mouse_down_pos = {x = x, y = y}
  local grid_x, grid_y = self.map:world_to_grid_coords(self.camera:mousePosition(x, y))
  local tile, room = self.map.grid:g(grid_x, grid_y), nil

  -- did you click on a room?
  if tile then
    room = tile:get_first_content_of_type(TowerRoom)
  end

  -- move selected entities to a given room if it's been clicked, otherwise deselect them
  if room then

    local index = 1
    -- we may have multiple entities selected at once
    for id,entity in pairs(self.selected_entities) do

      local entity_tile = self.map.grid:g(entity.x, entity.y)
      local entity_room = entity_tile:get_first_content_of_type(TowerRoom)

      -- don't try to put more crew than there are spaces for in a room
      while #room.crew < room.max_crew and index <= room.max_crew and room ~= entity_room do
        local target = room.crew_positions[index]

        -- there's nothing in that position, let's move to it!
        if room.occupied_crew_positions[target] == nil then
          room.occupied_crew_positions[target] = entity

          -- set up an entity to show where we're headed
          local target_indicator = MapEntity:new(self.map, target.x, target.y)
          target_indicator.z = entity.z
          self.map:add_entity(target_indicator)
          target_indicator.render = function(self)
            local x, y = self:world_center()
            g.setColor(COLORS.deepskyblue:rgb())
            g.circle("fill", x, y, 5)
          end

          -- find the path
          local path = self.map:find_path(entity.x, entity.y, target.x, target.y)

          local is_pathing = entity.follow_path_target ~= nil

          -- clear out the tile we're on or the one we were headed to
          local occupied_tile = nil
          if is_pathing then
            occupied_tile = entity.follow_path_target
          else
            occupied_tile = self.map.grid:g(entity.x, entity.y)
          end

          -- actually clear the tile
          local current_room = occupied_tile:get_first_content_of_type(TowerRoom)
          if current_room then
            current_room.occupied_crew_positions[occupied_tile] = nil
          end
          current_room:remove_crew(entity)

          -- clear the path we're on right now if we are then follow the new path
          local function follow_path_wrapper()
            entity:follow_path(path, nil, function()
              if entity.follow_path_target == self.map.grid:g(entity.x, entity.y) then
                entity:at_path_target()
              end
              self.map:remove_entity(target_indicator)
            end)
          end
          if is_pathing then
            entity:cancel_follow_path(follow_path_wrapper)
          else
            follow_path_wrapper()
          end

          -- we're moving so we stop looking for a spot
          index = index + 1
          break
        end

        index = index + 1
      end
    end
  else
    self:clear_selected_entities()
  end
end

function Main:left_mouse_up(x, y)
  if self.selection_box then
    local x, y, w, h = unpack(self.selection_box)
    local shapes = Collider:shapesInRange(x, y, x + w, y + h)
    for _,shape in pairs(shapes) do
      local entity = shape.parent
      if instanceOf(Crew, entity) then
        self.selected_entities[entity.id] = entity
        entity.selected = true
      end
    end
  end
  self.left_mouse_down_pos = nil
  self.selection_box = nil
end

function Main:right_mouse_up(x, y)
  self.right_mouse_down_pos = nil
end

function Main:mouse_wheel_up(x, y)
  local center_x, center_y = g.getWidth() / 2, g.getHeight() / 2
  local cw, ch = center_x * self.camera.scaleX, center_y * self.camera.scaleY
  self.camera:scale(0.9, 0.9)
  local delta_cw, delta_ch = cw - center_x * self.camera.scaleX, ch - center_y * self.camera.scaleY
  self.camera:move(delta_cw, delta_ch)
end

function Main:mouse_wheel_down(x, y)
  local center_x, center_y = g.getWidth() / 2, g.getHeight() / 2
  local cw, ch = center_x * self.camera.scaleX, center_y * self.camera.scaleY
  self.camera:scale(1.1, 1.1)
  local delta_cw, delta_ch = cw - center_x * self.camera.scaleX, ch - center_y * self.camera.scaleY
  self.camera:move(delta_cw, delta_ch)
end


function Main:left_mouse_update(x, y)
  if self.left_mouse_down_pos then
    local camera_x, camera_y = self.camera:mousePosition(x, y)
    local down = self.left_mouse_down_pos
    self.selection_box = {down.x, down.y, camera_x - down.x, camera_y - down.y}
  end
end

function Main:right_mouse_update(x, y)
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
  -- print(object_one, object_two)

  if object_one and is_func(object_one.on_collide) then
    object_one:on_collide(dt, object_two, mtv_x, mtv_y)
  end

  if object_two and is_func(object_two.on_collide) then
    object_two:on_collide(dt, object_one, mtv_x, mtv_y)
  end
end

function Main.on_stop_collide(dt, shape_one, shape_two)
end

function Main:clear_selected_entities()
  for _,entity in pairs(self.selected_entities) do
    entity.selected = false
  end
  self.selected_entities = {}
end

function Main:exitedState()
  Collider:clear()
  Collider = nil
end

return Main

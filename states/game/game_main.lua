local Main = Game:addState('Main')

function Main:enteredState()
  local tile_size = 25

  Collider = HC(tile_size, self.on_start_collide, self.on_stop_collide)

  self.player = Player:new()

  self.map = Map:new(0, 0, 80, 50, tile_size, tile_size)
  self.selected_entities = {}

  local cx, cy = (g.getWidth() - self.map.width * self.map.tile_width) / 2, (g.getHeight() - self.map.height * self.map.tile_height) / 2
  self.camera:setPosition(-cx, -cy)

  self.ui = GameUI:new(self)
  self.input_manager = GameInput:new(self)

  -- start setting up game objects
  local num_room_x, num_room_y = 3, 3
  local room_width, room_height = 3, 3

  self.tower = Tower:new(self.map,
    math.floor(self.map.width / 2) - math.floor(num_room_x * room_width / 2),
    math.floor(self.map.height / 2) - math.floor(num_room_y * room_height / 2))

  for i=0,num_room_x - 1 do
    for j=0,num_room_y - 1 do
      -- center the rooms on the map
      local x = math.floor(self.map.width / 2) - math.floor(num_room_x * room_width / 2) + room_width * i
      local y = math.floor(self.map.height / 2) - math.floor(num_room_y * room_height / 2) + room_height * j
      local room = TowerRoom:new(self.map, x, y, room_width, room_height)
      self.map.rooms[room.id] = room
      self.map:add_entity(room)
      self.tower:add_room(room)
    end
  end
  self.map:add_entity(self.tower)

  for id,room in pairs(self.map.rooms) do
    room:set_traversal_costs()
    local gun = Gun:new(self.map, room.x, room.y, room.width, room.height)
    room.emplacements[gun.id] = gun
    self.z = 1
    self.map:add_entity(gun)
  end

  self.crew = {}

  -- pop some starting guys into the rooms
  for _,room in pairs(self.map.rooms) do
    for i=1,1 do
      local target = room:get_first_unoccupied_position()
      local entity = Crew:new(self.map, target.x, target.y)
      room:set_position(entity, target)
      room:add_crew(entity)
      self.player.crew = self.player.crew + 1
      self.map:add_entity(entity)

      table.insert(self.crew, entity)
    end
  end
  self.ui:update_crew_text()

  -- start spawning enemies
  local enemies = {SmallSawEnemy, BigGundamEnemy}
  cron.every(0.1, function()
    local enemy = self.map:spawn_enemy(enemies[math.random(#enemies)])
    local target = self.map:get_closest_room(enemy.x, enemy.y)
    enemy:gotoState("Moving", target)
  end)
end

function Main:update(dt)
  self.input_manager:update(dt)
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
  -- for k,v in pairs(Collider:shapesInRange(-100, -100, 3000, 2000)) do
  --   v:draw("line")
  -- end

  self.camera:unset()
end

function Main:mousepressed(x, y, button)
  self.input_manager:mousepressed(x, y, button)
end

function Main:mousereleased(x, y, button)
  self.input_manager:mousereleased(x, y, button)
end

function Main:keypressed(key, unicode)
  self.input_manager:keypressed(key, unicode)
end

function Main:keyreleased(key, unicode)
  self.input_manager:keyreleased(key, unicode)
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

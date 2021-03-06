TowerRoom = class('TowerRoom', MapEntity)

function TowerRoom:initialize(parent, x, y, width, height)
  MapEntity.initialize(self, parent, x, y, width, height)

  self.walls, self.gates = {}, {}
  self.crew_positions = {}
  self.occupied_crew_positions = {}
  self.crew = {}
  self.tower = nil

  self.image = game.preloaded_image["room_filled.png"]
  self.crew_needed_image = game.preloaded_image["crew_needed.png"]

  for _, _, tile in self.parent:each(self.x, self.y, self.width, self.height) do
    -- check if you're in the outside row
    if tile.x == self.x or tile.y == self.y or tile.x == self.x + self.width - 1 or tile.y == self.y + self.height - 1 then
      -- put walls around the tower
      -- check if you're not midway down one of the outside rows
      if not (tile.x == self.x + math.floor(self.width / 2) or tile.y == self.y + math.floor(self.height / 2)) then
        local wall = Wall:new(self.parent, tile.x, tile.y)
        self.walls[wall.id] = wall
        table.insert(self.crew_positions, tile)
      else
        local gate = Gate:new(self.parent, tile.x, tile.y)
        self.gates[gate.id] = gate
      end
    else
      table.insert(self.crew_positions, tile)
    end
  end

  -- this is hard-coded, restricting the possible size of rooms
  -- should be done programmatically, maybe by checking neighbors
  -- or maybe this is the kind of thing that tiled would be good at
  self.standing_angles = {}
  self.standing_angles[self.crew_positions[1]] = math.rad(-45)
  self.standing_angles[self.crew_positions[2]] = math.rad(180 + 45)
  self.standing_angles[self.crew_positions[3]] = math.rad(-45)
  self.standing_angles[self.crew_positions[4]] = math.rad(45)
  self.standing_angles[self.crew_positions[5]] = math.rad(180 - 45)

  self.z = 100

  self.emplacements = {}
end

function TowerRoom:update(dt)
  for id,gun in pairs(self.emplacements) do
    gun:update(dt)
  end
end

function TowerRoom:set_traversal_costs()
  -- set traversal costs for both directions because it makes it easier and cheaper for astar calculations
  for _, _, tile in self.parent:each(self.x, self.y, self.width, self.height) do
    -- check if you're in the outside row
    if tile.x == self.x or tile.y == self.y or tile.x == self.x + self.width - 1 or tile.y == self.y + self.height - 1 then
      if not (tile.x == self.x + math.floor(self.width / 2) or tile.y == self.y + math.floor(self.height / 2)) then
        for direction,sibling in pairs(tile.siblings) do
          local room = sibling:get_first_content_of_type(TowerRoom)
          -- so, basically, you're in an outside row
          -- and you're not right in the middle of that row
          -- and the sibling that you're looking at either doesn't have a room
          -- or it's a room that isn't this one
          -- so it costs more to travel to it
          -- but it doesn't cost more to travel from the center of this row
          if room ~= self then
            sibling.traversal_cost[tile] = 100
            tile.traversal_cost[sibling] = 100
          end
        end
      end
    end
  end
end

function TowerRoom:get_first_unoccupied_position()
  local index = 1
  while index <= self:get_max_crew() do
    local target = self.crew_positions[index]
    if self.occupied_crew_positions[target] == nil then
      return target
    end
    index = index + 1
  end
  return nil
end

function TowerRoom:get_max_crew()
  local max_crew = 0
  for id,gun in pairs(self.emplacements) do
    max_crew = max_crew + gun.max_crew
  end
  return max_crew
end

function TowerRoom:set_position(entity, target)
  assert(instanceOf(MapEntity, entity))
  assert(instanceOf(MapTile, target))
  self.occupied_crew_positions[target] = entity
end

function TowerRoom:add_crew(crew)
  table.insert(self.crew, crew)
  crew.color = COLORS.white

  for id,gun in pairs(self.emplacements) do
    gun:update_crew_upgrades(#self.crew)
  end
end

function TowerRoom:remove_crew(crew)
  local crew_table_index = nil

  for index,room_crew in ipairs(self.crew) do
    if room_crew == crew then
      crew_table_index = index
    end
  end

  if crew_table_index then
    table.remove(self.crew, crew_table_index)
    crew.color = COLORS.blue

    for id,gun in pairs(self.emplacements) do
      gun:update_crew_upgrades(#self.crew)
    end
  end
end

function TowerRoom:add_to_map(map)
  for id,wall in pairs(self.walls) do
    wall:insert_into_grid()
  end
  for id,gate in pairs(self.gates) do
    gate:insert_into_grid()
  end
end

function TowerRoom:remove_from_map(map)
  for id,wall in pairs(self.walls) do
    wall:remove_from_grid()
  end
  for id,gate in pairs(self.gates) do
    gate:remove_from_grid()
  end
end

function TowerRoom:render()
  local pixel_width, pixel_height = self.width * self.parent.tile_width, self.height * self.parent.tile_height
  local scale = 0.5

  g.setColor(COLORS.white:rgb())
  g.draw(self.image, self.world_x, self.world_y, 0, scale)

  local max_crew = self:get_max_crew()
  for index, crew_tile in ipairs(self.crew_positions) do
    if index > max_crew then break end

    -- there's no crew stationed here
    if self.occupied_crew_positions[crew_tile] == nil then
      local w, h = crew_tile.parent.tile_width, crew_tile.parent.tile_height
      local x = (crew_tile.x - 1) * w + w / 2
      local y = (crew_tile.y - 1) * h + h / 2
      local angle = 0
      g.draw(self.crew_needed_image, x, y, angle, scale, scale, w * scale * 2, h * scale * 2)
    end
  end

  local x, y = game.camera:mousePosition()
  if self:contains(x, y) then
    g.setColor(COLORS.yellow:rgb())
    g.rectangle("line", self.world_x, self.world_y, pixel_width - 1, pixel_height - 1)
  end
end

function TowerRoom:get_border_tiles()
  local tower = self.tower
  local border_tiles = {}
  for _, _, tile in self.parent:each(self.x - 1, self.y - 1, self.width + 2, self.height + 2) do
    if tower.border_tiles[tile.id] then
      table.insert(border_tiles, tile)
    end
  end
  return border_tiles
end

TowerRoom.__lt = MapEntity.__lt
TowerRoom.__le = MapEntity.__le

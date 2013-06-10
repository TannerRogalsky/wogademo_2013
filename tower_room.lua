TowerRoom = class('TowerRoom', MapEntity)

function TowerRoom:initialize(parent, x, y, width, height)
  MapEntity.initialize(self, parent, x, y, width, height)

  self.walls = {}
  self.max_crew = 0
  for _, _, tile in self.parent:each(self.x, self.y, self.width, self.height) do
    -- check if you're in the outside row
    if tile.x == self.x or tile.y == self.y or tile.x == self.x + self.width - 1 or tile.y == self.y + self.height - 1 then
      -- put walls around the tower
      local wall = Wall:new(self.parent, tile.x, tile.y)
      self.walls[wall.id] = wall
      wall.cost = 1
      -- check if you're not midway down one of the outside rows
      if not (tile.x == self.x + math.floor(self.width / 2) or tile.y == self.y + math.floor(self.height / 2)) then
        wall.cost = 100
      end
    else
      self.max_crew = self.max_crew + 1
    end
  end

  self.crew_positions = {}
  for _, _, tile in self.parent:each(x + 1, y + 1, width - 2, height - 2) do
    table.insert(self.crew_positions, tile)
  end
  self.occupied_crew_positions = {}

  self.z = 1
  self.render = self.base_mode_render

  LOD.delegates[self.id] = self
end

function TowerRoom:update(dt)
end

function TowerRoom:add_to_map(map)
  for id,wall in pairs(self.walls) do
    wall:insert_into_grid()
  end
end

function TowerRoom:remove_from_map(map)
  for id,wall in pairs(self.walls) do
    wall:remove_from_grid()
  end
end

function TowerRoom:base_mode_render()
  g.setColor(COLORS.coral:rgb())
  g.rectangle("fill", self.world_x, self.world_y, self.width * self.parent.tile_width, self.height * self.parent.tile_height)

  g.setColor(COLORS.green:rgb())
  for id,wall in pairs(self.walls) do
    wall:render()
  end
end

function TowerRoom:gun_mode_render()
  g.setColor(COLORS.coral:rgb())
  g.rectangle("fill", self.world_x, self.world_y, self.width * self.parent.tile_width, self.height * self.parent.tile_height)
end

function TowerRoom:on_graphics_scale(x, y, dx, dy)
  if x < 1 then
    self.parent.render_queue:delete(self)
    self.z = 1
    self.render = self.base_mode_render
    self.parent.render_queue:insert(self)
  else
    self.parent.render_queue:delete(self)
    self.z = 10
    self.render = self.gun_mode_render
    self.parent.render_queue:insert(self)
  end
end

function TowerRoom:on_graphics_translate()
end

TowerRoom.__lt = MapEntity.__lt
TowerRoom.__le = MapEntity.__le

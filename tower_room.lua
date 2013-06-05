TowerRoom = class('TowerRoom', MapEntity)

function TowerRoom:initialize(parent, x, y, width, height)
  MapEntity.initialize(self, parent, x, y, width, height)

  self.walls = {}
  for _, _, tile in self.parent:each(x, y, width, height) do
    if tile.x == x or tile.y == y or tile.x == x + width - 1 or tile.y == y + height - 1 then
      local wall = Wall:new(self.parent, tile.x, tile.y)
      self.walls[wall.id] = wall
    end
  end
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

function TowerRoom:render()
  for id,wall in pairs(self.walls) do
    wall:render()
  end
end

TowerRoom.__lt = MapEntity.__lt
TowerRoom.__le = MapEntity.__le

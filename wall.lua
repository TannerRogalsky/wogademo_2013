Wall = class('Wall', MapEntity)

function Wall:initialize(parent, x, y)
  MapEntity.initialize(self, parent, x, y, 1, 1)
end

function Wall:update(dt)
end

function Wall:cost_to_move_to(from_tile)
  local from_room = from_tile:get_first_content_of_type(TowerRoom)
  local to_tile = self.parent.grid:g(self.x, self.y)
  local to_room = to_tile:get_first_content_of_type(TowerRoom)

  if from_room and to_room then
    return 0
  else
    return 100
  end
end

function Wall:render()
  g.rectangle("line", (self.x - 1) * self.parent.tile_width, (self.y - 1) * self.parent.tile_height, self.width * self.parent.tile_width, self.height * self.parent.tile_height)
end

Wall.__lt = MapEntity.__lt
Wall.__le = MapEntity.__le

Wall = class('Wall', MapEntity)

function Wall:initialize(parent, x, y)
  MapEntity.initialize(self, parent, x, y, 1, 1)

  self.cost = 100
end

function Wall:update(dt)
end

function Wall:cost_to_move_to(from)
  local room = from:get_first_content_of_type(TowerRoom)

  if room then
    return 1
  else
    return self.cost
  end
end

function Wall:render()
  g.rectangle("fill", (self.x - 1) * self.parent.tile_width, (self.y - 1) * self.parent.tile_height, self.width * self.parent.tile_width, self.height * self.parent.tile_height)
end

Wall.__lt = MapEntity.__lt
Wall.__le = MapEntity.__le

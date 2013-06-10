Wall = class('Wall', MapEntity)

function Wall:initialize(parent, x, y)
  MapEntity.initialize(self, parent, x, y, 1, 1)
end

function Wall:render()
  g.setColor(COLORS.green:rgb())
  g.rectangle("line", self.world_x, self.world_y, self.width * self.parent.tile_width, self.height * self.parent.tile_height)
end

Wall.__lt = MapEntity.__lt
Wall.__le = MapEntity.__le

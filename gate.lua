Gate = class('Gate', MapEntity)

function Gate:initialize(parent, x, y)
  MapEntity.initialize(self, parent, x, y, 1, 1)
end

function Gate:render()
  g.setColor(COLORS.lightblue:rgb())
  g.rectangle("line", self.world_x, self.world_y, self.width * self.parent.tile_width, self.height * self.parent.tile_height)
end

Gate.__lt = MapEntity.__lt
Gate.__le = MapEntity.__le

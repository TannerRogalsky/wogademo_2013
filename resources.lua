Resources = class('Resources', MapEntity)
Resources.static.instances = {}

function Resources:initialize(parent, x, y)
  MapEntity.initialize(self, parent, x, y, 1, 1)

  self.worth = 10
  Resources.instances[self.id] = self
end

function Resources:destroy()
  Resources.instances[self.id] = nil
end

function Resources:render()
  g.setColor(COLORS.magenta:rgb())
  g.rectangle("fill", self.world_x, self.world_y, self.width * self.parent.tile_width, self.height * self.parent.tile_height)
end

Resources.__lt = MapEntity.__lt
Resources.__le = MapEntity.__le

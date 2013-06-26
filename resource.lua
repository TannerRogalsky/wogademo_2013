Resource = class('Resource', MapEntity)
Resource.static.instances = {}

function Resource:initialize(parent, x, y)
  MapEntity.initialize(self, parent, x, y, 1, 1)

  self.worth = 10
  Resource.instances[self.id] = self
end

function Resource:destroy()
  self.parent:remove_entity(self)
  Resource.instances[self.id] = nil
end

function Resource:render()
  g.setColor(COLORS.magenta:rgb())
  g.rectangle("fill", self.world_x, self.world_y, self.width * self.parent.tile_width, self.height * self.parent.tile_height)
end

Resource.__lt = MapEntity.__lt
Resource.__le = MapEntity.__le

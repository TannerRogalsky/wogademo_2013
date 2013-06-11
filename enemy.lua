Enemy = class('Enemy', MapEntity)
MapEntity:include(Movable)
MapEntity:include(FollowsPath)

function Enemy:initialize(parent, x, y)
  MapEntity.initialize(self, parent, x, y, 1, 1)

  self.z = 151

  self.physics_body = Collider:addRectangle(self:world_bounds())
  self.physics_body.parent = self
  Collider:addToGroup("enemies", self.physics_body)
end

function Enemy:update(dt)
end

function Enemy:render()
  g.setColor(COLORS.cyan:rgb())
  g.rectangle("fill", self.world_x, self.world_y, self.width * self.parent.tile_width, self.height * self.parent.tile_height)
end

Enemy.__lt = MapEntity.__lt
Enemy.__le = MapEntity.__le

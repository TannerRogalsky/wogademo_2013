Enemy = class('Enemy', MapEntity)
Enemy:include(Movable)
Enemy:include(FollowsPath)
Enemy.static.instances = {}

function Enemy:initialize(parent, x, y)
  MapEntity.initialize(self, parent, x, y, 1, 1)

  self.z = 151
  self.speed = 50

  self.physics_body = Collider:addRectangle(self:world_bounds())
  self.physics_body.parent = self
  Collider:addToGroup("enemies", self.physics_body)

  Enemy.instances[self.id] = self
end

function Enemy:destroy()
  Enemy.instances[self.id] = nil
  self.parent:remove_entity(self)
  Collider:remove(self.physics_body)
  beholder.trigger("enemied_destroyed", self)
end

function Enemy:render()
  g.setColor(COLORS.cyan:rgb())
  g.rectangle("fill", self.world_x, self.world_y, self.width * self.parent.tile_width, self.height * self.parent.tile_height)
end

function Enemy:on_collide(dt, other, mtv_x, mtv_y)
  if instanceOf(Bullet, other) then
    self:destroy()
  end
end

Enemy.__lt = MapEntity.__lt
Enemy.__le = MapEntity.__le

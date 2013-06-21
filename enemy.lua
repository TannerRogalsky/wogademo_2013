Enemy = class('Enemy', MapEntity)
Enemy:include(Movable)
Enemy:include(FollowsPath)
Enemy.static.instances = {}

function Enemy:initialize(parent, x, y)
  MapEntity.initialize(self, parent, x, y, 1, 1)

  self.z = 151
  self.speed = 50

  self.damage = 3
  self.attack_speed = 0.6

  self.resource_drop_chance = 1 / 10

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

  if self.attacking_cron_id then cron.cancel(self.attacking_cron_id) end
  if self.transition_cron_id then cron.cancel(self.transition_cron_id) end

  if math.random() < self.resource_drop_chance then
    local resource = Resources:new(self.parent, self.x, self.y)
    self.parent:add_entity(resource)
  end
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

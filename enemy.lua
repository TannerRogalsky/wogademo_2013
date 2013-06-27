Enemy = class('Enemy', MapEntity)
Enemy:include(Movable)
Enemy:include(FollowsPath)
Enemy.static.instances = {}
Enemy.static.width = 3
Enemy.static.height = 3

function Enemy:initialize(parent, x, y, width, height)
  MapEntity.initialize(self, parent, x, y, Enemy.width, Enemy.height)

  self.z = 151
  self.speed = 50
  self.angle = 0
  self.health = 10

  self.damage = 3
  self.attack_speed = 0.6

  self.image = game.preloaded_image["enemy_large.png"]

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
    local resource = Resource:new(self.parent, self.x, self.y)
    self.parent:add_entity(resource)
  end
end

function Enemy:render()
  g.setColor(COLORS.white:rgb())
  local _, _, w, h = self:world_bounds()
  local x, y = self:world_center()

  g.draw(self.image, x, y, self.angle + math.pi / 2, 1, 1, w / 2, h / 2)
end

function Enemy:on_collide(dt, other, mtv_x, mtv_y)
  if instanceOf(Bullet, other) then
    self:damage_for(other.damage)
  end
end

function Enemy:damage_for(damage_value)
  self.health = self.health - damage_value
  if self.health <= 0 then
    self:destroy()
  end
end

Enemy.__lt = MapEntity.__lt
Enemy.__le = MapEntity.__le

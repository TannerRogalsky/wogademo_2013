Gun = class('Gun', MapEntity)

function Gun:initialize(parent, x, y, w, h)
  MapEntity.initialize(self, parent, x, y, w, h)

  self.target = nil
  self.angle = 0
  self.firing_speed = 0.3
  self.radius = self.width * self.parent.tile_width / 2

  self.z = 1

  self.render = self.base_mode_render

  self.image = game.preloaded_image["gun.png"]

  beholder.observe("enemied_destroyed", function(enemy)
    print("enemied_destroyed")
    if enemy == self.target then
      print("nilling")
      self:clear_target()
    end
  end)

  LOD.delegates[self.id] = self
end

function Gun:update(dt)
  if self.target then
    local x, y = self:world_center()
    self.angle = math.atan2(y - self.target.world_y, x - self.target.world_x)
  else
    local _, target = next(Enemy.instances)
    if target then
      self:shoot_at(target)
    end
  end
end

function Gun:shoot_at(target)
  assert(instanceOf(MapEntity, target))
  assert(self.firing_cron_id == nil)
  self.target = target
  self.firing_cron_id = cron.every(self.firing_speed, self.fire, self)
end

-- should only really be used by cron
function Gun:fire()
  assert(self.target ~= nil)
  local target_center_x, target_center_y = self.target:world_center()
  local center_x, center_y = self:world_center()
  local vx, vy = component_vectors(center_x, center_y, target_center_x, target_center_y)
  local speed = 200
  local bullet = Bullet:new(center_x, center_y, speed * vx, speed * vy)
end

function Gun:clear_target()
  self.target = nil
  cron.cancel(self.firing_cron_id)
  self.firing_cron_id = nil
end

function Gun:base_mode_render()
end

function Gun:gun_mode_render()
  g.setColor(COLORS.yellow:rgb())
  local x, y = self:world_center()
  g.circle("fill", x, y, self.radius)

  love.graphics.setColor(COLORS.black:rgb())
  local point_on_circle_x = x + self.radius * math.cos(self.angle + math.pi)
  local point_on_circle_y = y + self.radius * math.sin(self.angle + math.pi)
  love.graphics.line(x, y, point_on_circle_x, point_on_circle_y)

  -- draws from the center
  g.setColor(COLORS.white:rgb())
  g.draw(self.image, x, y, self.angle - math.pi / 2, 1, 1, self.width * self.parent.tile_width / 2, self.height * self.parent.tile_height / 2)
end

function Gun:on_graphics_scale(x, y, dx, dy)
  if x < 1 then
    self.parent.render_queue:delete(self)
    self.z = 1
    self.render = self.base_mode_render
    self.parent.render_queue:insert(self)
  else
    self.parent.render_queue:delete(self)
    self.z = 201
    self.render = self.gun_mode_render
    self.parent.render_queue:insert(self)
  end
end

function Gun:on_graphics_translate() end

Gun.__lt = MapEntity.__lt
Gun.__le = MapEntity.__le

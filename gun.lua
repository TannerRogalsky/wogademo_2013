Gun = class('Gun', MapEntity)
Gun.static.targets = {}

function Gun:initialize(parent, x, y, w, h)
  MapEntity.initialize(self, parent, x, y, w, h)

  self.target = nil
  self.angle = 0
  self.firing_speed = 0.3
  self.rotation_speed = math.rad(1)
  self.radius = self.width * self.parent.tile_width / 2

  self.z = 1

  self.render = self.base_mode_render

  self.image = game.preloaded_image["gun.png"]

  beholder.observe("enemied_destroyed", function(enemy)
    if enemy == self.target then
      self:clear_target()
    end
  end)

  LOD.delegates[self.id] = self
end

function Gun:update(dt)
  local x, y = self:world_center()

  if self.target then
    local target_x, target_y = self.target:world_center()
    local desired_angle = math.atan2(y - target_y, x - target_x)
    local delta_angle = desired_angle - self.angle
    delta_angle = math.clamp(-self.rotation_speed, delta_angle, self.rotation_speed)
    self.angle = self.angle + delta_angle
  else
    -- this seems to be a pretty common pattern. Maybe refactor?
    local _,closest = next(Enemy.instances)
    local distances = {closest = math.huge}

    for id,enemy in pairs(Enemy.instances) do

      local enemy_x, enemy_y = enemy:world_center()
      local distance = math.sqrt(math.pow(enemy_x - x, 2) + math.pow(enemy_y - y, 2))
      distances[enemy] = distance

      if Gun.targets[enemy.id] == nil and distance < distances[closest] then
        closest = enemy
      end
    end

    if closest and Gun.targets[closest.id] == nil then
      self:shoot_at(closest)
    end
  end
end

function Gun:shoot_at(target)
  assert(instanceOf(MapEntity, target))
  assert(self.firing_cron_id == nil)
  self.target = target
  Gun.targets[self.target.id] = self.target
  self.firing_cron_id = cron.every(self.firing_speed, self.fire, self)
end

-- should only really be used by cron
function Gun:fire()
  assert(self.target ~= nil)
  local center_x, center_y = self:world_center()
  local speed = 200
  local firing_angle = self.angle + math.pi
  local bullet = Bullet:new(center_x, center_y, speed * math.cos(firing_angle), speed * math.sin(firing_angle))
end

function Gun:clear_target()
  Gun.targets[self.target.id] = nil
  self.target = nil
  cron.cancel(self.firing_cron_id)
  self.firing_cron_id = nil
end

function Gun:base_mode_render()
end

function Gun:gun_mode_render()
  local x, y = self:world_center()
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

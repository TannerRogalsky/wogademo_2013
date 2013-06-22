Gun = class('Gun', MapEntity)
Gun.static.targets = {}

local vector  = require('lib.HardonCollider.vector-light')

function Gun:initialize(parent, x, y, w, h)
  MapEntity.initialize(self, parent, x, y, w, h)

  self.target = nil
  self.angle = 0
  self.firing_speed = 0.3
  self.rotation_speed = math.rad(1)
  self.radius = self.width * self.parent.tile_width / 2

  self.z = 200

  self.color = {}
  for k,v in pairs(COLORS.white) do
    self.color[k] = v
  end
  self.color.a = 0

  self.base_image = game.preloaded_image["base.png"]
  self.image = game.preloaded_image["gun.png"]

  beholder.observe("enemied_destroyed", function(enemy)
    if enemy == self.target then
      self:clear_target()
    end
  end)

  LOD.delegates[self.id] = self

  self.num_crew = 0
  self.max_crew = 1
  self.crew_upgrades = {
    [1] = {
      firing_speed = 0.3,
      rotation_speed = math.rad(1)
    },
    [2] = {
      firing_speed = 0.2,
      rotation_speed = math.rad(2)
    },
    [3] = {
      firing_speed = 0.1,
      rotation_speed = math.rad(3)
    },
    [4] = {
      firing_speed = 0.06,
      rotation_speed = math.rad(4)
    },
    [5] = {
      firing_speed = 0.03,
      rotation_speed = math.rad(5)
    }
  }

  self:gotoState("BaseMode")
end

function Gun:update(dt)
  local x, y = self:world_center()

  if self.target then
    local t, speed = self.target, 200
    local target_x, target_y = t:world_center()
    local target_vel_x, target_vel_y = t.speed * math.cos(t.angle), t.speed * math.sin(t.angle)
    local delta_x, delta_y = target_x - x, target_y - y

    local a = vector.dot(target_vel_x, target_vel_y, target_vel_x, target_vel_y) - (speed * speed)
    local b = 2 * vector.dot(target_vel_x, target_vel_y, delta_x, delta_y)
    local c = vector.dot(delta_x, delta_y, delta_x, delta_y)

    local p = -b / (2 * a)
    local q = math.sqrt((b * b) - 4 * a * c) / (2 * a)

    local t1 = p - q
    local t2 = p + q
    local t = nil

    if t1 > t2 and t2 > 0 then
      t = t2
    else
      t = t1
    end

    local aim_spot_x, aim_spot_y = vector.mul(t, target_vel_x, target_vel_y)
    aim_spot_x, aim_spot_y = vector.add(target_x, target_y, aim_spot_x, aim_spot_y)

    local desired_angle = math.atan2(y - aim_spot_y, x - aim_spot_x)
    local delta_angle = desired_angle - self.angle
    -- compensate for trying to rotate more than 180 degrees
    if math.abs(delta_angle) > math.pi then
      delta_angle = delta_angle - math.pi * 2
    end

    delta_angle = math.clamp(-self.rotation_speed, delta_angle, self.rotation_speed)
    self.angle = self.angle + delta_angle
  elseif self.num_crew > 0 then
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

function Gun:upgrade()
  self.max_crew = self.max_crew + 1
end

function Gun:update_crew_upgrades(num_crew)
  self.num_crew = num_crew

  local temp_target = self.target
  if self.target then self:clear_target() end

  if self.num_crew > 0 then
    for field,value in pairs(self.crew_upgrades[self.num_crew]) do
      self[field] = value
    end
  elseif self.target then
    self:clear_target()
  end

  if temp_target then self:shoot_at(temp_target) end
end

function Gun:render()
  local x, y = self:world_center()
  local c = self.color
  g.setColor(c.r, c.g, c.b, c.a)

  g.draw(self.base_image, self.world_x, self.world_y)

  -- draws from the center
  g.draw(self.image, x, y, self.angle - math.pi / 2, 1, 1, self.width * self.parent.tile_width / 2, self.height * self.parent.tile_height / 2)
end

function Gun:on_graphics_translate() end

Gun.__lt = MapEntity.__lt
Gun.__le = MapEntity.__le

Gun = class('Gun', MapEntity)

function Gun:initialize(parent, x, y, w, h)
  MapEntity.initialize(self, parent, x, y, w, h)

  self.target = nil
  self.firing_speed = 0.3
  self.radius = self.width / 2

  self.z = 1

  self.render = self.base_mode_render

  LOD.delegates[self.id] = self
end

function Gun:update(dt)
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
  g.circle("fill", x, y, self.width * self.parent.tile_width / 2)
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

Gun.__lt = MapEntity.__lt
Gun.__le = MapEntity.__le

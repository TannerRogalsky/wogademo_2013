Gun = class('Gun', MapEntity)

function Gun:initialize(parent, x, y, w, h)
  MapEntity.initialize(self, parent, x, y, w, h)

  self.target = nil
  self.firing_speed = 0.3
end

function Gun:update(dt)
end

function Gun:shoot_at(target)
  assert(instanceOf(MapEntity, target))
  assert(self.firing_cron_id == nil)
  self.firing_cron_id = cron.every(self.firing_speed, self.fire, self)
end

-- should only really be used by cron
function Gun:fire()
  assert(self.target ~= nil)

end

function Gun:clear_target()
  self.target = nil
  cron.cancel(self.firing_cron_id)
  self.firing_cron_id = nil
end

function Gun:render()
  g.setColor(COLORS.red:rgb())
  g.rectangle("fill", (self.x - 1) * self.parent.tile_width, (self.y - 1) * self.parent.tile_height, self.width * self.parent.tile_width, self.height * self.parent.tile_height)
end

Gun.__lt = MapEntity.__lt
Gun.__le = MapEntity.__le

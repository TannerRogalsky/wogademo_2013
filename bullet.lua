Bullet = class('Bullet', Base)
Bullet.static.instances = {}
Bullet.static.keep_alive_time = 5

function Bullet:initialize(x, y, vel_x, vel_y, target)
  Base.initialize(self)

  self.x, self.y = x, y
  self.vel_x, self.vel_y = vel_x, vel_y
  self.target = target

  self.color = {}
  for k,v in pairs(COLORS.red) do
    self.color[k] = v
  end

  self.physics_body = Collider:addPoint(self.x, self.y)
  self.physics_body.parent = self
  Collider:addToGroup("friendly", self.physics_body)

  Bullet.instances[self.id] = self

  cron.after(Bullet.keep_alive_time, self.destroy, self)
end

function Bullet:update(dt)
  local dx, dy = self.vel_x * dt, self.vel_y * dt
  self.x = self.x + dx
  self.y = self.y + dy
  self.physics_body:move(dx, dy)
end

function Bullet:destroy()
  Bullet.instances[self.id] = nil
  Collider:remove(self.physics_body)
end

function Bullet:render()
  local c = self.color
  g.setColor(c.r, c.g, c.b, c.a)
  g.circle("fill", self.x, self.y, 5)
end

function Bullet:on_collide(dt, other, mtv_x, mtv_y)
  if instanceOf(Enemy, other) then
    self:destroy()
  end
end

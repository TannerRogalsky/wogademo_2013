Bullet = class('Bullet', Base)
Bullet.static.instances = {}
Bullet.static.keep_alive_time = 5

function Bullet:initialize(x, y, vel_x, vel_y, target)
  Base.initialize(self)

  self.x, self.y = x, y
  self.vel_x, self.vel_y = vel_x, vel_y
  self.target = target

  self.physics_body = Collider:addPoint(self.x, self.y)

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
end

function Bullet:render()
  g.setColor(COLORS.red:rgb())
  g.circle("fill", self.x, self.y, 5)
end

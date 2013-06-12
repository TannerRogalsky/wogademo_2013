local MovingToAttackingTransition = Enemy:addState('MovingToAttackingTransition')

function MovingToAttackingTransition:enteredState()
  local tile = self.parent.grid:g(self.x, self.y)
  local target_x, target_y = self.parent:grid_to_world_coords(tile.x, tile.y)

  self.angle = math.atan2(target_y - self.world_y, target_x - self.world_x)
  local distance = math.sqrt(math.pow(target_x - self.world_x, 2) + math.pow(target_y - self.world_y, 2))

  cron.after(distance / self.speed, self.gotoState, self, "Attacking")
end

function MovingToAttackingTransition:update(dt)
  self:move_by_pixel(self.speed * dt * math.cos(self.angle), self.speed * dt * math.sin(self.angle))
end

function MovingToAttackingTransition:exitedState()
  self.world_x, self.world_y = self.parent:grid_to_world_coords(self.x, self.y)
end

return MovingToAttackingTransition

local Moving = Enemy:addState('Moving')

function Moving:enteredState(target)
  self.target = target or self.target
  assert(instanceOf(TowerRoom, self.target))
end

function Moving:update(dt)
  local x, y = self:world_center()
  local target_center_x, target_center_y = self.target:world_center()
  self.angle = math.atan2(target_center_y - y, target_center_x - x)

  self:move_by_pixel(self.speed * dt * math.cos(self.angle), self.speed * dt * math.sin(self.angle))

  local current_tile = self.parent.grid:g(self.x, self.y)

  -- our current tile is in the list of tower border tiles
  if self.target.tower.border_tiles[current_tile.id] ~= nil then
    self:gotoState("MovingToAttackingTransition")
  end
end

function Moving:exitedState()
end

return Moving

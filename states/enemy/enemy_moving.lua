local Moving = Enemy:addState('Moving')

function Moving:enteredState(target)
  self.target = target or self.target
  assert(instanceOf(TowerRoom, self.target))
end

function Moving:update(dt)
  local x, y = self:world_center()
  local target_center_x, target_center_y = self.target:world_center()
  self.angle = math.atan2(target_center_y - y, target_center_x - x)

  local old_x, old_y = self.x, self.y

  self:move_by_pixel(self.speed * dt * math.cos(self.angle), self.speed * dt * math.sin(self.angle))

  local new_x, new_y = self.x, self.y

  if old_x ~= new_x or old_y ~= new_y then
    for _, _, tile in self.parent:each(self.x, self.y, self.width, self.height) do
      -- our current tile is in the list of tower border tiles
      if self.target.tower.border_tiles[tile.id] ~= nil then
        self:gotoState("MovingToAttackingTransition")
        break
      end
    end
  end
end

function Moving:exitedState()
end

return Moving

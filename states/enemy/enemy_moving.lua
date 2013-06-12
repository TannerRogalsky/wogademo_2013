local Moving = Enemy:addState('Moving')

function Moving:enteredState(target)
  self.target = target or self.target
  assert(instanceOf(MapEntity, self.target))
end

function Moving:update(dt)
  local x, y = self:world_center()
  local target_center_x, target_center_y = self.target:world_center()
  self.angle = math.atan2(target_center_y - y, target_center_x - x)
  self:move_by_pixel(self.speed * dt * math.cos(self.angle), self.speed * dt * math.sin(self.angle))

  for _, _, sibling in self.parent:each(self.x - 1, self.y - 1, 3, 3) do
    if sibling then
      local room = sibling:get_first_content_of_type(TowerRoom)

      if room then
        self:gotoState("MovingToAttackingTransition")
        break
      end
    end
  end
end

function Moving:exitedState()
end

return Moving

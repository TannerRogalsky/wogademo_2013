local Moving = Enemy:addState('Moving')

function Moving:enteredState(target)
  self.target = target or self.target
  assert(instanceOf(TowerRoom, self.target))
end

function Moving:update(dt)
  local x, y = self:world_center()
  local target_center_x, target_center_y = self.target:world_center()
  self.angle = math.atan2(target_center_y - y, target_center_x - x)

  local old_grid_x, old_grid_y = self.x, self.y

  self:move_by_pixel(self.speed * dt * math.cos(self.angle), self.speed * dt * math.sin(self.angle))

  -- we're in a new grid space so check if any of our siblings are TowerRooms
  if old_grid_x ~= self.x or old_grid_y ~= self.y then
    for _, _, sibling in self.parent:each(self.x - 1, self.y - 1, 3, 3) do
      if sibling then
        local room = sibling:get_first_content_of_type(TowerRoom)

        -- if there's a room, transition into a state where we move next to it
        if room then
          self:gotoState("MovingToAttackingTransition")
          break
        end
      end
    end
  end
end

function Moving:exitedState()
end

return Moving

local Moving = Enemy:addState('Moving')

function Moving:enteredState(target)
  self.target = target or self.target
  assert(instanceOf(MapEntity, self.target))

  self.speed = 0.3
end

function Moving:update(dt)
  local x, y = self:world_center()
  local target_center_x, target_center_y = self.target:world_center()
  self.angle = math.atan2(target_center_y - y, target_center_x - x)
  self:move_by_pixel(self.speed * math.cos(self.angle), self.speed * math.sin(self.angle))

  local tile = self.parent.grid:g(self.x, self.y)
  for index,direction in ipairs(Direction.list) do
    local sibling = tile.siblings[direction]

    if sibling then
      local room = sibling:get_first_content_of_type(TowerRoom)

      if room then
        self:gotoState(nil)
      end
    end
  end
end

function Moving:exitedState()
end

return Moving

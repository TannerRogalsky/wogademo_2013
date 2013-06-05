local Movable = {
  move = function(self, delta_x, delta_y)
    local new_x, new_y = self.x + delta_x, self.y + delta_y

    -- bounds check
    if new_x > 0 and new_x <= self.parent.width and
       new_y > 0 and new_y <= self.parent.height then
      self:remove_from_grid()
      self.x, self.y = new_x, new_y
      self:insert_into_grid()
      if self.physics_body then
        local world_dx = delta_x * self.parent.tile_width
        local world_dy = delta_y * self.parent.tile_height
        self.physics_body:move(world_dx, world_dy)
      end
    end
  end,

  move_to = function(self, x, y)
    self:move(x - self.x, y - self.y)
  end
}

return Movable

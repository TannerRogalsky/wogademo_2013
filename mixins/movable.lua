local Movable = {
  move = function(self, delta_x, delta_y)
    local new_x, new_y = self.x + delta_x, self.y + delta_y

    -- bounds check
    if new_x > 0 and new_x <= self.parent.width and
       new_y > 0 and new_y <= self.parent.height then
      self:remove_from_grid()
      self.x, self.y = new_x, new_y
      self:insert_into_grid()
    end
  end
}

return Movable

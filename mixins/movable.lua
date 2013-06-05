-- this should probably only be used by a map entity.
-- not sure what else you would use it on anyway

local Movable = {
  move = function(self, delta_x, delta_y)
    self:move_by_pixel(delta_x * self.parent.tile_width, delta_y * self.parent.tile_height)
  end,

  move_to = function(self, x, y)
    self:move(x - self.x, y - self.y)
  end,

  move_by_pixel = function(self, x, y)
    local new_x, new_y = self.world_x + x, self.world_y + y

    -- bounds check
    -- maybe not working on bottom and right bounds yet? off by one
    if new_x >= 0 and new_x < self.parent.width * self.parent.tile_width and
       new_y >= 0 and new_y < self.parent.height * self.parent.tile_height then

      -- the grid coordinate should be the center
      local _, _, bw, bh = self:world_bounds()
      local new_grid_x, new_grid_y = self.parent:world_to_grid_coords(new_x + bw / 2, new_y + bh / 2)
      self:remove_from_grid()
      self.x, self.y = new_grid_x, new_grid_y
      self.world_x, self.world_y = new_x, new_y
      self:insert_into_grid()

      if self.physics_body then
        self.physics_body:move(x, y)
      end
    end
  end
}

return Movable

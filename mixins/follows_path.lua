-- this works but there are going to be issue with cancelling a follow and then starting one right away
-- not sure how to solve that yet

local FollowsPath = {
  follow_path = function(self, path, speed)
    assert(type(path) == "table" and #path >= 1, "Path is wrong or too short")
    assert(self.follow_path_tween_id == nil, tostring(self) .. " is already following a path")
    speed = speed or 0.3
    self.follow_path_interrupt = false

    local function tween_to_index(index)
      local new_tile = path[index]
      if new_tile and self.follow_path_interrupt == false then
        if self.follow_path_cron_id == nil then
          self.follow_path_cron_id = cron.every(0.1, function()
            self.physics_body:moveTo(self:world_center())
          end)
        end
        local new_x, new_y = self.parent:grid_to_world_coords(new_tile.x, new_tile.y)

        self:remove_from_grid()
        self.x, self.y = new_tile.x, new_tile.y
        self:insert_into_grid()

        self.follow_path_tween_id = tween(speed, self, {world_x = new_x, world_y = new_y}, "linear", tween_to_index, index + 1)
      else
        self.follow_path_tween_id = nil
        -- clean up the cron and make sure to reset the physics body just in case
        cron.cancel(self.follow_path_cron_id)
        self.physics_body:moveTo(self:world_center())
        self.follow_path_cron_id = nil
      end
    end

    tween_to_index(1)
  end,

  cancel_follow_path = function(self)
    self.follow_path_interrupt = true
  end
}

return FollowsPath

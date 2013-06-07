-- this works but there might be issues with cancelling a path and then starting another one right away

local FollowsPath = {
  follow_path = function(self, path, speed, callback)
    assert(type(path) == "table" and #path >= 2, "Path is wrong or too short")
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

        if is_func(callback) then
          callback(self)
        end

        -- maybe this is a good solution to cancelling the path and then starting one right away?
        -- too tired to tell if it really scales
        if is_func(self.follow_path_interrupt_callback) then
          self:follow_path_interrupt_callback()
        end
        self.follow_path_interrupt_callback = nil
      end
    end

    -- the first path index is the starting node
    tween_to_index(2)
  end,

  cancel_follow_path = function(self, callback)
    self.follow_path_interrupt = true
    self.follow_path_interrupt_callback = callback
  end
}

return FollowsPath

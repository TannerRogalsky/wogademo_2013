-- requires the class include the movable mixin

local FollowsPath = {
  follow_path = function(self, path, speed)
    assert(type(path) == "table" and #path >= 1, "Path is wrong or too short")
    assert(self.follow_path_cron_id == nil, tostring(self) .. " is already following a path")
    speed = speed or 0.3
    index = 1
    self.follow_path_cron_id = cron.every(speed, function()
      local new_tile = path[index]
      if new_tile == nil then
        cron.cancel(self.follow_path_cron_id)
        self.follow_path_cron_id = nil
      else
        self:move_to(new_tile.x, new_tile.y)
        index = index + 1
      end
    end)
  end
}

return FollowsPath

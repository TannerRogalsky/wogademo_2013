Tower = class('Tower', MapEntity)

function Tower:initialize(parent, x, y)
  MapEntity.initialize(self, parent, x, y)

  self.health = 100
  self.rooms = {}
end

function Tower:set_dimensions_from_rooms()
  for id,room in pairs(self.rooms) do
    if room.x < self.x then
      local delta = self.x - room.x
      self.x = room.x
      self.width = self.width + delta
    end
    if room.y < self.y then
      local delta = self.y - room.y
      self.y = room.y
      self.height = self.height + delta
    end
    if room.x + room.width > self.x + self.width then
      local delta = (room.x + room.width - 1) - (self.x + self.width - 1)
      self.width = self.width + delta
    end
    if room.y + room.height > self.y + self.height then
      local delta = (room.y + room.height - 1) - (self.y + self.height - 1)
      self.height = self.height + delta
    end
  end
  self.world_x, self.world_y = self.parent:grid_to_world_coords(self.x, self.y)
end

function Tower:render()
  -- g.setColor(COLORS.red:rgb())
  -- g.rectangle("fill", self.world_x, self.world_y, self.width * self.parent.tile_width, self.height * self.parent.tile_height)
end

Tower.__lt = MapEntity.__lt
Tower.__le = MapEntity.__le

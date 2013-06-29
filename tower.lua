Tower = class('Tower', MapEntity)

function Tower:initialize(parent, x, y)
  MapEntity.initialize(self, parent, x, y)

  self.max_health = 100
  self.health = 100
  self.rooms = {}

  self.border_tiles = {}
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

function Tower:add_room(room)
  assert(instanceOf(TowerRoom, room))
  self.rooms[room.id] = room
  room.tower = self
  self:set_dimensions_from_rooms()
end

function Tower:add_to_map(map)
  for _, _, tile in map:each(self.x - 1, self.y - 1, self.width + 2, self.height + 2) do
    if tile.x == self.x - 1 or tile.y == self.y - 1 or tile.x == self.x + self.width or tile.y == self.y + self.height then
      self.border_tiles[tile.id] = tile
    end
  end
end

function Tower:damage_for(health)
  self.health = self.health - health
  GameUI.instance:update_health_bar()
end

function Tower:repair_for(health)
  self.health = self.health + health
  GameUI.instance:update_health_bar()
end

function Tower:render()
  -- g.setColor(COLORS.red:rgb())
  -- g.rectangle("fill", self.world_x, self.world_y, self.width * self.parent.tile_width, self.height * self.parent.tile_height)
end

Tower.__lt = MapEntity.__lt
Tower.__le = MapEntity.__le

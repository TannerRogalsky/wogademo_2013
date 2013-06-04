MapEntity = class('MapEntity', Base):include(Stateful)

function MapEntity:initialize(parent, x, y, width, height, z)
  Base.initialize(self)
  assert(instanceOf(Map, parent))
  assert(is_num(x) and is_num(y))
  assert(is_num(width) or width == nil)
  assert(is_num(height) or height == nil)
  assert(is_num(z) or z == nil)

  self.parent = parent
  self.x, self.y = x, y
  self.width, self.height = width or 1, height or 1
  self.z = z or 1
end

function MapEntity:update(dt)
end

function MapEntity:render()
end

function MapEntity:insert_into_grid()
  for _, _, tile in self.parent:each(self.x, self.y, self.width, self.height) do
    tile.content[self.id] = self
  end
end

function MapEntity:remove_from_grid()
  for _, _, tile in self.parent:each(self.x, self.y, self.width, self.height) do
    tile.content[self.id] = nil
  end
end

function MapEntity:move(delta_x, delta_y)
  self:remove_from_grid()
  self.x, self.y = self.x + delta_x, self.y + delta_y
  self:insert_into_grid()
end

function MapEntity:__lt(other)
  if self.z < other.z then return true
  elseif self.z == other.z and self.id < other.id then return true
  else return false
  end
end

function MapEntity:__le(other)
  return self < other
end

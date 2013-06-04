Map = class('Map', Base)
Map.render_queue_depth = 3 -- this is just a best guess of how much map entities overlap

function Map:initialize(x, y, width, height, tile_width, tile_height)
  Base.initialize(self)
  assert(is_num(x) and is_num(y) and is_num(width) and is_num(height))
  assert(is_num(tile_width) and is_num(tile_width))

  self.x, self.y = x, y
  self.width, self.height = width, height
  self.tile_width, self.tile_height = tile_width, tile_height

  self.render_queue = Skiplist.new(self.width * self.height * Map.render_queue_depth)
  self.entity_list = {}

  self.grid = Grid:new(self.width, self.height)
  self.each = function(self, ...) return self.grid:each(...) end
  for x,y,_ in self.grid:each() do
    self.grid[x][y] = MapTile:new(self, x, y)
  end
  for _,_,tile in self.grid:each() do
    for _,_,neighbor in self.grid:each(tile.x - 1, tile.y - 1, 3, 3) do
      local dir_x, dir_y = neighbor.x - tile.x, neighbor.y - tile.y
      local direction = Direction[dir_x][dir_y]

      if direction then
        tile.siblings[direction] = neighbor
      end
    end
  end

  -- grid a* functions
  local function adjacency(tile)
    return pairs(tile.siblings)
  end

  local function cost(from, to)
    return to:cost_to_move_to()
  end

  local function distance(from, goal)
    return math.abs(goal.x - from.x) + math.abs(goal.y - from.y)
  end

  self.grid_astar = AStar:new(adjacency, cost, distance)

  self.grid_canvas = g.newCanvas(self.grid.width * self.tile_width, self.grid.height * self.tile_height)
  g.setCanvas(self.grid_canvas)
  g.setColor(COLORS.white:rgb())
  for x, y, _ in self.grid:each() do
    g.rectangle("line", (x - 1) * self.tile_width, (y - 1) * self.tile_width, self.tile_height, self.tile_height)
  end
  g.setCanvas()
end

function Map:update(dt)
end

function Map:render()
  g.draw(self.grid_canvas, 0, 0)
  for index,entity in self.render_queue:ipairs() do
    entity:render()
  end
end

function Map:add_entity(entity)
  assert(instanceOf(MapEntity, entity))
  entity:insert_into_grid()
  self.entity_list[entity.id] = entity
  self.render_queue:insert(entity)
end

function Map:remove_entity(entity)
  assert(instanceOf(MapEntity, entity))
  entity:remove_from_grid()
  self.entity_list[entity.id] = nil
  self.render_queue:delete(entity)
end

function Map:grid_to_world_coords(x, y)
  return (x - 1) * self.tile_width + self.x, (y - 1) * self.tile_height + self.y
end

function Map:world_to_grid_coords(x, y)
  return math.floor(x / self.tile_width + self.x + 1), math.floor(y / self.tile_height - self.y + 1)
end

function Map.keypressed_up(self)
end

function Map.keypressed_right(self)
end

function Map.keypressed_down(self)
end

function Map.keypressed_left(self)
end

function Map:mousepressed(x, y, button)
end

function Map:mousereleased(x, y, button)
end

function Map:keypressed(key, unicode)
end

function Map:keyreleased(key, unicode)
end

function Map:joystickpressed(joystick, button)
end

function Map:joystickreleased(joystick, button)
end

function Map:focus(has_focus)
end

function Map:quit()
end
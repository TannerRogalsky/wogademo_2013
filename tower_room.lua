TowerRoom = class('TowerRoom', MapEntity)

function TowerRoom:initialize(parent, x, y, width, height)
  MapEntity.initialize(self, parent, x, y, width, height)

  self.walls, self.gates = {}, {}
  self.max_crew = 0
  self.crew_positions = {}

  for _, _, tile in self.parent:each(self.x, self.y, self.width, self.height) do
    -- check if you're in the outside row
    if tile.x == self.x or tile.y == self.y or tile.x == self.x + self.width - 1 or tile.y == self.y + self.height - 1 then
      -- put walls around the tower
      -- check if you're not midway down one of the outside rows
      if not (tile.x == self.x + math.floor(self.width / 2) or tile.y == self.y + math.floor(self.height / 2)) then
        local wall = Wall:new(self.parent, tile.x, tile.y)
        self.walls[wall.id] = wall
        table.insert(self.crew_positions, tile)
        self.max_crew = self.max_crew + 1
      else
        local gate = Gate:new(self.parent, tile.x, tile.y)
        self.gates[gate.id] = gate
      end
    else
      table.insert(self.crew_positions, tile)
      self.max_crew = self.max_crew + 1
    end
  end

  self.occupied_crew_positions = {}

  self.z = 1
  self.render = self.base_mode_render

  LOD.delegates[self.id] = self
end

function TowerRoom:update(dt)
end

function TowerRoom:set_traversal_costs()
  -- set traversal costs for both directions because it makes it easier and cheaper for astar calculations
  for _, _, tile in self.parent:each(self.x, self.y, self.width, self.height) do
    -- check if you're in the outside row
    if tile.x == self.x or tile.y == self.y or tile.x == self.x + self.width - 1 or tile.y == self.y + self.height - 1 then
      if not (tile.x == self.x + math.floor(self.width / 2) or tile.y == self.y + math.floor(self.height / 2)) then
        for direction,sibling in pairs(tile.siblings) do
          local room = sibling:get_first_content_of_type(TowerRoom)
          -- so, basically, you're in an outside row
          -- and you're not right in the middle of that row
          -- and the sibling that you're looking at either doesn't have a room
          -- or it's a room that isn't this one
          -- so it costs more to travel to it
          -- but it doesn't cost more to travel from the center of this row
          if room ~= self then
            sibling.traversal_cost[tile] = 100
            tile.traversal_cost[sibling] = 100
          end
        end
      end
    end
  end
end

function TowerRoom:add_to_map(map)
  for id,wall in pairs(self.walls) do
    wall:insert_into_grid()
  end
  for id,gate in pairs(self.gates) do
    gate:insert_into_grid()
  end
end

function TowerRoom:remove_from_map(map)
  for id,wall in pairs(self.walls) do
    wall:remove_from_grid()
  end
  for id,gate in pairs(self.gates) do
    gate:remove_from_grid()
  end
end

function TowerRoom:base_mode_render()
  g.setColor(COLORS.coral:rgb())
  g.rectangle("fill", self.world_x, self.world_y, self.width * self.parent.tile_width, self.height * self.parent.tile_height)

  for id,wall in pairs(self.walls) do
    wall:render()
  end
  -- for id,gate in pairs(self.gates) do
  --   gate:render()
  -- end
end

function TowerRoom:gun_mode_render()
  g.setColor(COLORS.coral:rgb())
  g.rectangle("fill", self.world_x, self.world_y, self.width * self.parent.tile_width, self.height * self.parent.tile_height)
end

function TowerRoom:on_graphics_scale(x, y, dx, dy)
  if x < 1 then
    self.parent.render_queue:delete(self)
    self.z = 1
    self.render = self.base_mode_render
    self.parent.render_queue:insert(self)
  else
    self.parent.render_queue:delete(self)
    self.z = 10
    self.render = self.gun_mode_render
    self.parent.render_queue:insert(self)
  end
end

function TowerRoom:on_graphics_translate()
end

TowerRoom.__lt = MapEntity.__lt
TowerRoom.__le = MapEntity.__le

local UIInactive = GameInput:addState('UIInactive')

function UIInactive:enteredState()
  print("inactive")
  self.control_map = {
    mouse = {
      pressed = {
        l = self.left_mouse_down,
        r = self.right_mouse_down,
        wu = self.mouse_wheel_up,
        wd = self.mouse_wheel_down
      },
      released = {
        l = self.left_mouse_up,
        r = self.right_mouse_up
      },
      update = {
        l = self.left_mouse_update,
        r = self.right_mouse_update
      }
    },
    keyboard = {
      pressed = {},
      released = {}
    }
  }
end

function UIInactive:left_mouse_down(x, y)
  local grid_x, grid_y = self.game.map:world_to_grid_coords(self.game.camera:mousePosition(x, y))
  local tile = self.game.map.grid:g(grid_x, grid_y)

  for id,entity in pairs(tile.content) do
    if is_func(entity.left_mouse_down) then
      entity:left_mouse_down(x, y)
    end
  end

  local camera_x, camera_y = self.game.camera:mousePosition(x, y)
  self.game.left_mouse_down_pos = {x = camera_x, y = camera_y}

  self.game:clear_selected_entities()
end

function UIInactive:right_mouse_down(x, y)
  self.game.right_mouse_down_pos = {x = x, y = y}
  local grid_x, grid_y = self.game.map:world_to_grid_coords(self.game.camera:mousePosition(x, y))
  local tile, room = self.game.map.grid:g(grid_x, grid_y), nil

  -- did you click on a room?
  if tile then
    room = tile:get_first_content_of_type(TowerRoom)
  end

  -- move selected entities to a given room if it's been clicked, otherwise deselect them
  if room then

    local index = 1
    -- we may have multiple entities selected at once
    for id,entity in pairs(self.game.selected_entities) do

      local entity_tile = self.game.map.grid:g(entity.x, entity.y)
      local entity_room = entity_tile:get_first_content_of_type(TowerRoom)

      -- don't try to put more crew than there are spaces for in a room
      while #room.crew < room:get_max_crew() and index <= room:get_max_crew() and room ~= entity_room do
        local target = room.crew_positions[index]


        -- there's nothing in that position, let's move to it!
        if room.occupied_crew_positions[target] == nil then
          room.occupied_crew_positions[target] = entity

          -- set up an entity to show where we're headed
          local target_indicator = MapEntity:new(self.game.map, target.x, target.y)
          target_indicator.z = entity.z
          self.game.map:add_entity(target_indicator)
          function target_indicator:render()
            local x, y = self:world_center()
            g.setColor(COLORS.deepskyblue:rgb())
            g.circle("fill", x, y, 5)
          end

          -- find the path
          local path = self.game.map:find_path(entity.x, entity.y, target.x, target.y)

          local is_pathing = entity.follow_path_target ~= nil

          -- clear out the tile we're on or the one we were headed to
          local occupied_tile = nil
          if is_pathing then
            occupied_tile = entity.follow_path_target
          else
            occupied_tile = self.game.map.grid:g(entity.x, entity.y)
          end

          -- actually clear the tile
          local current_room = occupied_tile:get_first_content_of_type(TowerRoom)
          if current_room then
            current_room.occupied_crew_positions[occupied_tile] = nil
          end
          current_room:remove_crew(entity)

          -- clear the path we're on right now if we are then follow the new path
          local function follow_path_wrapper()
            entity:follow_path(path, nil, function()
              if entity.follow_path_target == self.game.map.grid:g(entity.x, entity.y) then
                entity:at_path_target()
              end
              self.game.map:remove_entity(target_indicator)
            end)
          end
          if is_pathing then
            entity:cancel_follow_path(follow_path_wrapper)
          else
            follow_path_wrapper()
          end

          -- we're moving so we stop looking for a spot
          index = index + 1
          break
        end

        index = index + 1
      end
    end
  else
    self.game:clear_selected_entities()
  end
end

function UIInactive:left_mouse_up(x, y)
  if self.game.selection_box then
    local x, y, w, h = unpack(self.game.selection_box)
    local shapes = Collider:shapesInRange(x, y, x + w, y + h)
    for _,shape in pairs(shapes) do
      local entity = shape.parent
      if instanceOf(Crew, entity) then
        self.game.selected_entities[entity.id] = entity
        entity.selected = true
      end
    end
  end
  self.game.left_mouse_down_pos = nil
  self.game.selection_box = nil
end

function UIInactive:right_mouse_up(x, y)
  self.game.right_mouse_down_pos = nil
end

function UIInactive:mouse_wheel_up(x, y)
  local center_x, center_y = g.getWidth() / 2, g.getHeight() / 2
  local cw, ch = center_x * self.game.camera.scaleX, center_y * self.game.camera.scaleY
  self.game.camera:scale(0.9, 0.9)
  local delta_cw, delta_ch = cw - center_x * self.game.camera.scaleX, ch - center_y * self.game.camera.scaleY
  self.game.camera:move(delta_cw, delta_ch)
end

function UIInactive:mouse_wheel_down(x, y)
  local center_x, center_y = g.getWidth() / 2, g.getHeight() / 2
  local cw, ch = center_x * self.game.camera.scaleX, center_y * self.game.camera.scaleY
  self.game.camera:scale(1.1, 1.1)
  local delta_cw, delta_ch = cw - center_x * self.game.camera.scaleX, ch - center_y * self.game.camera.scaleY
  self.game.camera:move(delta_cw, delta_ch)
end


function UIInactive:left_mouse_update(x, y)
  if self.game.left_mouse_down_pos then
    local camera_x, camera_y = self.game.camera:mousePosition(x, y)
    local down = self.game.left_mouse_down_pos
    self.game.selection_box = {down.x, down.y, camera_x - down.x, camera_y - down.y}
  end
end

function UIInactive:right_mouse_update(x, y)
end

function UIInactive:exitedState()
end

return UIInactive

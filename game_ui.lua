GameUI = class('GameUI', Base)
GameUI.static.instance = nil

function GameUI:initialize(game)
  if GameUI.instance then
    return GameUI.instance
  end

  Base.initialize(self)
  GameUI.instance = self

  self.game = game
  self.ui_font = g.newFont(20)

  local function draw_rect_and_children(object)
    g.setColor(COLORS.white:rgb())
    g.rectangle("fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())
    g.setColor(COLORS.black:rgb())
    g.rectangle("line", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())

    for _, child in ipairs(object.children) do
      child:draw()
    end
  end

  -- credits box
  self.credits_frame = loveframes.Create("frame")
  self.credits_frame:SetSize(200, 40)
  self.credits_frame:SetPos(g.getWidth() - self.credits_frame:GetWidth() - 20, 10)
  self.credits_frame:SetDraggable(false)
  self.credits_frame:ShowCloseButton(false)
  self.credits_frame.draw = draw_rect_and_children

  self.credits_text = loveframes.Create("text")
  self.credits_text:SetParent(self.credits_frame)
  self.credits_text:SetPos(20, 20)
  self.credits_text:CenterY()
  self.credits_text:SetFont(self.ui_font)
  self:update_credits_text()

  -- crew box
  self.crew_frame = loveframes.Create("frame")
  self.crew_frame:SetSize(200, 40)
  self.crew_frame:SetPos(g.getWidth() - self.crew_frame:GetWidth() - 20, self.credits_frame:GetY() + self.credits_frame:GetHeight() + 10)
  self.crew_frame:SetDraggable(false)
  self.crew_frame:ShowCloseButton(false)
  self.crew_frame.draw = draw_rect_and_children

  self.crew_text = loveframes.Create("text")
  self.crew_text:SetParent(self.crew_frame)
  self.crew_text:SetPos(20, 20)
  self.crew_text:CenterY()
  self.crew_text:SetFont(self.ui_font)
  self:update_crew_text()

  -- tower health bar
  self.tower_health_bar = loveframes.Create("progressbar")
  self.tower_health_bar:SetSize(g.getWidth() - 20 * 2, 25)
  self.tower_health_bar:SetPos(20, g.getHeight() - self.tower_health_bar:GetHeight() - 10)
  self.tower_health_bar:SetMinMax(0, 100)
  self.tower_health_bar:SetValue(100)
  self.tower_health_bar:SetLerp(true)

  -- get resources button
  self.collect_resources_button = loveframes.Create("button")
  self.collect_resources_button:SetText("Collect")
  self.collect_resources_button:SetPos(g.getWidth() - self.collect_resources_button:GetWidth() - 20,
  self.crew_frame:GetY() + self.crew_frame:GetHeight() + 10)
  function self.collect_resources_button.OnClick(button)
    local entities = game.selected_entities

    for _,entity in pairs(entities) do
      if next(Resource.instances) == nil then
        break
      end

      local function find_and_path(crew)
        assert(instanceOf(Crew, crew))

        local x, y = entity:world_center()
        local _, closest = next(Resource.instances)
        local distances = {closest = math.huge}

        -- find the closest resource to the given entity
        for _,resource in pairs(Resource.instances) do
          local resource_x, resource_y = resource:world_center()
          local distance = math.sqrt(math.pow(resource_x - x, 2) + math.pow(resource_y - y, 2))
          distances[resource] = distance

          if Crew.targeted_resources[resource.id] == nil and distance < distances[closest] then
            closest = resource
          end
        end

        -- we found the closest resource and nobody is headed toward it
        if closest and Crew.targeted_resources[closest.id] == nil then
          Crew.targeted_resources[closest.id] = closest
          local path = game.map:find_path(entity.x, entity.y, closest.x, closest.y)

          local is_pathing = entity.follow_path_target ~= nil
          local occupied_tile = self.game.map.grid:g(entity.x, entity.y)

          -- actually clear the tile
          local current_room = occupied_tile:get_first_content_of_type(TowerRoom)
          if current_room then
            current_room.occupied_crew_positions[occupied_tile] = nil
            current_room:remove_crew(entity)
          end

          if not is_pathing then
            entity:follow_path(path, nil, function()
              Crew.targeted_resources[closest.id] = nil

              -- got to the resource
              local resources = entity.follow_path_target:get_contents_of_type(Resource)
              for id,resource in pairs(resources) do
                self.game.player:collect(resource)
                resource:destroy()
              end

              -- TODO: this is sort of a hack and makes me sad
              -- follows_path still needs some work, you know?
              cron.after(0.0001, find_and_path, entity)
            end)
          end
        end
      end

      find_and_path(entity)
    end

    game:clear_selected_entities()
  end
  function self.collect_resources_button.OnMouseEnter(button)
    self.game.input_manager:gotoState("UIActive")
  end
  function self.collect_resources_button.OnMouseExit(button)
    self.game.input_manager:gotoState("UIInactive")
  end
end

function GameUI:show_upgrade_ui(gun)
  local upgrade_font = g.newFont(14)

  local ui = {}

  self.game.ui_active = true
  local x, y, w, h = gun:world_bounds()

  ui.upgrade_frame = loveframes.Create("frame")
  ui.upgrade_frame:SetSize(200, 200)
  ui.upgrade_frame:Center()
  ui.upgrade_frame:SetName("Upgrade")
  ui.upgrade_frame:SetScreenLocked(true)
  function ui.upgrade_frame.OnClose(object)
    self.game.input_manager:gotoState("UIInactive")
  end
  function ui.upgrade_frame.OnMouseEnter(object)
    self.game.input_manager:gotoState("UIActive")
  end
  function ui.upgrade_frame.OnMouseExit(object)
  end

  ui.base_image = loveframes.Create("image", ui.upgrade_frame)
  ui.base_image:SetImage(gun.base_image)
  ui.base_image:SetSize(50, 50)
  ui.base_image:SetPos(ui.upgrade_frame:GetWidth() - ui.base_image:GetWidth() - 10, 30)
  ui.base_image:SetScale(ui.base_image:GetWidth() / w, ui.base_image:GetHeight() / h)

  ui.gun_image = loveframes.Create("image", ui.upgrade_frame)
  ui.gun_image:SetImage(gun.image)
  ui.gun_image:SetSize(50, 50)
  ui.gun_image:SetPos(ui.upgrade_frame:GetWidth() - ui.gun_image:GetWidth() - 10, 30)
  ui.gun_image:SetScale(ui.gun_image:GetWidth() / w, ui.gun_image:GetHeight() / h)

  local padding_x, padding_y = 5, upgrade_font:getHeight() + 5

  ui.upgrade_button = loveframes.Create("button", ui.upgrade_frame)
  ui.upgrade_button:SetSize(125, 25)
  ui.upgrade_button:SetPos(padding_x, 30)
  function ui.upgrade_button.OnClick(button)
    if game.player.resources >= gun:upgrade_cost() then
      game.player:charge(gun:upgrade_cost())
      self:update_credits_text()
      gun:upgrade()
      self:update_upgrade_text(gun)
    else
      print("no can do, guv")
    end
  end

  ui.level_text = loveframes.Create("text", ui.upgrade_frame)
  ui.level_text:SetPos(padding_x, ui.upgrade_button:GetStaticY() + ui.upgrade_button:GetHeight() + 10)
  ui.level_text:SetFont(upgrade_font)

  ui.damage_text = loveframes.Create("text", ui.upgrade_frame)
  ui.damage_text:SetPos(padding_x, ui.level_text:GetStaticY() + padding_y)
  ui.damage_text:SetFont(upgrade_font)

  ui.shots_text = loveframes.Create("text", ui.upgrade_frame)
  ui.shots_text:SetPos(padding_x, ui.damage_text:GetStaticY() + padding_y)
  ui.shots_text:SetFont(upgrade_font)

  ui.rotation_text = loveframes.Create("text", ui.upgrade_frame)
  ui.rotation_text:SetPos(padding_x, ui.shots_text:GetStaticY() + padding_y)
  ui.rotation_text:SetFont(upgrade_font)

  self.upgrade_ui = ui
  self:update_upgrade_text(gun)
end

function GameUI:update_credits_text()
  self.credits_text:SetText({{COLORS.blue:rgb()}, game.player.resources .. " Credits"})
end

function GameUI:update_crew_text()
  self.crew_text:SetText({{COLORS.green:rgb()}, game.player.crew .. " Crew"})
end

function GameUI:update_upgrade_text(gun)
  local level = gun.max_crew
  local stats = gun.crew_upgrades[level]

  self.upgrade_ui.upgrade_button:SetText("Upgrade: " .. gun:upgrade_cost() .. " credits")
  self.upgrade_ui.level_text:SetText({{COLORS.black:rgb()}, "Level: " .. level})
  self.upgrade_ui.damage_text:SetText({{COLORS.black:rgb()}, "Damage: " .. stats.damage})
  self.upgrade_ui.shots_text:SetText({{COLORS.black:rgb()}, "Shots/minute: " .. 60 / stats.firing_speed})
  self.upgrade_ui.rotation_text:SetText({{COLORS.black:rgb()}, "Degrees/second: " .. math.deg(stats.rotation_speed)})
end

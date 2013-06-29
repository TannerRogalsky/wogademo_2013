GameUI = class('GameUI', Base)
GameUI.static.instance = nil

local function on_mouse_enter()
  game.input_manager:gotoState("UIActive")
end
local function on_mouse_exit()
  game.input_manager:gotoState("UIInactive")
end

function GameUI:initialize(game)
  if GameUI.instance then
    return GameUI.instance
  end

  Base.initialize(self)
  GameUI.instance = self

  self.game = game
  self.ui_font = g.newFont(20)

  local function draw_rect_and_children(object)
    g.setColor(object.background_color)
    g.rectangle("fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())
    g.setColor(COLORS.black:rgb())
    g.rectangle("line", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())

    for _, child in ipairs(object.children) do
      child:draw()
    end
  end

  -- credits box
  self.credits_frame = loveframes.Create("frame")
  self.credits_frame:SetSize(150, 36)
  self.credits_frame:SetPos(g.getWidth() - self.credits_frame:GetWidth() - 20, 10)
  self.credits_frame:SetDraggable(false)
  self.credits_frame:ShowCloseButton(false)
  self.credits_frame.draw = draw_rect_and_children
  self.credits_frame.background_color = {COLORS.white:rgb()}

  self.credits_text = loveframes.Create("text")
  self.credits_text:SetParent(self.credits_frame)
  self.credits_text:SetPos(5, 10)
  self.credits_text:SetFont(self.ui_font)
  self:update_credits_text()

  -- crew box
  self.crew_frame = loveframes.Create("frame")
  self.crew_frame:SetSize(150, 36)
  self.crew_frame:SetPos(g.getWidth() - self.crew_frame:GetWidth() - 20, self.credits_frame:GetY() + self.credits_frame:GetHeight() + 10)
  self.crew_frame:SetDraggable(false)
  self.crew_frame:ShowCloseButton(false)
  self.crew_frame.draw = draw_rect_and_children
  self.crew_frame.background_color = {COLORS.white:rgb()}

  self.crew_text = loveframes.Create("text")
  self.crew_text:SetParent(self.crew_frame)
  self.crew_text:SetPos(5, 10)
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
  self.collect_resources_button = loveframes.Create("imagebutton")
  self.collect_resources_button:SetText("")
  self.collect_resources_button:SetImage(game.preloaded_image["ui_sendoutcrew.png"])
  self.collect_resources_button:SizeToImage()
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
  self.collect_resources_button.OnMouseEnter = on_mouse_enter
  self.collect_resources_button.OnMouseExit = on_mouse_exit

  self.buy_crew_button = loveframes.Create("imagebutton")
  self.buy_crew_button:SetText("")
  self.buy_crew_button:SetImage(game.preloaded_image["ui_buycrew.png"])
  self.buy_crew_button:SizeToImage()
  self.buy_crew_button:SetPos(self.collect_resources_button:GetX() - self.buy_crew_button:GetWidth() - 20,
    self.crew_frame:GetY() + self.crew_frame:GetHeight() + 10)

  self.repair_tower_button = loveframes.Create("imagebutton")
  self.repair_tower_button:SetText("")
  self.repair_tower_button:SetImage(game.preloaded_image["ui_wall.png"])
  self.repair_tower_button:SizeToImage()
  self.repair_tower_button:SetPos(g.getWidth() - self.repair_tower_button:GetWidth() - 20,
    self.tower_health_bar:GetY() - self.repair_tower_button:GetHeight() - 10)
  function self.repair_tower_button.OnClick()
    self:show_wall_ui()
  end
end

function GameUI:show_upgrade_ui(gun)
  local upgrade_font = g.newFont(14)

  local ui = {}

  ui.upgrade_frame = loveframes.Create("frame")
  ui.upgrade_frame:SetSize(200, 200)
  ui.upgrade_frame:Center()
  ui.upgrade_frame:SetName("Upgrade")
  ui.upgrade_frame:SetScreenLocked(true)
  ui.upgrade_frame.OnMouseEnter = on_mouse_enter
  ui.upgrade_frame.OnClose = on_mouse_exit

  ui.image_frame = loveframes.Create("frame", ui.upgrade_frame)
  ui.image_frame:SetSize(50, 50)
  ui.image_frame:SetPos(ui.upgrade_frame:GetWidth() - ui.image_frame:GetWidth() - 10, 30)
  ui.image_frame:SetDraggable(false)
  ui.image_frame:ShowCloseButton(false)
  function ui.image_frame:draw()
    for _, child in ipairs(self.children) do
      child:draw()
    end
  end

  local x, y, w, h = gun:world_bounds()

  ui.base_image = loveframes.Create("image", ui.image_frame)
  ui.base_image:SetImage(gun.base_image)
  ui.base_image:SetSize(50, 50)
  ui.base_image:SetScale(ui.base_image:GetWidth() / w, ui.base_image:GetHeight() / h)
  ui.base_image:SetPos(0, 0)

  local image_delta_x = gun.base_image:getWidth() - gun.image:getWidth()
  local image_delta_y = gun.base_image:getWidth() - gun.image:getHeight()

  ui.gun_image = loveframes.Create("image", ui.image_frame)
  ui.gun_image:SetImage(gun.image)
  ui.gun_image:SetSize(50, 50)
  local image_scale_x, image_scale_y = ui.gun_image:GetWidth() / w, ui.gun_image:GetHeight() / h
  ui.gun_image:SetScale(image_scale_x, image_scale_y)
  ui.gun_image:SetPos(image_delta_x * image_scale_x / 2, image_delta_y * image_scale_y / 2)

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
      self:flash_credits_red()
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

  local button_text, level_text, damage_text, shots_text, rotation_text

  -- max level
  if level == #gun.crew_upgrades then
    self.upgrade_ui.upgrade_button:SetEnabled(false)
    button_text = "Upgrade: MAX"
  else
    button_text = "Upgrade: " .. gun:upgrade_cost() .. " credits"
  end

  level_text = {{COLORS.black:rgb()}, "Level: " .. level}
  damage_text = {{COLORS.black:rgb()}, "Damage: " .. stats.damage}
  shots_text = {{COLORS.black:rgb()}, "Shots/minute: " .. 60 / stats.firing_speed}
  rotation_text = {{COLORS.black:rgb()}, "Degrees/second: " .. math.deg(stats.rotation_speed)}

  self.upgrade_ui.upgrade_button:SetText(button_text)
  self.upgrade_ui.level_text:SetText(level_text)
  self.upgrade_ui.damage_text:SetText(damage_text)
  self.upgrade_ui.shots_text:SetText(shots_text)
  self.upgrade_ui.rotation_text:SetText(rotation_text)
end

function GameUI:flash_credits_red(time)
  time = time or 0.6

  tween.reset(self.credits_bg_tween_id)
  self.credits_bg_tween_id = tween(time / 2, self.credits_frame.background_color, {COLORS.red:rgb()}, "linear", function()
    tween(time / 2, self.credits_frame.background_color, {COLORS.white:rgb()})
  end)
end

function GameUI:update_health_bar()
  local tower = self.game.tower
  self.tower_health_bar:SetMinMax(0, tower.max_health)
  self.tower_health_bar:SetValue(tower.health)
end

function GameUI:show_wall_ui()
  local tower = self.game.tower
  local player = self.game.player

  local wall_frame = loveframes.Create("frame")
  wall_frame:SetSize(200, 130)
  wall_frame:Center()
  wall_frame:SetName("Walls")
  wall_frame:SetScreenLocked(true)
  wall_frame.OnMouseEnter = on_mouse_enter
  wall_frame.OnClose = on_mouse_exit

  local x_offset = 10
  local upgrade_amount = 10

  -- button declarations
  local repair_button = loveframes.Create("button", wall_frame)
  local repair_all_button = loveframes.Create("button", wall_frame)
  local upgrade_health_button = loveframes.Create("button", wall_frame)

  -- update function closes over the buttons
  local function update_wall_ui()
    repair_button:SetText("Repair 10 Health for 100 Credits")
    repair_button:SetEnabled(player.resources >= 100 and tower.health <= tower.max_health - 10)

    local health_delta = tower.max_health - tower.health
    local cost = health_delta * 10
    repair_all_button:SetText("Repair All Health for " .. cost .. " Credits")
    repair_all_button:SetEnabled(player.resources >= cost and tower.health <= tower.max_health - 1)

    cost = upgrade_amount * 100
    upgrade_health_button:SetText("Add " .. upgrade_amount .. " Health for " .. cost .. " Credits")
    upgrade_health_button:SetEnabled(player.resources >= cost)
  end

  -- set up all the other crap
  repair_button:SetWidth(wall_frame:GetWidth() - x_offset * 2)
  repair_button:SetPos(x_offset, 30)
  function repair_button.OnClick()
    tower:repair_for(10)
    player:charge(10 * 10)
    self:update_credits_text()
    update_wall_ui()
  end

  repair_all_button:SetWidth(wall_frame:GetWidth() - x_offset * 2)
  repair_all_button:SetPos(x_offset, repair_button:GetStaticY() + repair_button:GetHeight() + 10)
  function repair_all_button.OnClick()
    local health_delta = tower.max_health - tower.health
    tower:repair_for(health_delta)
    player:charge(health_delta * 10)
    self:update_credits_text()
    update_wall_ui()
  end

  upgrade_health_button:SetWidth(wall_frame:GetWidth() - x_offset * 2)
  upgrade_health_button:SetPos(x_offset, repair_all_button:GetStaticY() + repair_all_button:GetHeight() + 10)
  function upgrade_health_button.OnClick()
    tower.max_health = tower.max_health + upgrade_amount
    tower:repair_for(upgrade_amount)
    player:charge(upgrade_amount * 100)
    self:update_credits_text()
    update_wall_ui()
  end

  -- initial update
  update_wall_ui()
end

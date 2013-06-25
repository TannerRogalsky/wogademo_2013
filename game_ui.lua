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
  function self.collect_resources_button:OnClick()
    local entities = game.selected_entities

    for _,entity in pairs(entities) do
      if next(Resources.instances) == nil then
        break
      end

      local x, y = entity:world_center()
      local _, closest = next(Resources.instances)
      local distances = {closest = math.huge}

      for _,resource in pairs(Resources.instances) do
        local resource_x, resource_y = resource:world_center()
        local distance = math.sqrt(math.pow(resource_x - x, 2) + math.pow(resource_y - y, 2))
        distances[resource] = distance

        if distance < distances[closest] then
          closest = resource
        end
      end

      if closest then
        local path = game.map:find_path(entity.x, entity.y, closest.x, closest.y)
        entity:follow_path(path, nil, function()
          print("wooo")
        end)
      end
    end

    game:clear_selected_entities()
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
    self.game.ui_active = false
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

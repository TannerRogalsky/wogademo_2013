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

  self.game.ui_active = true
  local x, y, w, h = gun:world_bounds()

  local upgrade_frame = loveframes.Create("frame")
  upgrade_frame:SetSize(200, 200)
  upgrade_frame:Center()
  upgrade_frame:SetName("Upgrade")
  upgrade_frame:SetScreenLocked(true)
  function upgrade_frame.OnClose(object)
    self.game.ui_active = false
  end

  local base_image = loveframes.Create("image", upgrade_frame)
  base_image:SetImage(gun.base_image)
  base_image:SetSize(50, 50)
  base_image:SetPos(upgrade_frame:GetWidth() - base_image:GetWidth() - 10, 30)
  base_image:SetScale(base_image:GetWidth() / w, base_image:GetHeight() / h)

  local gun_image = loveframes.Create("image", upgrade_frame)
  gun_image:SetImage(gun.image)
  gun_image:SetSize(50, 50)
  gun_image:SetPos(upgrade_frame:GetWidth() - gun_image:GetWidth() - 10, 30)
  gun_image:SetScale(gun_image:GetWidth() / w, gun_image:GetHeight() / h)

  local padding_x, padding_y = 5, 30

  local upgrade_button = loveframes.Create("button", upgrade_frame)
  upgrade_button:SetSize(125, 25)
  upgrade_button:SetText("Upgrade: " .. gun:upgrade_cost() .. " credits")
  upgrade_button:SetPos(padding_x, padding_y)
  function upgrade_button:OnClick()
    gun:upgrade()
  end

  local level_text = loveframes.Create("text", upgrade_frame)
  level_text:SetText({{COLORS.black:rgb()}, "Level: " .. gun.max_crew})
  level_text:SetPos(padding_x, upgrade_button:GetStaticY() + upgrade_button:GetHeight() + 10)
  level_text:SetFont(upgrade_font)

  local damage_text = loveframes.Create("text", upgrade_frame)
  damage_text:SetText({{COLORS.black:rgb()}, "Damage: " .. gun.damage})
  damage_text:SetPos(padding_x, level_text:GetStaticY() + padding_y)
  damage_text:SetFont(upgrade_font)

  local shots_text = loveframes.Create("text", upgrade_frame)
  shots_text:SetText({{COLORS.black:rgb()}, "Shots/minute: " .. 60 / gun.firing_speed})
  shots_text:SetPos(padding_x, damage_text:GetStaticY() + padding_y)
  shots_text:SetFont(upgrade_font)

  local rotation_text = loveframes.Create("text", upgrade_frame)
  rotation_text:SetText({{COLORS.black:rgb()}, "Degrees/second: " .. math.deg(gun.rotation_speed)})
  rotation_text:SetPos(padding_x, shots_text:GetStaticY() + padding_y)
  rotation_text:SetFont(upgrade_font)
end

function GameUI:update_credits_text()
  self.credits_text:SetText({{COLORS.blue:rgb()}, game.player.resources .. " Credits"})
end

function GameUI:update_crew_text()
  self.crew_text:SetText({{COLORS.green:rgb()}, game.player.crew .. " Crew"})
end

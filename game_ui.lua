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
  self.credits_text:SetText({{COLORS.blue:rgb()}, "800 Credits"})
  self.credits_text:SetPos(20, 20)
  self.credits_text:CenterY()
  self.credits_text:SetFont(self.ui_font)


  -- crew box
  self.crew_frame = loveframes.Create("frame")
  self.crew_frame:SetSize(200, 40)
  self.crew_frame:SetPos(g.getWidth() - self.crew_frame:GetWidth() - 20, 10 + self.credits_frame:GetHeight() + 10)
  self.crew_frame:SetDraggable(false)
  self.crew_frame:ShowCloseButton(false)
  self.crew_frame.draw = draw_rect_and_children

  self.crew_text = loveframes.Create("text")
  self.crew_text:SetParent(self.crew_frame)
  self.crew_text:SetText({{COLORS.green:rgb()}, "9 Crew"})
  self.crew_text:SetPos(20, 20)
  self.crew_text:CenterY()
  self.crew_text:SetFont(self.ui_font)

  -- tower health bar
  self.tower_health_bar = loveframes.Create("progressbar")
  self.tower_health_bar:SetSize(g.getWidth() - 20 * 2, 25)
  self.tower_health_bar:SetPos(20, g.getHeight() - self.tower_health_bar:GetHeight() - 10)
  self.tower_health_bar:SetMinMax(0, 100)
  self.tower_health_bar:SetValue(100)
  self.tower_health_bar:SetLerp(true)
end

function GameUI:show_upgrade_ui(gun)
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
  base_image:SetPos(upgrade_frame:GetWidth() - base_image:GetWidth() - 20, 20)
  base_image:SetScale(base_image:GetWidth() / w, base_image:GetHeight() / h)

  local gun_image = loveframes.Create("image", upgrade_frame)
  gun_image:SetImage(gun.image)
  gun_image:SetSize(50, 50)
  gun_image:SetPos(upgrade_frame:GetWidth() - gun_image:GetWidth() - 20, 20)
  gun_image:SetScale(gun_image:GetWidth() / w, gun_image:GetHeight() / h)

  local upgrade_button = loveframes.Create("button", upgrade_frame)
  upgrade_button:SetText("Upgrade")
  upgrade_button:SetPos(50, 50)
  function upgrade_button:OnClick()
    gun:upgrade()
  end
end

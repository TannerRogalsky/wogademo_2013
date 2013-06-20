GameUI = class('GameUI', Base)

function GameUI:initialize(game)
  Base.initialize(self)

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
  self.crew_text:CenterY()
  self.crew_text:SetFont(self.ui_font)

  -- tower health bar
  self.tower_health_bar = loveframes.Create("progressbar")
  self.tower_health_bar:SetSize(g.getWidth() - 20 * 2, 25)
  self.tower_health_bar:SetPos(20, g.getHeight() - self.tower_health_bar:GetHeight() - 10)
  self.tower_health_bar:SetMinMax(0, 100)
  self.tower_health_bar:SetValue(65)
  self.tower_health_bar:SetLerp(true)
end

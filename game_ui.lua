GameUI = class('GameUI', Base)

function GameUI:initialize(game)
  Base.initialize(self)

  self.top_frame = loveframes.Create("frame")
  self.top_frame:SetSize(g.getWidth(), 50)
  self.top_frame:SetDraggable(false)
  self.top_frame:ShowCloseButton(false)
  function self.top_frame:draw()
    g.setColor(COLORS.white:rgb())
    g.rectangle("fill", self:GetX(), self:GetY(), self:GetWidth(), self:GetHeight())

    for _, child in ipairs(self.children) do
      child:draw()
    end
  end

  self.button = loveframes.Create("button")
  self.button:SetParent(self.top_frame)

end

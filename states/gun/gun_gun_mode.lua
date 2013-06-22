local GunMode = Gun:addState('GunMode')

function GunMode:enteredState()
end

function GunMode:on_graphics_scale(x, y, dx, dy)
  if x < 1 then
    tween.stop(self.alpha_tween_id)
    self.alpha_tween_id = tween(0.3, self.color, {a = 0}, "linear", function()
      self:gotoState("BaseMode")
    end)
  end
end

function GunMode:left_mouse_down(x, y)
  GameUI.instance:show_upgrade_ui(self)
end

function Gun:render()
  local x, y = self:world_center()
  local c = self.color
  g.setColor(c.r, c.g, c.b, c.a)

  g.draw(self.base_image, self.world_x, self.world_y)

  -- draws from the center
  g.draw(self.image, x, y, self.angle - math.pi / 2, 1, 1, self.width * self.parent.tile_width / 2, self.height * self.parent.tile_height / 2)
end

function GunMode:exitedState()
end

return GunMode

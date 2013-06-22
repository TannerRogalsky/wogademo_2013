local GunMode = Gun:addState('GunMode')

function GunMode:enteredState()
end

function GunMode:on_graphics_scale(x, y, dx, dy)
  tween.stop(self.alpha_tween_id)
  if x < 1 then
    self.alpha_tween_id = tween(0.3, self.color, {a = 0})
    self:gotoState("BaseMode")
  end
end

function GunMode:left_mouse_down(x, y)
  GameUI.instance:show_upgrade_ui(self)
end

function GunMode:exitedState()
end

return GunMode

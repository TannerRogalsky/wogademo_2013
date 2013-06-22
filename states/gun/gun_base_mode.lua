local BaseMode = Gun:addState('BaseMode')

function BaseMode:enteredState()
end

function BaseMode:on_graphics_scale(x, y, dx, dy)
  if x > 1 then
    tween.stop(self.alpha_tween_id)
    self.alpha_tween_id = tween(0.3, self.color, {a = 255})
    self:gotoState("GunMode")
  end
end

function BaseMode:exitedState()
end

return BaseMode

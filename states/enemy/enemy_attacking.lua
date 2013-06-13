local Attacking = Enemy:addState('Attacking')

function Attacking:enteredState()
  self.attacking_cron_id = cron.every(1, print, tostring(self) .. " attacked")
end

function Attacking:exitedState()
end

return Attacking

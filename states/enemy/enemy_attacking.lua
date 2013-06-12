local Attacking = Enemy:addState('Attacking')

function Attacking:enteredState()
  cron.every(1, print, tostring(self) .. " attacked")
end

function Attacking:exitedState()
  print("exited Attacking")
end

return Attacking

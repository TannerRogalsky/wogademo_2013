local Attacking = Enemy:addState('Attacking')

function Attacking:enteredState()
  self.attacking_cron_id = cron.every(1, self.attack, self)
end

function Attacking:attack()
  assert(Enemy.instances[self.id], "Wrah! Polly shouldn't be! Wrah!")
  print(self .. " attacked")
end

function Attacking:exitedState()
end

return Attacking

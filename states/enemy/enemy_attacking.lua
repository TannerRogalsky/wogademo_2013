local Attacking = Enemy:addState('Attacking')

function Attacking:enteredState()
  self.speed = 0
  self.attacking_cron_id = cron.every(self.attack_speed, self.attack, self)
end

function Attacking:attack()
  assert(Enemy.instances[self.id], "Wrah! Polly shouldn't be! Wrah!")
  self.target.tower:damage_for(self.damage)
end

function Attacking:exitedState()
end

return Attacking

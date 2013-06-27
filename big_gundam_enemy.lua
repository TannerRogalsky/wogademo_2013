BigGundamEnemy = class('BigGundamEnemy', Enemy)

BigGundamEnemy.static.width = 3
BigGundamEnemy.static.height = 3

function BigGundamEnemy:initialize(parent, x, y)
  Enemy.initialize(self, parent, x, y, BigGundamEnemy.width, BigGundamEnemy.height)

  self.speed = 25
  self.health = 10

  self.image = game.preloaded_image["enemy_large.png"]
end

BigGundamEnemy.__lt = MapEntity.__lt
BigGundamEnemy.__le = MapEntity.__le

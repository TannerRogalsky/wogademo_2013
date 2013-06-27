SmallSawEnemy = class('SmallSawEnemy', Enemy)

SmallSawEnemy.static.width = 1
SmallSawEnemy.static.height = 1

function SmallSawEnemy:initialize(parent, x, y)
  Enemy.initialize(self, parent, x, y, SmallSawEnemy.width, SmallSawEnemy.height)

  self.speed = 50

  self.image = game.preloaded_image["enemy_small.png"]
end

-- function SmallSawEnemy:render()
--   g.setColor(COLORS.yellow:rgb())
--   g.rectangle("fill", self.world_x, self.world_y, self.width * self.parent.tile_width, self.height * self.parent.tile_height)
-- end

SmallSawEnemy.__lt = MapEntity.__lt
SmallSawEnemy.__le = MapEntity.__le

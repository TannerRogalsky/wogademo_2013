SmallSawEnemy = class('SmallSawEnemy', Enemy)
SmallSawEnemy:include(Movable)
SmallSawEnemy:include(FollowsPath)

function SmallSawEnemy:initialize(parent, x, y)
  Enemy.initialize(self, parent, x, y, 1, 1)

  self.speed = 50
end

function SmallSawEnemy:render()
  g.setColor(COLORS.yellow:rgb())
  g.rectangle("fill", self.world_x, self.world_y, self.width * self.parent.tile_width, self.height * self.parent.tile_height)
end

SmallSawEnemy.__lt = MapEntity.__lt
SmallSawEnemy.__le = MapEntity.__le

Resource = class('Resource', MapEntity)
Resource.static.instances = {}

function Resource:initialize(parent, x, y)
  MapEntity.initialize(self, parent, x, y, 1, 1)

  local small_crystal = game.preloaded_image["crystal_small.png"]
  local big_crystal = game.preloaded_image["crystal.png"]

  self.canvas = g.newCanvas(self.width * self.parent.tile_width, self.height * self.parent.tile_height)
  g.setCanvas(self.canvas)
  g.setColor(COLORS.white:rgb())
  for i=0,10,5 do
    g.draw(small_crystal, i, math.random(3))
  end
  g.setCanvas(nil)

  self.worth = 10
  Resource.instances[self.id] = self
end

function Resource:destroy()
  self.parent:remove_entity(self)
  Resource.instances[self.id] = nil
end

function Resource:render()
  g.setColor(COLORS.white:rgb())
  g.draw(self.canvas, self.world_x, self.world_y)
end

Resource.__lt = MapEntity.__lt
Resource.__le = MapEntity.__le

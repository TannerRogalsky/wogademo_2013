Crew = class('Crew', MapEntity)
MapEntity:include(Movable)
MapEntity:include(FollowsPath)

function Crew:initialize(parent, x, y)
  MapEntity.initialize(self, parent, x, y, 1, 1)

  self.z = 150
  self.color = COLORS.blue
  self.selected = false

  self.physics_body = Collider:addRectangle(self:world_bounds())
  self.physics_body.parent = self
  Collider:addToGroup("friendly", self.physics_body)
end

function Crew:at_path_target()
  local tile = self.parent.grid:g(self.x, self.y)
  local room = tile:get_first_content_of_type(TowerRoom)

  room:add_crew(self)
end

function Crew:update(dt)
end

function Crew:render()
  g.setColor(self.color:rgb())
  g.rectangle("fill", self.world_x, self.world_y, self.width * self.parent.tile_width, self.height * self.parent.tile_height)

  if self.selected then
    g.setColor(COLORS.red:rgb())
    g.rectangle("line", self.world_x, self.world_y, self.width * self.parent.tile_width, self.height * self.parent.tile_height)
  end
end

Crew.__lt = MapEntity.__lt
Crew.__le = MapEntity.__le

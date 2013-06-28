Crew = class('Crew', MapEntity)
Crew.static.targeted_resources = {}
MapEntity:include(Movable)
MapEntity:include(FollowsPath)

function Crew:initialize(parent, x, y)
  MapEntity.initialize(self, parent, x, y, 1, 1)

  self.angle = 0

  self.z = 150
  self.color = COLORS.blue
  self.selected = false

  self.image = game.preloaded_image["crew_stand.png"]
  self.selected_image = game.preloaded_image["crew_stand_selected.png"]

  self.physics_body = Collider:addRectangle(self:world_bounds())
  self.physics_body.parent = self
  Collider:addToGroup("friendly", self.physics_body)
end

function Crew:at_path_target()
  local tile = self.parent.grid:g(self.x, self.y)
  local room = tile:get_first_content_of_type(TowerRoom)

  room:add_crew(self)
  self:set_standing_angle(room, tile)
end

function Crew:set_standing_angle(room, tile)
  self.angle = room.standing_angles[tile] - math.pi / 2
end

function Crew:render()
  g.setColor(COLORS.white:rgb())
  local _, _, w, h = self:world_bounds()
  local x, y = self:world_center()

  local image = nil
  if self.selected then
    image = self.selected_image
  else
    image = self.image
  end

  local scale = 0.5
  g.draw(image, x, y, self.angle - math.pi / 2, scale, scale, w * scale * 2, h * scale * 2)
end

Crew.__lt = MapEntity.__lt
Crew.__le = MapEntity.__le

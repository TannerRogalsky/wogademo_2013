Player = class('Player', Base)

function Player:initialize(game)
  Base.initialize(self)

  self.resources = 1000
  self.crew = 0
end

function Player:collect(resource)
  assert(instanceOf(Resource, resource))
  self.resources = self.resources + resource.worth
  GameUI.instance:update_credits_text()
end

function Player:charge(value)
  assert(is_num(value))
  self.resources = self.resources - value
end

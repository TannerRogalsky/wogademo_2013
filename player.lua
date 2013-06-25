Player = class('Player', Base)

function Player:initialize(game)
  Base.initialize(self)

  self.resources = 1000
  self.crew = 0
end

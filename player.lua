Player = class('Player', Base)

function Player:initialize(game)
  Base.initialize(self)

  self.resources = 0
  self.crew = 0
end

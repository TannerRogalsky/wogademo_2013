Gate = class('Gate', MapEntity)

function Gate:initialize(parent, x, y)
  MapEntity.initialize(self, parent, x, y, 1, 1)

  self.cost_to_move_to = 0
end

Gate.__lt = MapEntity.__lt
Gate.__le = MapEntity.__le

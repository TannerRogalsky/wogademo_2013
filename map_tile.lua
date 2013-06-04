MapTile = class('MapTile', Base)

function MapTile:initialize(parent, x, y)
  Base.initialize(self)
  self.parent = parent
  self.x = x
  self.y = y

  self.color = COLORS.green
  self.content = {}
  self.siblings = {}
end

function MapTile:update(dt)
end

function MapTile:render()
end

function MapTile:cost_to_move_to()
  local cost = 0
  for _,content in pairs(self.content) do
    if is_func(content.cost_to_move_to) then
      cost = cost + content:cost_to_move_to()
    elseif is_num(content.cost_to_move_to) then
      cost = cost + content.cost_to_move_to
    end
  end
  return cost
end

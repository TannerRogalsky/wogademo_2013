LOD = class('LOD')
LOD.static.delegates = {}

function LOD.static.on_graphics_scale(x, y, dx, dy)
  for _,delegate in pairs(LOD.delegates) do
    delegate:on_graphics_scale(x, y, dx, dy)
  end
end

function LOD.static.on_graphics_translate(x, y, dx, dy)
  for _,delegate in pairs(LOD.delegates) do
    delegate:on_graphics_translate(x, y, dx, dy)
  end
end

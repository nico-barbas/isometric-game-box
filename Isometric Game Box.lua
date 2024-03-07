local palette = {
  stroke = Color { r = 0, g = 0, b = 0, a = 255 },
  top = Color { r = 255, g = 0, b = 0, a = 255 },
  left = Color { r = 0, g = 255, b = 0, a = 255 },
  right = Color { r = 0, g = 0, b = 255, a = 255 },
}

local cfg = {
  fill = false
}

---@param startx number
---@param starty number
---@param dirx number
---@param diry number
---@param len number
local function draw_iso_line(startx, starty, dirx, diry, len, color)
  for i = 0, (len - 1) do
    local x = i * 2 * dirx
    local y = i * diry
    app.activeImage:putPixel(startx + x, starty + y, color)
    app.activeImage:putPixel(startx + x + dirx, starty + y, color)
  end
end

---@param x number
---@param y1 number
---@param y2 number
local function draw_v_line(x, y1, y2, color)
  for y = 0, y2 - y1 do
    app.activeImage:putPixel(x, y1 + y, color)
  end
end

---@param x number
---@param y number
---@param height number
local function draw_cube_line(x, y, height, color_stroke)
  local startx = x * 2
  local starty = x + y - 1

  draw_iso_line(startx, starty, 1, -1, y, color_stroke)
  draw_iso_line(startx - 1, starty, -1, -1, x, color_stroke)
  draw_iso_line(y * 2, 0, 1, 1, x, color_stroke)
  draw_iso_line(y * 2 - 1, 0, -1, 1, y, color_stroke)

  draw_iso_line(startx, starty + height, 1, -1, y, color_stroke)
  draw_iso_line(startx - 1, starty + height, -1, -1, x, color_stroke)

  local vrstartx = x * 2 + y * 2 - 1
  local vlstarty = y + 1
  local vrstarty = math.max(x, y) + 1
  draw_v_line(0, vlstarty, vlstarty + height - 2, color_stroke)
  draw_v_line(vrstartx, vrstarty, vrstarty + height - 2, color_stroke)
end

---@param x number
---@param y number
---@param height number
local function draw_cube_fill(x, y, height, color_top, color_left, color_right)
  local startx = x * 2
  local starty = x + y

  for i = 0, height - 1 do
    draw_iso_line(startx, starty + i, 1, -1, y, color_right)
  end

  for i = 0, height - 1 do
    draw_iso_line(startx - 1, starty + i, -1, -1, x, color_left)
  end

  for i = 0, x do
    if i > 0 then
      local currx = (i - 1) * 2
      draw_iso_line(currx, y + i - 1, 1, -1, y + 1, color_top)
    end
    draw_iso_line(i * 2, y + i - 1, 1, -1, y, color_top)
  end
end

local function new_layer(name)
  local sprite = app.activeSprite
  local layer = sprite:newLayer()
  layer.name = name
  sprite:newCel(layer, 1)

  return layer
end

local dialog = Dialog("Isometric Game Box")
dialog:separator { text = "Size (one unit is 4px): " }
    :slider { id = "left", label = "Left: ", min = 1, max = 16, value = 2 }
    :slider { id = "right", label = "Right: ", min = 1, max = 16, value = 2 }
    :slider { id = "height", label = "Height: ", min = 1, max = 10, value = 1 }

    :separator { text = "Colors:" }
    :color { id = "color_stroke", label = "Stroke:", color = palette.stroke }
    :color { id = "color_top", label = "Top:", color = palette.top }
    :color { id = "color_left", label = "Left:", color = palette.left }
    :color { id = "color_right", label = "Right:", color = palette.right }

    :separator("Type: ")
    :radio { id = "type_line", text = "line", selected = not cfg.fill }
    :radio { id = "type_fill", text = "fill", selected = cfg.fill }

    :separator()
    :button {
      id = "ok",
      text = "Add box",
      onclick = function()
        local data = dialog.data
        app.transaction(function()
          new_layer("Cube")

          if data.type_line then
            draw_cube_line(
              data.left * 2,
              data.right * 2,
              data.height * 8,
              data.color_stroke
            )
          else
            draw_cube_fill(
              data.left * 2,
              data.right * 2,
              data.height * 8,
              data.color_top,
              data.color_left,
              data.color_right
            )
          end
        end)

        app.command.Undo()
        app.command.Redo()
      end
    }
    :show { wait = false }

-- Filename: bounce.lua.
-- Coded by: arkenidar.
-- Original Repo: lua-love2d-bounce.
-- Original source: main.lua.
-- Uses: LOVE 2D.
-- Adapted for: https://github.com/arkenidar/luajit-sdl.
-- Copied from: https://github.com/arkenidar/lua-love2d-bounce/blob/main/main.lua.

-- global variables : ffi, sdl, renderer, love

-- Local Lua Debugger for Visual Studio Code
-- https://marketplace.visualstudio.com/items?itemName=tomblind.local-lua-debugger-vscode
if love and os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

if not love then
    love = {} -- fake love table
end

-- Bounce
-- https://love2d.org/

local field

local function object_update(dt, object)
    -- move object
    object.x = object.x + dt * object.vx
    object.y = object.y + dt * object.vy

    -- bounce object
    local min_x, min_y, max_x, max_y = field.x, field.y, (field.size.x + field.x) - object.size.x,
        (field.size.y + field.y) - object.size.y

    if object.x <= min_x then object.vx = -object.vx end
    if object.y <= min_y then object.vy = -object.vy end
    if object.x >= max_x then object.vx = -object.vx end
    if object.y >= max_y then object.vy = -object.vy end
end

---@diagnostic disable-next-line: unused-function
local function rectangle_draw(object)
    if love and love.graphics then
        love.graphics.setColor(object.color[1], object.color[2], object.color[3])
        love.graphics.rectangle("fill", object.x, object.y, object.size.x, object.size.y)
        return
    end

    -- Set draw color and draw a filled rectangle
    sdl.SDL_SetRenderDrawColor(renderer, object.color[1] * 255, object.color[2] * 255, object.color[3] * 255, 255)
    local rectangle = ffi.new("SDL_Rect", { x = object.x, y = object.y, w = object.size.x, h = object.size.y })
    sdl.SDL_RenderFillRect(renderer, rectangle)
end

local objects

-- https://www.love2d.org/wiki/Tutorial:Callback_Functions
-- https://www.love2d.org/wiki/love.update
function love.update(dt)
    for _, object in ipairs(objects) do
        object_update(dt, object)
    end
end

-- https://www.love2d.org/wiki/Tutorial:Callback_Functions
-- https://www.love2d.org/wiki/love.draw
function love.draw()
    for _, object in ipairs(objects) do
        object.object_draw(object)
    end
end

-- https://www.love2d.org/wiki/Tutorial:Callback_Functions
-- https://www.love2d.org/wiki/love.load
function love.load()
    love.window.setTitle("Hello, Bounce!")
end

-- https://www.love2d.org/wiki/love.keypressed
function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    end
end

field = { x = 10, y = 10, vx = 0, vy = 0, size = { x = 100, y = 90 }, color = { 1, 1, 0 }, object_draw = rectangle_draw }

objects =
{
    field, -- first object is the field, in this case a rectangle,
    -- that will contain the other objects. it will not move.
    -- it's a background so it's the first in drawing order.

    -- other objects, that will bounce inside the field.
    { x = 10, y = 10, vx = 10, vy = 20, size = { x = 80, y = 40 }, color = { 1, 0, 0 }, object_draw = rectangle_draw },
    { x = 50, y = 30, vx = 15, vy = 10, size = { x = 10, y = 10 }, color = { 1, 0, 1 }, object_draw = rectangle_draw },
    { x = 10, y = 30, vx = 55, vy = 50, size = { x = 10, y = 10 }, color = { 1, 1, 1 }, object_draw = rectangle_draw },
}

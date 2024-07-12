-- global variables : ffi, sdl, renderer

-- global variable : ffi
ffi = require("ffi")
-- global variable : sdl
sdl = ffi.load("SDL2")

-- LuaJIT 2D Game Development
-- https://chatgpt.com/share/470cd945-7e27-42bd-8aff-e6ab84b2ead4

--[[
ffi.cdef[[

typedef struct SDL_Window SDL_Window;
typedef struct SDL_Renderer SDL_Renderer;
typedef struct SDL_Rect { int x, y, w, h; } SDL_Rect;

int SDL_Init(uint32_t flags);
void SDL_Quit(void);

SDL_Window* SDL_CreateWindow(const char* title, int x, int y, int w, int h, uint32_t flags);
void SDL_DestroyWindow(SDL_Window* window);

SDL_Renderer* SDL_CreateRenderer(SDL_Window* window, int index, uint32_t flags);
void SDL_DestroyRenderer(SDL_Renderer* renderer);

int SDL_PollEvent(SDL_Event * event);

void SDL_RenderClear(SDL_Renderer* renderer);
void SDL_RenderPresent(SDL_Renderer* renderer);
void SDL_SetRenderDrawColor(SDL_Renderer* renderer, uint8_t r, uint8_t g, uint8_t b, uint8_t a);
void SDL_RenderFillRect(SDL_Renderer* renderer, const SDL_Rect* rect);

]]

print("init sdl cdef ...")
ffi.cdef(require("cdefs-sdl"))

-- Constants
local SDL_INIT_VIDEO = 0x00000020
local SDL_WINDOW_SHOWN = 0x00000004
local SDL_RENDERER_ACCELERATED = 0x00000002
--- local SDL_QUIT = 0x100

-- Initialize SDL
if sdl.SDL_Init(SDL_INIT_VIDEO) ~= 0 then
    error("SDL_Init failed")
end
print("sdl init done")

-- Create an SDL window
local window = sdl.SDL_CreateWindow("LuaJIT SDL2 Draw Rectangle", 100, 100, 800, 600, SDL_WINDOW_SHOWN)
if window == nil then
    error("SDL_CreateWindow failed")
end
print("window init done")

-- Create a renderer
-- global variable : renderer
renderer = sdl.SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED)
if renderer == nil then
    error("SDL_CreateRenderer failed")
end

-- Global variables

-- Optional require to merge "bounce.lua" with this file ( filename : "app.lua" ) .
--- require("bounce")

-- Create a rectangle
-- rect3 is global in order to keep state across drawing frames
local rect3 = ffi.new("SDL_Rect", { x = 100 - 40 + 50, y = 100 - 20 + 50, w = 200, h = 100 })

-- Main loop
local running = true
print("main loop started")

local mouse = { x = -1, y = -1, button = false, button_before = false, button_clicked = false }

local time_ticks = sdl.SDL_GetTicks()

while running do
    -- Poll events
    local event = ffi.new("SDL_Event")

    -- before loop of SDL_PollEvent
    mouse.button_before = mouse.button

    while sdl.SDL_PollEvent(event) ~= 0 do
        -- Get mouse position
        if event.type == sdl.SDL_MOUSEMOTION then
            mouse.x = event.motion.x
            mouse.y = event.motion.y
        end
        -- Handle mouse button
        if event.type == sdl.SDL_MOUSEBUTTONDOWN then
            mouse.button = true
        end
        if event.type == sdl.SDL_MOUSEBUTTONUP then
            mouse.button = false
        end
        -- Check for quit event
        if event.type == sdl.SDL_QUIT or
            event.type == sdl.SDL_KEYDOWN and event.key.keysym.sym == sdl.SDLK_ESCAPE
        then -- SDL_QUIT
            running = false
            print("quit received ...")
        end
    end

    -- after loop of SDL_PollEvent
    mouse.button_clicked = mouse.button and not mouse.button_before

    local dt -- elapsed time in fractions of seconds
    delta_ticks = sdl.SDL_GetTicks() - time_ticks
    time_ticks = sdl.SDL_GetTicks()
    dt = delta_ticks / 1000 -- milliseconds to seconds

    if love and love.update then love.update(dt) end

    -- Clear the screen
    sdl.SDL_SetRenderDrawColor(renderer, 50, 50, 50, 255)
    sdl.SDL_RenderClear(renderer)

    if love and love.draw then love.draw() end

    -- Demonstrating "mouse.y" and "mouse.y"
    -- Set draw color and draw a filled rectangle
    sdl.SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255)
    local rect1 = ffi.new("SDL_Rect", { x = mouse.x, y = mouse.y, w = 200, h = 100 })
    sdl.SDL_RenderFillRect(renderer, rect1)

    -- Demonstrating "mouse.button"
    -- Set draw color and draw a filled rectangle
    sdl.SDL_SetRenderDrawColor(renderer, 255, 0, 255, 255)
    local rect2 = ffi.new("SDL_Rect", { x = 100 - 40, y = 100 - 20, w = 200, h = 100 })
    if mouse.button then rect2.y = rect2.y + 150 end
    sdl.SDL_RenderFillRect(renderer, rect2)

    -- Demonstrating "mouse.button_clicked"
    -- Set draw color and draw a filled rectangle
    sdl.SDL_SetRenderDrawColor(renderer, 255, 255, 100, 255)
    -- rect3 is global in order to keep state across drawing frames
    if mouse.button_clicked then rect3.y = rect3.y + 15 end
    sdl.SDL_RenderFillRect(renderer, rect3)

    -- Present the renderer
    sdl.SDL_RenderPresent(renderer)
end

-- Cleanup
sdl.SDL_DestroyRenderer(renderer)
sdl.SDL_DestroyWindow(window)
sdl.SDL_Quit()

-- include library for virtual resolution
push = require 'push'

-- include library for classes
Class = require 'class'

-- include our own Bird class
require 'Bird'

-- physical dimensions
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- virtual dimensions
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

-- load background and set scroll start location
local background = love.graphics.newImage('background.png')
local backgroundScroll = 0

-- load ground and set scroll location
local ground = love.graphics.newImage('ground.png')
local groundScroll = 0

-- speed at which we scroll our images
local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

-- looping point for background
local BACKGROUND_LOOPING_POINT = 413

-- create our bird
local bird = Bird()

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')

  love.window.setTitle('Fifty Bird')

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    fullscreen = false,
    resizable = true
  })
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
end

function love.update(dt)
  backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
  groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH
end

function love.draw()
  push:start()

  -- draw background image at top left (0, 0)
  love.graphics.draw(background, -backgroundScroll, 0)

  -- draw the ground on top of the background 16 pixels from the bottom
  love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

  -- draw bird to the screen
  bird:render()

  push:finish()
end

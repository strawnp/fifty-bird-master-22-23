-- include library for virtual resolution
push = require 'push'

-- include library for classes
Class = require 'class'

-- include our own Bird and Pipe class
require 'Bird'
require 'Pipe'

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

-- create table of pipes
local pipes = {}

-- track spawn time of pipes
local spawnTimer = 0

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')

  love.window.setTitle('Fifty Bird')

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    fullscreen = false,
    resizable = true
  })

  love.keyboard.keysPressed = {}
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.keypressed(key)
  love.keyboard.keysPressed[key] = true

  if key == 'escape' then
    love.event.quit()
  end
end

function love.keyboard.wasPressed(key)
  if love.keyboard.keysPressed[key] then
    return true
  else
    return false
  end
end

function love.update(dt)
  backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
  groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH

  -- spwan logic for new pipe every two seconds
  spawnTimer = spawnTimer + dt

  if spawnTimer > 2 then
    table.insert(pipes, Pipe())
    print('Added new pipe!')
    spawnTimer = 0
  end

  bird:update(dt)

  -- update every pipe in our scene
  for k, pipe in pairs(pipes) do
    pipe:update(dt)

    -- if pipe no longer on screen, remove it
    if pipe.x < -pipe.width then
      table.remove(pipes, k)
    end
  end

  love.keyboard.keysPressed = {}
end

function love.draw()
  push:start()

  -- draw background image at top left (0, 0)
  love.graphics.draw(background, -backgroundScroll, 0)

  -- iterate over pipes table to draw to screen
  for k, pipe in pairs(pipes) do
    pipe:render()
  end 

  -- draw the ground on top of the background 16 pixels from the bottom
  love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

  -- draw bird to the screen
  bird:render()

  push:finish()
end

-- include library for virtual resolution
push = require 'push'

-- include library for classes
Class = require 'class'

-- include our own Bird and Pipe and PipePair class
require 'Bird'
require 'Pipe'
require 'PipePair'

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

-- looping point for ground
local GROUND_LOOPING_POINT = 514

-- create our bird
local bird = Bird()

-- create table of pipes
local pipePairs = {}

-- track spawn time of pipes
local spawnTimer = 0

-- store last recorded Y value for gap placement
local lastY = -PIPE_HEIGHT + math.random(80) + 20

-- set scrolling state
local scrolling = false

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
  elseif key == 'return' or key == 'enter' then
    scrolling = true
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
  if scrolling then
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % GROUND_LOOPING_POINT

    -- spwan logic for new pipe every two seconds
    spawnTimer = spawnTimer + dt

    if spawnTimer > 2 then
      local y = math.max(-PIPE_HEIGHT + 10,
                  math.min(lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
      lastY = y

      table.insert(pipePairs, PipePair(y))
      print('Added new pipe!')
      spawnTimer = 0
    end

    bird:update(dt)

    -- update every pipe pair in our scene
    for k, pair in pairs(pipePairs) do
      pair:update(dt)

      -- check for collisions
      for l, pipe in pairs(pair.pipes) do
        if bird: collides(pipe) then
          scrolling = false
        end
      end

      if pair.x < -PIPE_WIDTH then
        pair.remove = true
      end 
    end

  -- remove any flagged pipes
  for k, pair in pairs(pipePairs) do
    if pair.remove then
      table.remove(pipePairs, k)
    end
  end
end

  love.keyboard.keysPressed = {}
end

function love.draw()
  push:start()

  -- draw background image at top left (0, 0)
  love.graphics.draw(background, -backgroundScroll, 0)

  -- iterate over pipe pairs table to draw to screen
  for k, pair in pairs(pipePairs) do
    pair:render()
  end

  -- draw the ground on top of the background 16 pixels from the bottom
  love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

  -- draw bird to the screen
  bird:render()

  push:finish()
end

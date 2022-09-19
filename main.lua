-- include library for virtual resolution
push = require 'push'

-- include library for classes
Class = require 'class'

-- include our own Bird and Pipe and PipePair class
require 'Bird'
require 'Pipe'
require 'PipePair'

--include files for managing our state machine
require 'StateMachine'
require 'states/BaseState'
require 'states/CountdownState'
require 'states/PlayState'
require 'states/ScoreState'
require 'states/TitleScreenState'

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

-- set scrolling state
local scrolling = true

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')

  love.window.setTitle('Fifty Bird')

  smallFont = love.graphics.newFont('font.ttf', 8)
  mediumFont = love.graphics.newFont('flappy.ttf', 14)
  flappyFont = love.graphics.newFont('flappy.ttf', 28)
  hugeFont = love.graphics.newFont('flappy.ttf', 56)
  love.graphics.setFont(flappyFont)

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    fullscreen = false,
    resizable = true
  })

  gStateMachine = StateMachine {
    ['title'] = function() return TitleScreenState() end,
    ['play'] = function() return PlayState() end,
    ['score'] = function() return ScoreState() end,
    ['countdown'] = function() return CountdownState() end 
  }
  gStateMachine:change('title')

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
  -- scrolling of the background and ground
  backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
  groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % GROUND_LOOPING_POINT

  -- update based on current state of state machine
  gStateMachine:update(dt)

  -- reset input table
  love.keyboard.keysPressed = {}
end

function love.draw()
  push:start()

  -- draw background image at top left (0, 0)
  love.graphics.draw(background, -backgroundScroll, 0)

  -- render based on current state of state machine
  gStateMachine:render()

  -- draw the ground on top of the background 16 pixels from the bottom
  love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

  push:finish()
end

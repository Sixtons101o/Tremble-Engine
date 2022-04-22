fpsGraph = require "libraries/FPSGraph"
lovedebug = require "libraries/lovedebug"
local STI = require "libraries/sti"
local box2d = require "libraries/sti/plugins/box2d"


function love.load()
--welcome message
    print("Hello welcome to the Tremble Engine cmds")
--windfield shits
    wf = require ('libraries/windfield')
    world = wf.newWorld(0, 0)
--sti map
	Map = STI("maps/testMapCool.lua")
--this dumbass shitt
	-- fps graph
	testGraph = fpsGraph.createGraph()
	-- memory graph
	testGraph2 = fpsGraph.createGraph(0, 30)
	-- random graph
	testGraph3 = fpsGraph.createGraph(0, 60)

--animation shits
    anim8 = require 'libraries/anim8'
--idfk they told me to add this
	love.graphics.setDefaultFilter("nearest", "nearest")
--CAMERA :O
	camera = require "libraries/camera"
    cam = camera()
--stuff you should definitely load in. load new things in here
    player = {}
    player.collider = world:newBSGRectangleCollider(400, 250, 50, 100, 10)
    player.collider:setFixedRotation(true)
    player.x = 400
    player.y = 200
    player.speed = 300
	player.spriteSheet = love.graphics.newImage('sprites/player-sheet.png')
    player.grid = anim8.newGrid( 12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight() )
    --add animations here (pls)
    player.animations = {}
    player.animations.down = anim8.newAnimation( player.grid('1-4', 1), 0.2 )
    player.animations.left = anim8.newAnimation( player.grid('1-4', 2), 0.2 )
    player.animations.right = anim8.newAnimation( player.grid('1-4', 3), 0.2 )
    player.animations.up = anim8.newAnimation( player.grid('1-4', 4), 0.2 )
--fuck you
    player.anim = player.animations.left
--DUMBASS WALLS (just add ur tiled walls layer name, adds the objects from tiled into ur map.)
walls = {}
if Map.layers["DUMB SHIT"] then
    for i, obj in pairs(Map.layers["DUMB SHIT"].objects) do
        local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        wall:setType('static')   
        table.insert(walls, wall)
   end
end 
--literally just imported this shit from a github library for l2d
function randomUpdate(graph, dt, n)
    local val = love.math.random()*n

    fpsGraph.updateGraph(graph, val, "Random: " .. math.floor(val*10)/10, dt)
end
--here comes the fun part
function love.update(dt)
	-- update graphs using the update functions included in fpsGraph
	fpsGraph.updateFPS(testGraph, dt)
	fpsGraph.updateMem(testGraph2, dt)

	-- update this one using a custom update function
	randomUpdate(testGraph3, dt, 100)
--BULLSHIT
	local isMoving = false
--use this for speed instead of just normal x and y code
    local vx = 0
    local vy = 0
--simple movement code
    if love.keyboard.isDown("right") then
        vx = player.speed
        player.anim = player.animations.right
        isMoving = true
    end

    if love.keyboard.isDown("left") then
        vx = player.speed * -1
        player.anim = player.animations.left
        isMoving = true
    end

    if love.keyboard.isDown("down") then
       vy = player.speed
        player.anim = player.animations.down
        isMoving = true
    end

    if love.keyboard.isDown("up") then
       vy = player.speed * -1
        player.anim = player.animations.up
        isMoving = true
    end
--just so the player isnt super slow i guess
player.collider:setLinearVelocity(vx, vy) 
--pls keep it keeps the collider in the player (sounds pretty suggestive for some reason)
    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()
--lame ass animation code
    if isMoving == false then
        player.anim:gotoFrame(2)
    end

    player.anim:update(dt)
--very cool and interesting camera code
	cam:lookAt(player.x, player.y)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    -- Left border
    if cam.x < w/2 then
        cam.x = w/2
    end

    -- Right border
    if cam.y < h/2 then
        cam.y = h/2
    end

    -- Get width/height of background
    local mapW = Map.width * Map.tilewidth
    local mapH = Map.height * Map.tileheight

    -- Right border
    if cam.x > (mapW - w/2) then
        cam.x = (mapW - w/2)
    end
    -- Bottom border
    if cam.y > (mapH - h/2) then
        cam.y = (mapH - h/2)
    end
end

--boring shit
function love.draw()
cam:attach()
	-- draw the graphs
    --you have to draw layers now btw instead of 1 tile map layer
    Map:drawLayer(Map.layers["Tile Layer 1"])
    Map:drawLayer(Map.layers["walls and poop butt haha"])
    --this shit draws ur spritesheet 
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 10, nil, 6, 9)

    --world:draw()
cam:detach()
--fpsgraphs...this shits super useful
fpsGraph.drawGraphs({testGraph, testGraph2, testGraph3})
 end
end
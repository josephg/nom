canvas = document.getElementsByTagName('canvas')[0]
canvas.width = 1024
canvas.height = 768
ctx = canvas.getContext '2d'

dudespeed = 0.01

TAU = Math.PI * 2

tileSize = 50
moveDelay = 1000

# in tiles.
sx = 0
sy = 0

# map[[x,y]] = 'meat', 'flower' or null/undefined.
map = {}

meat = {x:0, y:0, dx:1, dy:0}
dude = {x:10, y:10, angle:0}

now = prev = lastMovementFrame = Date.now()

update = (dt) ->
  if now - lastMovementFrame > moveDelay
    lastMovementFrame += moveDelay

    meat.x += meat.dx
    meat.y += meat.dy

    map[[meat.x, meat.y]] = 'meat'

  dude.x += dudespeed * dt * Math.cos dude.angle
  dude.y += dudespeed * dt * Math.sin dude.angle



draw = ->
  ctx.fillStyle = 'rgb(215,232,148)'
  ctx.fillRect 0, 0, canvas.width, canvas.height
  

  ctx.fillStyle = 'red'
  ctx.fillRect (meat.x - sx) * tileSize, (meat.y - sy) * tileSize, tileSize, tileSize

  ctx.fillStyle = 'black'
  ctx.fillRect (meat.x - sx + 0.3 + meat.dx * 0.4) * tileSize,
    (meat.y - sy + 0.3 + meat.dy * 0.4) * tileSize, tileSize * 0.4, tileSize * 0.4

  ctx.fillStyle = 'blue'
  ctx.fillRect (dude.x - sx) * tileSize, (dude.y - sy) * tileSize, tileSize/2, tileSize/2

requestAnimationFrame = window.requestAnimationFrame or window.mozRequestAnimationFrame or
                        window.webkitRequestAnimationFrame or window.msRequestAnimationFrame


frame = ->
  now = Date.now()
  dt = now - prev
  prev = now

  update dt
  draw()
  requestAnimationFrame frame

frame()

keys =
  up: [38, 'W'.charCodeAt(0)]
  left: [37, 'A'.charCodeAt(0)]
  right: [39, 'D'.charCodeAt(0)]
  down: [40, 'S'.charCodeAt(0)]

document.onkeydown = (e) ->
  [meat.dx, meat.dy] = [-1, 0] if e.keyCode is 37 # left
  [meat.dx, meat.dy] = [ 1, 0] if e.keyCode is 39 # right
  [meat.dx, meat.dy] = [0, -1] if e.keyCode is 38 # up
  [meat.dx, meat.dy] = [0,  1] if e.keyCode is 40 # down


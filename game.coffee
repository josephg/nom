canvas = document.getElementsByTagName('canvas')[0]
canvas.width = 1024
canvas.height = 768
ctx = canvas.getContext '2d'

dudespeed = 0.01

TAU = Math.PI * 2

tileSize = 50
moveDelay = 500

# in tiles.
sx = 0
sy = 0

sw = Math.ceil canvas.width / tileSize
sh = Math.ceil canvas.height / tileSize

# map[[x,y]] = 'meat', 'grass' or null/undefined.
map = {}

meat = {x:0, y:0, dx:1, dy:0, ammo:5}
dude = {x:10, y:10, angle:0, ammo:2}

map[[meat.x, meat.y]] = 'meat'


map[[10, 0]] = 'meatspawn'


for x in [6..8]
  for y in [6..8]
    map[[x,y]] = 'grass'

flowers = []

now = prev = lastMovementFrame = Date.now()

update = (dt) ->
  if now - lastMovementFrame > moveDelay
    lastMovementFrame += moveDelay

    newx = meat.x + meat.dx
    newy = meat.y + meat.dy

    if 0 <= meat.x + meat.dx < sw and
      0 <= meat.y + meat.dy < sh and
      map[[newx, newy]] not in ['grass', 'flowerspawn']
        meat.x = newx
        meat.y = newy

        thing = map[[meat.x, meat.y]]

        switch thing
          when 'meatspawn'
            meat.ammo = 5

          when undefined
            if meat.ammo
              map[[meat.x, meat.y]] = 'meat'
              meat.ammo--

  dude.x += dudespeed * dt * Math.cos dude.angle
  dude.y += dudespeed * dt * Math.sin dude.angle



draw = ->
  ctx.fillStyle = 'white'
  ctx.fillRect 0, 0, canvas.width, canvas.height
  
  ctx.save()
  ctx.translate -sx * tileSize, -sy * tileSize

  for tx in [sx..sx+sw]
    for ty in [sy..sy+sh]
      thing = map[[tx,ty]]
      switch thing
        when 'meat'
          ctx.fillStyle = '#800000'
          ctx.fillRect tx * tileSize, ty * tileSize, tileSize, tileSize
        when 'grass'
          ctx.fillStyle = '#008000'
          ctx.fillRect tx * tileSize, ty * tileSize, tileSize, tileSize
        when 'meatspawn'
          ctx.fillStyle = '#800000'
          ctx.fillRect tx * tileSize, ty * tileSize, tileSize, tileSize
          ctx.fillStyle = 'grey'
          ctx.fillRect (tx + 0.3) * tileSize, (ty + 0.3) * tileSize, tileSize * 0.4, tileSize * 0.4



  # Draw meat player
  ctx.fillStyle = 'red'
  ctx.fillRect meat.x * tileSize, meat.y * tileSize, tileSize, tileSize

  ctx.fillStyle = 'black'
  ctx.fillRect (meat.x + 0.3 + meat.dx * 0.4) * tileSize,
    (meat.y + 0.3 + meat.dy * 0.4) * tileSize, tileSize * 0.4, tileSize * 0.4

  # draw dude
  ctx.fillStyle = 'blue'
  ctx.fillRect dude.x * tileSize, dude.y * tileSize, tileSize/2, tileSize/2


  ctx.restore()


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


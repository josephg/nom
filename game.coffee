canvas = document.getElementsByTagName('canvas')[0]
canvas.width = 1024
canvas.height = 768
ctx = canvas.getContext '2d'

dudespeed = 0.005
dudeturnspeed = 0.1

TAU = Math.PI * 2

mx = my = 0
tileSize = 50
moveDelay = 200

# in tiles.
sx = 0
sy = 0

sw = Math.ceil canvas.width / tileSize
sh = Math.ceil canvas.height / tileSize

# map[[x,y]] = 'meat', 'grass' or null/undefined.

map = {}

meat = {x:0, y:0, dx:1, dy:0, ammo:10}
dude = {x:10.5, y:10.5, angle:0, ammo:2}

map[[meat.x, meat.y]] = ['meat',1]

dist2 = (a, b) ->
  dx = a.x - b.x
  dy = a.y - b.y
  dx * dx + dy * dy

within = (a, b, dist) ->
  dist2(a, b) < dist * dist


map[[10, 0]] = ['meatspawn']
maxlevel = 5

for x in [6..8]
  for y in [6..8]
    map[[x,y]] = ['grass',1]

flowers = []

now = prev = lastMovementFrame = Date.now()

clamp = (x, min, max) -> Math.min(Math.max(x, min), max)

dudePos = (x = dude.x, y = dude.y) -> [Math.floor(x), Math.floor(y)]

update = (dt) ->
  #console.log dt
  if now - lastMovementFrame > moveDelay
    lastMovementFrame += moveDelay

    newx = meat.x + meat.dx
    newy = meat.y + meat.dy

    if 0 <= meat.x + meat.dx < sw and
      0 <= meat.y + meat.dy < sh and
      map[[newx, newy]]?[0] not in ['grass', 'flowerspawn']
        meat.x = newx
        meat.y = newy

        thing = map[[meat.x, meat.y]]

        switch thing?[0]
          when 'meatspawn'
            console.log 'meaat'
            meat.ammo = 10

          when 'meat'
            if meat.ammo and thing[1] < maxlevel
              thing[1]++
              meat.ammo--
              for tx in [meat.x - 1 .. meat.x + 1]
                for ty in [meat.y - 1 .. meat.y + 1]
                  t = map[[tx,ty]]
                  if t and t[0] is 'grass' and t[1] < thing[1]
                    map[[tx,ty]] = null

          when undefined
            if meat.ammo
              map[[meat.x, meat.y]] = ['meat',1]
              meat.ammo--
            
  dude.angle = Math.atan2 my - dude.y * tileSize, mx - dude.x * tileSize
  if dude.move and not within({x:mx/tileSize, y:my/tileSize}, dude, 0.4)
    newx = clamp (dude.x + dudespeed * dt * Math.cos dude.angle), 0, sw
    newy = clamp (dude.y + dudespeed * dt * Math.sin dude.angle), 0, sh

    if map[dudePos(newx, newy)]?[0] isnt 'meat'
      dude.x = newx
      dude.y = newy
    
draw = ->
  ctx.fillStyle = 'white'
  ctx.fillRect 0, 0, canvas.width, canvas.height
  
  ctx.save()
  #ctx.translate -sx * tileSize, -sy * tileSize

  for tx in [sx..sx+sw]
    for ty in [sy..sy+sh]
      thing = map[[tx,ty]]
      switch thing?[0]
        when 'meat'
          meatcolors = ["#800000", "#a00000", "#b00000", "#c00000", "#d00000"]
          ctx.fillStyle = meatcolors[thing[1] - 1]
          ctx.fillRect tx * tileSize, ty * tileSize, tileSize, tileSize
        when 'grass'
          ctx.fillStyle = '#008000'
          ctx.fillRect tx * tileSize, ty * tileSize, tileSize, tileSize
        when 'flower'
          ctx.fillStyle = '#afaf00'
          ctx.fillRect tx * tileSize, ty * tileSize, tileSize, tileSize
        when 'meatspawn'
          ctx.fillStyle = '#800000'
          ctx.fillRect tx * tileSize, ty * tileSize, tileSize, tileSize
          ctx.fillStyle = 'grey'
          ctx.fillRect (tx + 0.3) * tileSize, (ty + 0.3) * tileSize, tileSize * 0.4, tileSize * 0.4

  # border around dude

  ctx.strokeStyle = 'black'
  ctx.strokeRect Math.floor(dude.x) * tileSize, Math.floor(dude.y) * tileSize, tileSize, tileSize


  # Draw meat player
  ctx.fillStyle = 'red'
  ctx.fillRect meat.x * tileSize, meat.y * tileSize, tileSize, tileSize
  ctx.fillStyle = 'grey'
  ctx.fillRect meat.x * tileSize, meat.y * tileSize, tileSize, tileSize * (1 - meat.ammo / 10)

  ctx.fillStyle = 'black'
  ctx.fillRect (meat.x + 0.3 + meat.dx * 0.4) * tileSize,
    (meat.y + 0.3 + meat.dy * 0.4) * tileSize, tileSize * 0.4, tileSize * 0.4

  # draw dude
  ctx.save()
  ctx.translate dude.x * tileSize, dude.y * tileSize
  ctx.rotate dude.angle
  ctx.fillStyle = 'blue'
  ctx.fillRect -10, -10, 20, 20
  #ctx.fillRect -tileSize/4, -tileSize/4, tileSize/2, tileSize/2
  ctx.restore()
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

canvas.onmousemove = (e) ->
  #console.log e.offsetY, e.offsetX
  mx = e.pageX - canvas.offsetLeft
  my = e.pageY - canvas.offsetTop
  
document.onkeydown = (e) ->
  [meat.dx, meat.dy] = [-1, 0] if e.keyCode is 37 # left
  [meat.dx, meat.dy] = [ 1, 0] if e.keyCode is 39 # right
  [meat.dx, meat.dy] = [0, -1] if e.keyCode is 38 # up
  [meat.dx, meat.dy] = [0,  1] if e.keyCode is 40 # down
  
  dude.move = true if e.keyCode is 'W'.charCodeAt 0


  if e.keyCode is 32 and dude.ammo #and map[[Math.floor(dude.x),Math.floor(dude.y)]]?[0]
    # Plant flower.
    #flowers.push
    pos = [Math.floor(dude.x), Math.floor(dude.y)]
    if map[pos]?[0] not in ['meat']
      map[pos] = ['flower', 0]
      flowers.push {p:pos, t:now}
  
document.onkeyup = (e) ->
  dude.move = false if e.keyCode is 'W'.charCodeAt 0

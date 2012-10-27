canvas = document.getElementsByTagName('canvas')[0]
canvas.width = 1024
canvas.height = 768
ctx = canvas.getContext '2d'

TAU = Math.PI * 2

mx = my = 0
tileSize = 64
moveDelay = 0.004

meatDecay = 2000
grassDecay = 5000


# in tiles.
sx = 0
sy = 0

sw = Math.ceil canvas.width / tileSize
sh = Math.ceil canvas.height / tileSize

# map[[x,y]] = 'meat', 'grass' or null/undefined.

map = {}

dudeSpeed = 0.002
dudeReload = -> 1 / (0.001 + dude.land * 0.00001)

meat = {x:0, y:0, dx:0, dy:0, land:0}
dude = {x:canvas.width / tileSize - 0.5, y:canvas.height / tileSize - 0.5, angle:0, reload:0, land:0}

#map[[meat.x, meat.y]] = ['meat',1]

dist2 = (a, b) ->
  dx = a.x - b.x
  dy = a.y - b.y
  dx * dx + dy * dy

within = (a, b, dist) ->
  dist2(a, b) < dist * dist

flowers = []

now = prev = lastMovementFrame = Date.now()

clamp = (x, min, max) -> Math.min(Math.max(x, min), max)

dudePos = (x = dude.x, y = dude.y) -> [Math.floor(x), Math.floor(y)]

placeMeat = ->
  thing = map[[meat.x, meat.y]]

  if !thing
    map[[meat.x, meat.y]] = ['meat', now]
    meat.land++
  else if thing[0] is 'meat'
    thing[1] = now
  
update = (dt) ->
  meatspeed = moveDelay + meat.land * 0.00007
  if now - lastMovementFrame > 1 / meatspeed
    #console.log meat.land, dude.land
    lastMovementFrame += 1/meatspeed

    newx = meat.x + meat.dx
    newy = meat.y + meat.dy

    newThing = map[[newx, newy]]
    if 0 <= meat.x + meat.dx < sw and 0 <= meat.y + meat.dy < sh and
      (!newThing or newThing[0] isnt 'grass' or now - newThing[1] > grassDecay)
        if newThing?[0] is 'grass'
          delete map[[newx, newy]]
          dude.land--

        meat.x = newx
        meat.y = newy

        placeMeat()

  dude.angle = Math.atan2 my - dude.y * tileSize, mx - dude.x * tileSize
  if dude.move and not within({x:mx/tileSize, y:my/tileSize}, dude, 0.4)
    s = dudeSpeed + dude.land * 0.00007

    newx = clamp (dude.x + s * dt * Math.cos dude.angle), 0, sw
    newy = clamp (dude.y + s * dt * Math.sin dude.angle), 0, sh

    if map[dudePos(newx, newy)]?[0] isnt 'meat'
      dude.x = newx
      dude.y = newy

  if dude.firing and dude.reload < now - dudeReload()
    # Plant flower.
    #flowers.push
    if map[pos]?[0] not in ['meat']
      dude.reload = now
      pos = [Math.floor(dude.x), Math.floor(dude.y)]
      #map[pos] = ['flower', 0]
      flowers.push {p:pos, t:now + 1500}

  newf = []
  for f in flowers
    if f.t < now
      if map[[f.p[0], f.p[1]]]?[0] is 'meat'
        console.log 'asdf'
        meat.land--
        delete map[[f.p[0],f.p[1]]]
      for tx in [f.p[0] - 1 .. f.p[0] + 1]
        for ty in [f.p[1] - 1 .. f.p[1] + 1]
          thing = map[[tx, ty]]
          if thing and thing[0] is 'meat' and now - thing[1] > meatDecay
            meat.land--
            delete map[[tx,ty]]
            thing = null
          if !thing or thing[0] is 'grass'
            if !thing then dude.land++
            map[[tx,ty]] = ['grass', now]

    else
      newf.push f

  flowers = newf

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
          colors = ["#800000", "#a00000", "#b00000", "#c00000", "#d00000"]
          ctx.fillStyle = colors[4 - Math.min 4, Math.floor((now - thing[1]) / 400)]
          ctx.fillRect tx * tileSize, ty * tileSize, tileSize, tileSize
        when 'grass'
          colors = ["#008000", "#00a000", "#00b000", "#00c000", "#00d000"]
          ctx.fillStyle = colors[4 - Math.min 4, Math.floor((now - thing[1]) / 1000)]
          ctx.fillRect tx * tileSize, ty * tileSize, tileSize, tileSize

  # flowers
  ctx.fillStyle = '#afaf00'
  for f in flowers
    ctx.fillRect (f.p[0] + 0.2) * tileSize, (f.p[1] + 0.2) * tileSize, tileSize * 0.6, tileSize * 0.6


  # border around dude
  ctx.strokeStyle = 'black'
  ctx.strokeRect Math.floor(dude.x) * tileSize, Math.floor(dude.y) * tileSize, tileSize, tileSize


  # Draw meat player
  ctx.fillStyle = 'red'
  ctx.fillRect meat.x * tileSize, meat.y * tileSize, tileSize, tileSize
  #ctx.fillStyle = 'grey'
  #ctx.fillRect meat.x * tileSize, meat.y * tileSize, tileSize, tileSize * (1 - meat.ammo / maxMeatAmmo)

  ctx.fillStyle = 'black'
  ctx.fillRect (meat.x + 0.3 + meat.dx * 0.4) * tileSize,
    (meat.y + 0.3 + meat.dy * 0.4) * tileSize, tileSize * 0.4, tileSize * 0.4

  # draw dude
  ctx.save()
  ctx.translate dude.x * tileSize, dude.y * tileSize
  ctx.rotate dude.angle
  ctx.fillStyle = if dude.reload < now - dudeReload() then 'blue' else 'black'
  ctx.fillRect -10, -10, 20, 20
  ctx.fillStyle = 'black'
  ctx.fillRect -2, -2, 20, 4
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

document.onmousemove = (e) ->
  #console.log e.offsetY, e.offsetX
  mx = e.pageX - canvas.offsetLeft
  my = e.pageY - canvas.offsetTop
 
pressed = {left:0, right:0, up:0, down:0}
updateD = ->
  meat.dx = pressed.left + pressed.right
  meat.dy = if meat.dx then 0 else pressed.up + pressed.down
 
document.onkeydown = (e) ->
  pressed.left = -1 if e.keyCode is 37 # left
  pressed.right = 1 if e.keyCode is 39 # right
  pressed.up = -1 if e.keyCode is 38 # up
  pressed.down = 1 if e.keyCode is 40 # down
  updateD()

  dude.move = true if e.keyCode is 'W'.charCodeAt 0
  dude.firing = true if e.keyCode is 32

document.onkeyup = (e) ->
  pressed.left = 0 if e.keyCode is 37 # left
  pressed.right = 0 if e.keyCode is 39 # right
  pressed.up = 0 if e.keyCode is 38 # up
  pressed.down = 0 if e.keyCode is 40 # down
  updateD()

  dude.move = false if e.keyCode is 'W'.charCodeAt 0
  dude.firing = false if e.keyCode is 32

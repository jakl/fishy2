do ->#adapted from creativejs.com/resources/requestanimationframe
  lastTime = 0
  vendors = ['ms', 'moz', 'webkit', 'o']

  for vendor in vendors
    break if window.requestAnimationFrame
    window.requestAnimationFrame = window[vendor+'RequestAnimationFrame']
    window.cancelAnimationFrame = window[vendor+'CancelAnimationFrame'] or window[vendor+'CancelRequestAnimationFrame']

  if not window.requestAnimationFrame
    window.requestAnimationFrame = (callback, element)->
      currTime = new Date().getTime()
      timeToCall = Math.max 0, 16 - (currTime - lastTime)
      id = after timeToCall, -> callback currTime + timeToCall
      lastTime = currTime + timeToCall
      return id

  if not window.cancelAnimationFrame
    window.cancelAnimationFrame = (id)-> clearTimeout id

every=(ms,cb)->setInterval cb,ms
after=(ms,cb)->setTimeout cb,ms

c = $('canvas')[0].getContext '2d'
c.fillOval=(xm,ym,r)-> #paramas are relative positions
  cw=c.canvas.width
  ch=c.canvas.height
  xm *= cw
  ym *= ch
  w = r*2*cw
  h = r*2*ch

  x = xm-w/2
  y = ym-h/2
  xe = xm+w/2
  ye = ym+h/2

  kappa = .5522848
  ox = (w / 2) * kappa # control point offset horizontal
  oy = (h / 2) * kappa # control point offset vertical

  @beginPath()
  @moveTo(x, ym)
  @bezierCurveTo(x, ym - oy, xm - ox, y, xm, y)
  @bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym)
  @bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye)
  @bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym)
  @closePath()
  @fill()

resize=->
  c.canvas.width=window.innerWidth
  c.canvas.height=window.innerHeight
window.onresize=resize
resize()

colors=do->
  combinations=[]
  for i in ['0','f']
    for j in ['0','f']
      for k in ['0','f']
        combinations.push i+j+k
  combinations.shift() #no black allowed
  combinations

randomcolor=->colors[Math.floor Math.random()*colors.length]

class fish
  #This one line constructor needs to be on multiple lines with comments but in some cases a multiline constructor crashes node
  constructor:(@x=Math.random(), @y=Math.random(), @r=Math.random()*.05+.005, @color=randomcolor(), @maxspeed=.2, @maxacceleration=.03, @swimpower=Math.random()*.003, @xa=0, @ya=0, @xs=0, @ys=0)->
    #x and y are midpoints of the fish which is a perfect circle until drawn as an oval to match screen width and height ratio
  draw:->
    c.fillStyle=@color
    c.fillOval @x, @y, @r
  move:->
    @limitmovement()
    @xs += @xa #Accelerate
    @ys += @ya
    @x += @xs #Move
    @y += @ys
    @limitmovement()
    @applyfriction()
    @wrap()
  limitmovement:->
    #Need to limit acceleration regardless of direction
    if Math.abs(@xa) > @maxacceleration
      @xa = @maxacceleration if @xa>0
      @xa = -@maxacceleration if @xa<0
    if Math.abs(@ya) > @maxacceleration
      @ya = @maxacceleration if @ya>0
      @ya = -@maxacceleration if @ya<0

    if Math.abs(@xs) > @maxspeed
      @xs = @maxspeed if @xs>0
      @xs = -@maxspeed if @xs<0
    if Math.abs(@ys) > @maxspeed
      @ys = @maxspeed if @ys>0
      @ys = -@maxspeed if @ys<0
  applyfriction:->
    @xa *= .80
    @ya *= .80
    @xs *= .95
    @ys *= .95
  wrap:->
    left = -@r
    right = 1+@r
    @x = left if @x > right
    @y = left if @y > right
    @x = right if @x+@r < left
    @y = right if @y+@r < left
  moverandomly:->
    @xa+=Math.random()*@swimpower*2-@swimpower
    @ya+=Math.random()*@swimpower*2-@swimpower
  colides:(f)->
    x = @x-f.x
    y = @y-f.y
    r =  @r+f.r
    x*x+y*y < r*r
  trumps:(f)-> @r > f.r
  eats:(f)->
    f.isdead = true
    @r+= ((f.r*f.r) / (@r*@r)) /100
    @isdead=true if @r > .5 #You are too fat, and thus, dead

player1 = new fish()
player2 = new fish()
player1.isplayer = true
player2.isplayer=true
pond=[player1, player2]

every 1000,-> pond.unshift new fish() unless pond.length>100 #add fish

draw = ->
  requestAnimationFrame draw
  c.clearRect 0, 0, c.canvas.width, c.canvas.height
  for f in pond
    f.draw()
    f.move()
    #f.moverandomly() unless f.isplayer? and f.isplayer
  for i in [0...pond.length-1]
    for j in [i+1...pond.length]
      if pond[i].colides(pond[j])
        if pond[i].trumps(pond[j])
          pond[i].eats pond[j]
        if pond[j].trumps(pond[i])
          pond[j].eats pond[i]
  for i in [pond.length-1...0] #kill dead
    pond[i..i]=[] if pond[i].isdead? and pond[i].isdead

  if keys.up then player1.ya -= player1.swimpower
  if keys.down then player1.ya += player1.swimpower
  if keys.left then player1.xa -= player1.swimpower
  if keys.right then player1.xa += player1.swimpower

  if keys.w then player2.ya -= player2.swimpower
  if keys.s then player2.ya += player2.swimpower
  if keys.a then player2.xa -= player2.swimpower
  if keys.d then player2.xa += player2.swimpower

keys = {}

$('body').keydown (key)->
  switch key.keyCode
    when 37 then keys.left=true
    when 39 then keys.right=true
    when 38 then keys.up=true
    when 40 then keys.down=true
    when 32 then keys.space=true
    when 65 then keys.a=true
    when 68 then keys.d=true
    when 87 then keys.w=true
    when 83 then keys.s=true
    else console.log key.keyCode

$('body').keyup (key)->
  switch key.keyCode
    when 37 then keys.left=false
    when 39 then keys.right=false
    when 38 then keys.up=false
    when 40 then keys.down=false
    when 32 then keys.space=false
    when 65 then keys.a=false
    when 68 then keys.d=false
    when 87 then keys.w=false
    when 83 then keys.s=false

$('canvas').mousedown (mouse)->
  mx = mouse.pageX/c.canvas.width
  my = mouse.pageY/c.canvas.height
  for f in pond
    if f.colides(x:mx,y:my,r:0)
      console.log 'GOT ONE!'
      player1.isplayer=false
      player1 = f
      f.isplayer=true
    else
      console.log 'missed...'

draw()

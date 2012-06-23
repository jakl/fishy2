every=(ms,cb)->setInterval cb,ms

c = $('canvas')[0].getContext '2d'
c.fillOval=(x,y,w,h)->
  this.beginPath()

  kappa = .5522848
  ox = (w / 2) * kappa # control point offset horizontal
  oy = (h / 2) * kappa # control point offset vertical
  xe = x + w           # x-end
  ye = y + h           # y-end
  xm = x + w / 2       # x-middle
  ym = y + h / 2       # y-middle

  this.beginPath()
  this.moveTo(x, ym)
  this.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y)
  this.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym)
  this.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye)
  this.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym)
  this.closePath()
  this.fill()

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
  constructor:(@x=Math.random(), @y=Math.random(), @r=Math.random()*.05+.005, @color=randomcolor(), @maxspeed=.2, @maxacceleration=.03, @swimpower=Math.random()*.006, @xa=0, @ya=0, @xs=0, @ys=0)->
  draw:(c)->
    cw=c.canvas.width
    ch=c.canvas.height
    c.fillStyle=@color
    c.fillOval @x*cw, @y*ch, @r*2*cw, @r*2*ch
  move:->
    @limitmovement()
    @xs += @xa #Accelerate
    @ys += @ya
    @x += @xs #Move
    @y += @ys
    @limitmovement()
    @wrap()
  limitmovement:->
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
    if @r > .5
      @isdead=true

    @xa *= .80
    @ya *= .80
    @xs *= .95
    @ys *= .95
  wrap:->
    if @x > 1 then @x = -@r
    if @x+@r < 0 then @x = 1
    if @y > 1 then @y = -@r
    if @y+@r < 0 then @y = 1
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

player1 = new fish()
player2 = new fish()
player1.isplayer = true
player2.isplayer=true
pond=[player1, player2]

every 1000,-> pond.unshift new fish() unless pond.length>100 #add fish

every 30,-> #draw and update fish
  c.clearRect 0, 0, c.canvas.width, c.canvas.height
  for f in pond
    f.draw c
    f.move()
    f.moverandomly() unless f.isplayer? is true
  for i in [0...pond.length-1] #trump fish eat munch fish
    for j in [i+1...pond.length]
      if pond[i].colides(pond[j])
        if pond[i].trumps(pond[j])
          pond[i].eats pond[j]
        if pond[j].trumps(pond[i])
          pond[j].eats pond[i]
  for i in [pond.length-1...0] #kill dead
    pond[i..i]=[] if pond[i].isdead? is true

  if keys.left then player1.xa -= player1.swimpower
  if keys.right then player1.xa += player1.swimpower
  if keys.up then player1.ya -= player1.swimpower
  if keys.down then player1.ya += player1.swimpower

  if keys.a then player2.xa -= player2.swimpower
  if keys.d then player2.xa += player2.swimpower
  if keys.w then player2.ya -= player2.swimpower
  if keys.s then player2.ya += player2.swimpower

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

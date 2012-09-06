ss.rpc 'demo.is_authed', (is_authed)->
  $('#login').modal 'show' unless is_authed

ss.event.on 'username', (username) -> p.username = username

do ->#adapted from creativejs.com/resources/requestanimationframe
  w = window

  for vendor in ['ms', 'moz', 'webkit', 'o']
    break if w.requestAnimationFrame
    w.requestAnimationFrame = w[vendor+'RequestAnimationFrame']
    w.cancelAnimationFrame = w[vendor+'CancelAnimationFrame'] or w[vendor+'CancelRequestAnimationFrame']

  lastTime = 0
  w.requestAnimationFrame or= (callback)->
    currTime = new Date().getTime()
    timeToCall = Math.max 0, 16 - (currTime - lastTime)
    id = after timeToCall, -> callback currTime + timeToCall
    lastTime = currTime + timeToCall
    return id

  w.cancelAnimationFrame or= (id)-> clearTimeout id

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

class fish
  allowedcolors:do->
    combinations=[]
    for i in ['0','f']
      for j in ['0','f']
        for k in ['0','f']
          combinations.push i+j+k
    combinations.shift() #no black allowed
    combinations
  randomcolor:->@allowedcolors[Math.floor Math.random()*@allowedcolors.length]
  constructor:(@isplayer=false)->
    #midpoints and radius as percentages of screen width and height
    @x=Math.random()
    @y=Math.random()
    @r=Math.random()*.07+.002

    @color=@randomcolor()
    @maxspeed=.01
    @swimpower=Math.random()*.0003
    @xa=0
    @ya=0
    @xs=0
    @ys=0

    @isdead=false

  draw:->
    c.fillStyle=@color
    c.fillStyle = 'black' if @isdead
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
    #Need to limit speed regardless of direction
    if Math.abs(@xs) > @maxspeed
      @xs = @maxspeed if @xs>0
      @xs = -@maxspeed if @xs<0
    if Math.abs(@ys) > @maxspeed
      @ys = @maxspeed if @ys>0
      @ys = -@maxspeed if @ys<0
  applyfriction:->
    @xs *= .95
    @ys *= .95
    @xa *= .75
    @ya *= .75
  wrap:->
    left = -@r
    right = 1+@r
    @x = left if @x > right
    @y = left if @y > right
    @x = right if @x < left
    @y = right if @y < left
  moverandomly:->
    @xa = [-4..4][Math.floor(Math.random()*9)] *@swimpower
    @ya = [-4..4][Math.floor(Math.random()*9)] *@swimpower
  colides:(f)->
    x = @x-f.x
    y = @y-f.y
    r =  @r+f.r
    x*x+y*y < r*r
  trumps:(f)-> @r > f.r
  eats:(f)->
    f.isdead = true
    @r+= ((f.r*f.r) / (@r*@r)) /100
    @isdead=true if @r > .2 #You are too fat, and thus, dead

class pond
  reset:=>
    @initcontrols()
    @fishes=[new fish true]
    @player = @fishes[0]
    @draw()
    every 1000, => @fishes.unshift new fish() unless @fishes.length>10
  colide:=>
    for f in @fishes
      for i in @fishes
        continue if i is f
        if f.colides i
          if f.trumps i
            f.eats i
          else
            i.eats f
  update:=>
    @keyboardinput()
    for f in @fishes
      f.moverandomly() if not f.isplayer and Math.random()>.2
      f.move()
    @colide()
    for i in [@fishes.length-1..0] #kill dead
      @fishes[i..i]=[] if @fishes[i].isdead
  keyboardinput:=>
    @player.ya -= @player.swimpower if @keys.up
    @player.ya += @player.swimpower if @keys.down
    @player.xa -= @player.swimpower if @keys.left
    @player.xa += @player.swimpower if @keys.right

    if @keys.z then f.r *= 1.2 for f in @fishes
    if @keys.x then f.r /= 1.2 for f in @fishes
  draw:=>
    requestAnimationFrame @draw
    c.clearRect 0, 0, c.canvas.width, c.canvas.height
    f.draw() for f in @fishes
    c.fillStyle = 'white'
    c.font = '20pt Arial'
    c.fillText @username, 10, 30
    @update()
  click:(mx,my)=>
    for f in @fishes
      if f.colides(x:mx,y:my,r:0)
        @player?.isplayer=false
        @player = f
        f.isplayer=true
  initcontrols:->
    @keys = {}
    $('body').keydown (key)=>
      switch key.keyCode
        when 37
          @keys.left = true
          ss.rpc 'demo.keydown', 'left'
        when 39
          @keys.right = true
          ss.rpc 'demo.keydown', 'right'
        when 38
          @keys.up = true
          ss.rpc 'demo.keydown', 'up'
        when 40
          @keys.down = true
          ss.rpc 'demo.keydown', 'down'
        when 32
          @keys.space = true
          ss.rpc 'demo.keydown', 'space'
          $('#login').modal 'toggle'
        when 90
          @keys.z = true
          ss.rpc 'demo.keydown', 'z'
        when 88
          @keys.x = true
          ss.rpc 'demo.keydown', 'x'
        else console.log key.keyCode

    $('body').keyup (key)=>
      switch key.keyCode
        when 37
          @keys.left = false
          ss.rpc 'demo.keyup', 'left'
        when 39
          @keys.right = false
          ss.rpc 'demo.keyup', 'right'
        when 38
          @keys.up = false
          ss.rpc 'demo.keyup', 'up'
        when 40
          @keys.down = false
          ss.rpc 'demo.keyup', 'down'
        when 32
          @keys.space = false
          ss.rpc 'demo.keyup', 'space'
        when 90
          @keys.z = false
          ss.rpc 'demo.keyup', 'z'
        when 88
          @keys.x = false
          ss.rpc 'demo.keyup', 'x'

    $('canvas').mousedown (mouse)=>
      mx = mouse.pageX/c.canvas.width
      my = mouse.pageY/c.canvas.height
      ss.rpc 'demo.mousedown', mx, my
      @click mx, my

p = new pond()
p.reset()

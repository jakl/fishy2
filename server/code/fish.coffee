module.exports =
  class
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

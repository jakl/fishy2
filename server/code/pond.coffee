every=(ms,cb)->setInterval cb,ms
after=(ms,cb)->setTimeout cb,ms
fish = require './fish.js'

module.exports =
  reset:->
    @keys =
      up: false
      down: false
      left: false
      right: false
    @fishes=[new fish true]
    @player = @fishes[0]
    @draw()
    every 1000, => @fishes.unshift new fish() unless @fishes.length>10
    @
  colide:->
    for f in @fishes
      for i in @fishes
        continue if i is f
        if f.colides i
          if f.trumps i
            f.eats i
          else
            i.eats f
  update:->
    @keyboardinput()
    for f in @fishes
      f.moverandomly() if not f.isplayer and Math.random()>.2
      f.move()
    @colide()
    for i in [@fishes.length-1..0] #kill dead
      @fishes[i..i]=[] if @fishes[i].isdead
  keyboardinput:->
    @player.ya -= @player.swimpower if @keys.up
    @player.ya += @player.swimpower if @keys.down
    @player.xa -= @player.swimpower if @keys.left
    @player.xa += @player.swimpower if @keys.right

    if @keys.z then f.r *= 1.2 for f in @fishes
    if @keys.x then f.r /= 1.2 for f in @fishes
  draw:->
    @update()
  click:(mx,my)->
    for f in @fishes
      if f.colides(x:mx,y:my,r:0)
        @player?.isplayer=false
        @player = f
        f.isplayer=true

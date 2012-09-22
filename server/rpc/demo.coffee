exports.actions = (req, res, ss) ->
  req.use 'session'
  req.use 'user.authed'

  is_authed: ->
    ss.publish.user user, 'username', user
    res true
  get_ss: -> res ss

  newfish: (fish) ->
    console.log fish
    ss.publish.all('newfish', fish)     # Broadcast the message to everyone
    res(true)                                 # Confirm it was sent to the originating client


  keydown: (key)->
    s = req.session
    switch key
      when 'left'
        s.left=true
        s.save()
      when 'right'
        s.right=true
        s.save()
      when 'up'
        s.up=true
        s.save()
      when 'down'
        s.down=true
        s.save()
      when 'space'
        s.space=true
        s.save()
      when 'z'
        s.z=true
        s.save()
      when 'x'
        s.x=true
        s.save()

  keyup: (key)->
    s = req.session
    switch key
      when 'left'
        s.left=false
        s.save()
      when 'right'
        s.right=false
        s.save()
      when 'up'
        s.up=false
        s.save()
      when 'down'
        s.down=false
        s.save()
      when 'space'
        s.space=false
        s.save()
      when 'z'
        s.z=false
        s.save()
      when 'x'
        s.x=false
        s.save()
  mousedown: (x,y)->
    s = req.session
    s.mousex=x
    s.mousey=y
    s.save()

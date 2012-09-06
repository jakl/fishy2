exports.actions = (req, res, ss) ->
  req.use('session')

  ss.heartbeat.on 'disconnect', (session)-> console.log "#{session.userId} disconnected"
  ss.heartbeat.on 'connect', (session)-> console.log "#{session.userId} connected"
  ss.heartbeat.on 'reconnect', (session)-> console.log "#{session.userId} reconnected"

  #Deny users without a userId, meaning they havn't authed yet
  req.use -> (req, res, next)->
    if req.session and req.session.userId? then next()
    else res false

  req.use -> (req)->
    ss.publish.user req.session.userId, 'username', req.session.userId

  is_authed: -> res true

  #auth using twitter, save data on user session, remove on disconnect, all users get data of all other users, server has logic

###
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
###

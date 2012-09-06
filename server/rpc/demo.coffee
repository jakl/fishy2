exports.actions = (req, res, ss) ->
  req.use('session')

  #Deny users without a userId, meaning they havn't authed yet
  req.use -> (req, res, next)->
    if req.session and req.session.userId? then next()
    else res false

  req.use -> (req)->
    ss.publish.user req.session.userId, 'username', req.session.userId

  is_authed: -> res true

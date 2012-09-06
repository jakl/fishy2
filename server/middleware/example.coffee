exports.authenticated = ->
  (req, res, next) ->
    if req.session and req.session.userId? then next() else res false

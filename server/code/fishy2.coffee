module.exports = (ss)->
  f = ss.api.fishy = {}
  f.pond = (require './pond.js').reset()

http = require 'http'
ss = require 'socketstream'
everyauth = require 'everyauth'
require('./auth.js')(everyauth)

redis =
  host: 'clingfish.redistogo.com'
  port: 9402
  pass: '150e688374536416d6cc82373db38dc9'

ss.client.define 'main',
  view: 'app.jade'
  css:  ['libs', 'app.styl']
  code: ['libs', 'app']
  tmpl: '*'

ss.http.route '/', (req, res)-> res.serveClient 'main'

ss.publish.transport.use 'redis', redis
ss.session.store.use 'redis', redis
ss.responders.add require('ss-heartbeat-responder'), redis

ss.client.formatters.add require 'ss-coffee'
ss.client.formatters.add require 'ss-jade'
ss.client.formatters.add require 'ss-stylus'
ss.client.templateEngine.use require 'ss-hogan'
ss.http.middleware.append everyauth.middleware()

#Minimize and pack assets if you type: SS_ENV=production node app.js
ss.client.packAssets() if ss.env is 'production'

server = http.Server ss.http.middleware
server.listen 3000

consoleServer = require('ss-console')(ss)
consoleServer.listen(5000)

ss.start(server)

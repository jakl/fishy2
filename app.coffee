http = require 'http'
ss = require 'socketstream'
everyauth = require 'everyauth'
require('./auth.js')(everyauth)

ss.client.define 'main',
  view: 'app.jade'
  css:  ['libs', 'app.styl']
  code: ['libs', 'app']
  tmpl: '*'

ss.http.route '/', (req, res)-> res.serveClient 'main'

ss.client.formatters.add require 'ss-coffee'
ss.client.formatters.add require 'ss-jade'
ss.client.formatters.add require 'ss-stylus'
ss.client.templateEngine.use require 'ss-hogan'
ss.http.middleware.append everyauth.middleware()

#Minimize and pack assets if you type: SS_ENV=production node app.js
ss.client.packAssets() if ss.env is 'production'

server = http.Server ss.http.middleware
server.listen 80

#consoleServer = require('ss-console')(ss)
#consoleServer.listen(5000)

ss.start(server)

// Generated by CoffeeScript 1.3.3
(function() {
  var consoleServer, everyauth, http, server, ss;

  http = require('http');

  ss = require('socketstream');

  everyauth = require('everyauth');

  require('./auth.js')(everyauth);

  ss.client.define('main', {
    view: 'app.jade',
    css: ['libs', 'app.styl'],
    code: ['libs', 'app'],
    tmpl: '*'
  });

  ss.http.route('/', function(req, res) {
    return res.serveClient('main');
  });

  ss.session.store.use('redis', {
    host: 'clingfish.redistogo.com',
    port: 9402,
    pass: '150e688374536416d6cc82373db38dc9',
    db: 1
  });

  ss.publish.transport.use('redis', {
    host: 'clingfish.redistogo.com',
    port: 9402,
    pass: '150e688374536416d6cc82373db38dc9',
    db: 1
  });

  ss.client.formatters.add(require('ss-coffee'));

  ss.client.formatters.add(require('ss-jade'));

  ss.client.formatters.add(require('ss-stylus'));

  ss.client.templateEngine.use(require('ss-hogan'));

  ss.responders.add(require('ss-heartbeat-responder'));

  ss.http.middleware.append(everyauth.middleware());

  if (ss.env === 'production') {
    ss.client.packAssets();
  }

  server = http.Server(ss.http.middleware);

  server.listen(3000);

  consoleServer = require('ss-console')(ss);

  consoleServer.listen(5000);

  ss.start(server);

}).call(this);

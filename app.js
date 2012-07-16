// My SocketStream app

var http = require('http')
  , ss = require('socketstream');

// Define a single-page client
ss.client.define('main', {
  view: 'app.jade',
  css:  ['libs', 'app.styl'],
  code: ['libs', 'app'],
  tmpl: '*'
});

// Serve this client on the root URL
ss.http.route('/', function(req, res){
  res.serveClient('main');
})

// Code Formatters
ss.client.formatters.add(require('ss-coffee'));
ss.client.formatters.add(require('ss-jade'));
ss.client.formatters.add(require('ss-stylus'));

// Use server-side compiled Hogan (Mustache) templates. Others engines available
ss.client.templateEngine.use(require('ss-hogan'));

// Minimize and pack assets if you type: SS_ENV=production node app.js
if (ss.env == 'production') ss.client.packAssets();

// Start web server
var server = http.Server(ss.http.middleware);
server.listen(80);

// Start Console Server (REPL)
// To install client: sudo npm install -g ss-console
// To connect: ss-console <optional_host_or_port>
//var consoleServer = require('ss-console')(ss);
//consoleServer.listen(5000);

// Start SocketStream
ss.start(server);

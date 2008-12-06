# == Synopsis
#
# http2xmpp: starts a HTTP server and a XMPP agent so you can send messages
# to XMPP through HTTP. It spawns a HTTP server on localhost:3001 where you
# can point your browser (or other client) at http://localhost:3001/send
#
# == Usage
#
# http2xmpp --jid user@domain.com --password password
#
# -j, --jid:
#     The XMPP user to connect
# 
# -p, --password:
#     The password of the XMPP user
#
# -h, --help:
#     Shows this message

require 'rubygems'
require 'webrick'
require 'xmpp4r-simple'
require 'logger'
require 'getoptlong'
require 'rdoc/usage'

include WEBrick
LOGGER = Logger.new(STDERR)

opts = GetoptLong.new(
  [ '--jid', '-j', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--password', '-p', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
)

jid = nil
pass = nil

opts.each do |opt, arg|
  case opt
  when '--jid'
    jid = arg.to_s
  when '--password'
    pass = arg.to_s
  when '--help'
    RDoc::usage
  end
end

unless jid && pass
  RDoc::usage
end

bot = Jabber::Simple.new(jid, pass)
LOGGER.info("Bot initialized")

s = HTTPServer.new(:Port => 3001)
s.mount_proc("/send") do |req, res|
  body = req.query['body'] || ''
  to   = req.query['to'] || ''
  
  extra = ''
  unless body.empty? || to.empty?
    LOGGER.info "Sending #{body} to #{to}"
    
    bot.deliver(to, body)
    extra = '<p style="color: red;">Thank you sir, can I have another?</p>';
  end
  
  res['Content-Type'] = 'text/html'
  res.body = <<EOH
    <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
      <title>Send a message!</title>
    </head>
    <body>
      <h1>Send a message</h1>
      #{extra}
      <form method="post" action="/send" accept-charset="utf-8">
        <label for="to">JID:</label><input type="text" name="to" id="to" value="#{to}" size="60"/><br />
        <label for="body">Body:</label><textarea name="body" id="body" cols="50" rows="4">#{body}</textarea><br />
        <input type="submit" value="Send!" />
      </form>
    </body>
    </html>
EOH
end

trap("INT") { s.shutdown }
s.start
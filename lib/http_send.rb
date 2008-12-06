# == Synopsis
#
# http_send: sends a message to a xmpp user, using a HTTP server
#
# == Usage
# 
# http_send --to user@domain.com --body "howdy world!" [--xml "<foo>bar</foo>"]
#
# -t, --to:
#   the XMPP user you want to send the message
#
# -b, --body:
#   a text to send to the user
#
# -x, --xml:
#   optinal XML stanza to include in the XMPP message

require 'getoptlong'
require 'rdoc/usage'
require 'net/http'
require 'uri'

opts = GetoptLong.new(
  [ '--to', '-t', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--body', '-b', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--xml', '-x', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
)

to = nil
body = nil
xml = nil

opts.each do |opt, arg|
  case opt
  when '--to'
    to = arg.to_s
  when '--body'
    body = arg.to_s
  when '--xml'
    xml = xml.to_s
  when '--help'
    RDoc::usage
  end
end

unless to
  puts "Type the destination JID:\n"
  to = STDIN.readline.chomp
end

unless body
  puts "Type the message to send, CTRL-D to send, CTRL-C to abort\n"
  body = STDIN.read.chomp
end

Net::HTTP.post_form(
  URI.parse('http://127.0.0.1:3001/send'),
  { "to" => to, "body" => body, "xml" => xml }
)

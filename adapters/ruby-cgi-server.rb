#! /usr/bin/env ruby

require "webrick"

port       = 8080
hostname   = '127.0.0.1'
cgi_script = nil

while ARGV.any?
  if %w[ -p --port ].include?(ARGV.first)
    ARGV.shift
    port = ARGV.shift
  elsif %w[ -h --host ].include?(ARGV.first)
    ARGV.shift
    hostname = ARGV.shift
  elsif File.file?(ARGV.first)
    cgi_script = ARGV.shift
  else
    STDERR.puts "Unexpected argument to run-cgi.rb: #{ARGV.first}. Expected path to CGI script or -p/--port argument or -h/--host argument"
    exit 1
  end
end

unless cgi_script && File.file?(cgi_script)
  STDERR.puts "run-cgi.rb missing expected argument: path to CGI script"
  exit 1
end

cgi_script = File.expand_path cgi_script
root_dir   = File.dirname cgi_script
server     = WEBrick::HTTPServer.new Port: port, Host: hostname, DocumentRoot: root_dir

server.mount "/", WEBrick::HTTPServlet::CGIHandler, cgi_script

trap 'INT' do
  server.shutdown
end

STDERR.puts "CGI script '#{cgi_script}' running at http://#{hostname}:#{port}/"

server.start
cgi-server() {
  VERSION=0.1.0
  USAGE="cgi-server - 🔌 Connecting BASH to the web!

Usage:

  cgi-server start my-script.cgi

  cgi-server start my-script.cgi -p 8080

  cgi-server start my-script.cgi --port 8080 -h 0.0.0.0

  cgi-server start my-script.cgi --adapter ruby

  cgi-server start my-script.cgi --adapter uwsgi

  cgi-server start my-script.cgi --adapter [custom]

Default port: 8080

Default host: 127.0.0.1

To provide a [custom] adapter, there must be a defined
function named [custom]CgiAdapter which responds to
the following commands:

  myCgiAdapter start file.cgi     # must output server identifier, e.g. PID
                                  # and return 0 if server started successfully
                                  # else return non-zero with message in STDERR
                                  # please block until your server is ready
                                  # to receive requests (e.g. use curl to verify)

  myCgiAdapter stop [identifier]  # the id returned by 'start' is used by 'stop'

All arguments (excluding --adapter xxx) will be passed to the adapter
including the raw -p/--port or -h/--host and all other arguments.

Your adapter is responsible for parsing and handling any provided arguments.
"

  [ "$1" = "--version" ] && { echo "cgi-server version $VERSION"; return 0; } 
  ([ "$1" = "-h" ] || [ "$1" = "--help" ]) && { echo "$USAGE"; return 0; }
  [ $# -eq 0 ] && { echo "Missing required argument for cgi-server: [start|stop]\n\n$USAGE" >&2; return 1; }
  [ "$1" != "start" ] && [ "$1" != "stop" ] && { echo "Unexpected cgi-server command: $1. Expected 'start' or 'stop'." >&2; return 1; }

  # Either auto-detect or use provided adapter
  local adapter=""

  # Arguments to pass-thru to adapter (everything but --adapter argument)
  declare adapterArguments=()
  while [ $# -gt 0 ]
  do
    if [ "$1" == "--adapter" ]
    then
      shift
      adapter="$1"
      shift
    else
      adapterArguments+=("$1")
      shift
    fi
  done

  if [ -z "$adapter" ]
  then
    # hard-coded support for ruby (and others when implemented)
    if [ -f "${BASH_SOURCE[0]%cgi-server.sh}adapters/ruby.sh" ] && which ruby &>/dev/null
    then
      source "${BASH_SOURCE[0]%cgi-server.sh}adapters/ruby.sh"
      adapter=ruby
    else
      echo "No --adapter provided and no available CGI adapters auto-detected (ruby missing on system)" >&2
      return 1
    fi
  fi

  local adapterFunction="${adapter}CgiAdapter"

  # Delegate to adapter
  "$adapterFunction" "${adapterArguments[@]}"
}
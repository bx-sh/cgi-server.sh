# 🔌 `@cgi-server`

Connecting BASH to the web!

---

```sh
$ bin/cgi-server --help

# Usage:
#
#   cgi-server start my-script.cgi
#
#   cgi-server start my-script.cgi -p 8080
#
#   cgi-server start my-script.cgi --port 8080 -h 0.0.0.0
#
#   cgi-server start my-script.cgi --adapter ruby
#
#   cgi-server start my-script.cgi --adapter uwsgi
#
#   cgi-server start my-script.cgi --adapter [custom]
#
# Default port: 8080
#
# Default host: 127.0.0.1
#
# To provide a [custom] adapter, there must be a defined
# function named [custom]CgiAdapter which responds to
# the following commands:
#
#   myCgiAdapter start file.cgi     # must output server identifier, e.g. PID
#                                   # and return 0 if server started successfully
#                                   # else return non-zero with message in STDERR
#                                   # please block until your server is ready
#                                   # to receive requests (e.g. use curl to verify)
#
#   myCgiAdapter stop [identifier]  # the id returned by 'start' is used by 'stop'
#
# All arguments (excluding --adapter xxx) will be passed to the adapter
# including the raw -p/--port or -h/--host and all other arguments.
#
# Your adapter is responsible for parsing and handling any provided arguments.
```

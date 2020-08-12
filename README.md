# 🔌 Connecting BASH to the web!

---

Download the [latest version](https://github.com/bx-sh/cgi-server.sh/archive/v0.1.0.tar.gz)

```sh
$ PATH="$PATH:cgi-server/bin"

$ cgi-server --version
cgi-server version 0.1.0
```

---

### `cgi-server start my-cgi-script.sh`

```sh
$ ./bin/cgi-server start helloWorld.cgi
# Running CGI script [helloWorld.cgi]
# http://127.0.0.1:8080/
# Server identifier: 886841
```

```sh
$ curl http://localhost:8080/
# Hello, world!
```

### `cgi-server stop [server identifier]`

```sh
$ ./bin/cgi-server stop 886841
# Stopped CGI script [886841]
```

```sh
$ curl http://localhost:8080/
# curl: (7) Failed to connect to localhost port 8080: Connection refused
```

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

---

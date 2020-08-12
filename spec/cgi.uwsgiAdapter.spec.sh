import @cgi-server
import @cgi-server/adapters/uwsgi

##
# Test running Ruby CGI adapter via cgi-server --adapter uwsgi
##

stopRunningInstances() {
  ps -C "uwsgi" -o pid= | xargs -n 1 kill -s INT &>/dev/null
}

@after() {
  stopRunningInstances
  return 0
}

@example.start.file_not_found() {
  refute run cgi-server start --adapter uwsgi i-dont-exist.sh
  expect "$STDOUT" toBeEmpty
  expect "$STDERR" toContain "Unsupported" "i-dont-exist.sh" "Expected" "CGI script"
}

@example.stop.no_arguments() {
  refute run cgi-server stop --adapter uwsgi
  expect "$STDOUT" toBeEmpty
  expect "$STDERR" toContain "Missing" "server identifier" "returned" "start"
}

@example.stop.not_running() {
  refute run cgi-server stop --adapter uwsgi 123789
  expect "$STDOUT" toBeEmpty
  expect "$STDERR" toContain "No" "running" "instance"
}

@example.stop.invalid_looking_pid() {
  refute run cgi-server stop --adapter uwsgi abc123
  expect "$STDOUT" toBeEmpty
  expect "$STDERR" toContain "Invalid" "numeric"
}

@example.start.file_not_executable() {
  refute run cgi-server start --adapter uwsgi spec/scripts/not_executable
  expect "$STDOUT" toBeEmpty
  expect "$STDERR" toContain "executable" "chmod +x"
}

@example.run_and_stop_ok() {
  local script_name="hello_world"

  refute run curl -i http://127.0.0.1:$PORT1/

  assert run cgi-server start --adapter uwsgi "spec/scripts/$script_name" --port "$PORT1" --host "$HOST"
  expect "$STDERR" toContain "Running" "CGI" "http://$HOST:$PORT1"
  expect "$STDOUT" toMatch [0-9]+

  local serverId="$STDOUT"

  assert run curl -i http://$HOST:$PORT1/
  expect "$STDOUT" toContain "Hello, world!"
  expect "$STDOUT" toContain "200 OK"

  assert run cgi-server stop --adapter uwsgi "$serverId"
  expect "$STDOUT" toBeEmpty
  expect "$STDERR" toContain "Stopped"

  refute run curl -i http://127.0.0.1:$PORT1/
}

@example.specify_port() {
  local script_name="hello_world"

  refute run curl -i http://127.0.0.1:$PORT2/

  assert run cgi-server start --adapter uwsgi "spec/scripts/$script_name" --port "$PORT2" --host "$HOST"
  expect "$STDERR" toContain "Running" "CGI" "http://$HOST:$PORT2"
  expect "$STDOUT" toMatch [0-9]+

  local serverId="$STDOUT"

  assert run curl -i http://$HOST:$PORT2/
  expect "$STDOUT" toContain "Hello, world!"
  expect "$STDOUT" toContain "200 OK"

  assert run cgi-server stop --adapter uwsgi "$serverId"
  expect "$STDOUT" toBeEmpty
  expect "$STDERR" toContain "Stopped"

  refute run curl -i http://127.0.0.1:$PORT2/
}

@example.different_cgi_script() {
  local script_name="goodnight_moon"

  refute run curl -i http://127.0.0.1:$PORT1/

  assert run cgi-server start --adapter uwsgi "spec/scripts/$script_name" --port "$PORT1" --host "$HOST"
  expect "$STDERR" toContain "Running" "CGI" "http://$HOST:$PORT1"
  expect "$STDOUT" toMatch [0-9]+

  local serverId="$STDOUT"

  assert run curl -i http://$HOST:$PORT1/
  expect "$STDOUT" not toContain "Hello, world!"
  expect "$STDOUT" not toContain "200 OK"
  expect "$STDOUT" toContain "Goodnight, moon!"
  expect "$STDOUT" toContain "404 Not Found"

  assert run cgi-server stop --adapter uwsgi "$serverId"
  expect "$STDOUT" toBeEmpty
  expect "$STDERR" toContain "Stopped"

  refute run curl -i http://127.0.0.1:$PORT1/
}
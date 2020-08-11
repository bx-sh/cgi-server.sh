import @cgi-server

##
# Test running CGI adapter (don't care which adapter)
##

@example.run_and_stop_ok() {
  local script_name="hello_world"

  refute run curl -i http://127.0.0.1:$PORT1/

  assert run cgi-server start "spec/scripts/$script_name" --port "$PORT1" --host "$HOST"
  expect "$STDERR" toContain "Running" "CGI" "http://$HOST:$PORT1"
  expect "$STDOUT" toMatch [0-9]+

  local serverId="$STDOUT"

  assert run curl -i http://$HOST:$PORT1/
  expect "$STDOUT" toContain "Hello, world!"
  expect "$STDOUT" toContain "200 OK"

  assert run cgi-server stop "$serverId"
  expect "$STDOUT" toBeEmpty
  expect "$STDERR" toContain "Stopped"

  refute run curl -i http://127.0.0.1:$PORT1/
}

@example.specify_port() {
  local script_name="hello_world"

  refute run curl -i http://127.0.0.1:$PORT2/

  assert run cgi-server start "spec/scripts/$script_name" --port "$PORT2" --host "$HOST"
  expect "$STDERR" toContain "Running" "CGI" "http://$HOST:$PORT2"
  expect "$STDOUT" toMatch [0-9]+

  local serverId="$STDOUT"

  assert run curl -i http://$HOST:$PORT2/
  expect "$STDOUT" toContain "Hello, world!"
  expect "$STDOUT" toContain "200 OK"

  assert run cgi-server stop "$serverId"
  expect "$STDOUT" toBeEmpty
  expect "$STDERR" toContain "Stopped"

  refute run curl -i http://127.0.0.1:$PORT2/
}

@example.different_cgi_script() {
  local script_name="goodnight_moon"

  refute run curl -i http://127.0.0.1:$PORT1/

  assert run cgi-server start "spec/scripts/$script_name" --port "$PORT1" --host "$HOST"
  expect "$STDERR" toContain "Running" "CGI" "http://$HOST:$PORT1"
  expect "$STDOUT" toMatch [0-9]+

  local serverId="$STDOUT"

  assert run curl -i http://$HOST:$PORT1/
  expect "$STDOUT" not toContain "Hello, world!"
  expect "$STDOUT" not toContain "200 OK"
  expect "$STDOUT" toContain "Goodnight, moon!"
  expect "$STDOUT" toContain "404 Not Found"

  assert run cgi-server stop "$serverId"
  expect "$STDOUT" toBeEmpty
  expect "$STDERR" toContain "Stopped"

  refute run curl -i http://127.0.0.1:$PORT1/
}
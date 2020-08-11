import @cgi-server/adapters/ruby

@example.not_running() {
  refute run curl -i http://localhost:$PORT1
  expect "$STDOUT" toBeEmpty
  expect "$STDERR" toContain "Failed to connect to localhost port $PORT1: Connection refused"
}

@pending.no_arguments() {
  :
}
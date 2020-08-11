# Just show the behavior of curl when it fails
@example.curl_error_when_website_isnt_running_locally() {
  refute run curl -i http://localhost:$PORT1
  expect "$STDOUT" toBeEmpty
  expect "$STDERR" toContain "Failed to connect to localhost port $PORT1: Connection refused"
}
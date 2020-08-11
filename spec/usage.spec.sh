import @cgi-server

@example.no_arguments_fails_with_helpful_documentation() {
  refute run cgi-server
  expect "$STDOUT" toBeEmpty
  expect "$STDERR" toContain "Missing"
  expect "$STDERR" toContain "cgi-server"
  expect "$STDERR" toContain "Usage"
}

@example.dash_h_succeeds_with_helpful_documentation() {
  assert run cgi-server -h
  expect "$STDERR" toBeEmpty
  expect "$STDOUT" toContain "cgi-server"
  expect "$STDOUT" toContain "Usage"
}

@example.dash_dash_help_succeeds_with_helpful_documentation() {
  assert run cgi-server --help
  expect "$STDERR" toBeEmpty
  expect "$STDOUT" toContain "cgi-server"
  expect "$STDOUT" toContain "Usage"
}
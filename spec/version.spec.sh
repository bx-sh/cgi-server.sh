import @cgi-server

@example.show_version() {
  expect { cgi-server --version } toMatch 'cgi-server version [0-9]+\.[0-9\+\.[0-9]+'
}
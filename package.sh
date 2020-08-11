name cgi-server

description "🔌 Connecting BASH to the web!"

version "$( grep VERSION= cgi-server.sh | sed 's/.*VERSION=\(.*\)/\1/' | sed 's/"//g' )"

main cgi-server.sh

exclude spec/ *.cgi

devDependency spec
devDependency assert
devDependency expect
devDependency run-command
devDependency map

# Currently unsupported
# devDependency command: curl

# TODO: Configure multi-bash to be more configurable.
#       I'd like to test this against a variety of docker images.
#
# devDependency multi-bash
# devDependency bx
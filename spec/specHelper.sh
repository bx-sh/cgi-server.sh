. "$( bx BxSH )"

PACKAGE_PATH=.:packages

# These are the ports which the specs use.
# If these conflict with local ports in use,
# change them or the specs will fail.
PORT1=8080
PORT2=4242
HOST=127.0.0.1

import @assert
import @expect/all
import @run-command
. "$( bx BxSH )"

PACKAGE_PATH=.:packages

# These are the ports which the specs use.
# If these conflict with local ports in use,
# change them or the specs will fail.
PORT1=4242
PORT2=8080

import @assert
import @expect/all
import @run-command
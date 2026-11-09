#!/bin/sh
# The JavaScript reference interpreter has been retired.
# No fallback is permitted: use the native S0/S1 executable.
echo 'Triad: the foreign-language reference oracle is no longer available.' >&2
echo 'Run ./bin/triad --logic program.triad or sh conformance/logic/run.sh.' >&2
exit 2

#!/bin/bash
rm trace.log
rm trace.def
dub run --build=profile
dub run profdump -- -b trace.log > trace.log.b
dub run profdump -- -f --dot --threshold 1 trace.log trace.log.dot
xdot trace.log.dot

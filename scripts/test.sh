#!/bin/bash
# Activate virtal env
. /appenv/bin/activate

# Install app test reqs.
pip install -r requirements_test.txt

# Run test.sh args
exec $@
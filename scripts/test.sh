#!/bin/bash
# Activate virtal env
. /appenv/bin/activate


# Download requirements to build cache
pip download -d /build -r requirements_test.txt --no-input

# Install app test reqs.
pip install --no-index -f /build -r requirements_test.txt

# Run test.sh args
exec $@
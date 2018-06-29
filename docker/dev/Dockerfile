FROM alexkoepke/todobackend-base:latest
LABEL  maintainer="Alex Koepke <akoepke@usdigitalpartners.com>"

# Install dev/build dependencies
RUN apt-get update && \
    apt-get install -qy python-dev libmysqlclient-dev

# Activate virtual environment and install wheel support
RUN . /appenv/bin/activate && \
    pip install wheel --upgrade

# PIP env variables (note: must be set after installing wheel)
ENV WHEELHOUSE=/wheelhouse PIP_WHEEL_DIR=/wheelhouse PIP_FIND_LINKS=/wheelhouse XDG_CACHE_HOME=/cache

VOLUME [ "/wheelhouse", "/build", "/reports" ]

COPY scripts/test.sh /usr/local/bin/test.sh
RUN chmod +x /usr/local/bin/test.sh

# Set defaults fro entrypoint and command string (overwrites entrypoint of the parent base image (double note: parent script is still availabe if we need it))
ENTRYPOINT [ "test.sh" ]
CMD [ "python", "manage.py", "test", "--noinput" ]

# Add application source
COPY src /application
WORKDIR /application
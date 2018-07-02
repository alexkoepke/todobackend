FROM alexkoepke/todobackend-base:latest
LABEL  maintainer="Alex Koepke <akoepke@usdigitalpartners.com>"

# Copy application artifacts
COPY target /wheelhouse

# Install application
RUN . /appenv/bin/activate && \
    pip install --no-index -f /wheelhouse todobackend && \
    rm -rf /wheelhouse
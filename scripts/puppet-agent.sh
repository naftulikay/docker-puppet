#!/bin/bash

# load environment variables
source /etc/container_environment.sh

# default puppet master port is 8410
test -z "$PUPPETMASTER_TCP_PORT" && export PUPPETMASTER_TCP_PORT="8410"

puppet_agent_args="--no-daemonize"

# if there is a puppet master host defined, append the server and port parameters
if [ ! -z "$PUPPET_MASTER_TCP_HOST" ]; then 
    puppet_agent_args="$puppet_agent_args --server \"$PUPPETMASTER_TCP_HOST\" --masterport $PUPPETMASTER_TCP_PORT"
fi

# start the puppet agent in foreground with given arguments
exec puppet agent $puppet_agent_args

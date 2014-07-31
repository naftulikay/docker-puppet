#!/bin/bash

# load environment variables
source /etc/container_environment.sh

# default puppet master port is 8140
test -z "$PUPPETMASTER_TCP_PORT" && export PUPPETMASTER_TCP_PORT="8140"

puppet_agent_args="--no-daemonize"

# if there is a puppet environment defined, append the environment parameter
if [ ! -z "$PUPPET_AGENT_ENVIRONMENT" ]; then
    puppet_agent_args="$puppet_agent_args --environment $PUPPET_AGENT_ENVIRONMENT"
fi

# if there is a puppet master host defined, append the server and port parameters
if [ ! -z "$PUPPETMASTER_TCP_HOST" ]; then 
    puppet_agent_args="$puppet_agent_args --server $PUPPETMASTER_TCP_HOST --masterport $PUPPETMASTER_TCP_PORT"
fi

# start the puppet agent in foreground with given arguments
exec puppet agent $puppet_agent_args

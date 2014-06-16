#!/bin/bash

# load environment variables
source /etc/container_environment.sh

function write_puppet_config () {
    read -d '' puppet_config <<EOF
[agent]
server=$1
masterport=$2
EOF
    
    echo -e "$puppet_config" >> /etc/puppet/puppet.conf
}

# default puppet master port is 8410
test -z "$PUPPET_MASTER_TCP_PORT" && export PUPPET_MASTER_TCP_PORT="8410"

# if there is a puppet master host defined, rewrite the config to match
if [ ! -z "$PUPPET_MASTER_TCP_HOST" ]; then 
    write_puppet_config "$PUPPET_MASTER_TCP_HOST" "$PUPPET_MASTER_TCP_PORT"
fi

exec puppet agent --no-daemonize

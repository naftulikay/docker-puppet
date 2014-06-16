docker-puppet
=============

A wondrous base image for Puppet-automated Docker instances.

# Built on Phusion's baseimage

Most Docker base images don't include a proper init system, system logging, or simple facilities like SSH.

# Build it From Scratch

# Ready for a Puppet Master 

# SSH Out of the Box

Simply copy over your public key(s) in the form of an `authorized_keys` file to the `root` user, then SSH
right into the Docker container:

    sudo docker cp ~/.ssh/authorized_keys 

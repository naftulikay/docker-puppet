FROM phusion/baseimage:0.9.10
MAINTAINER Naftuli Tzvi Kay <rfkrocktk@gmail.com>

ENV HOME /root
ENV LANG en_US.UTF-8
RUN locale-gen en_US.UTF-8

# Install tools
RUN apt-get update -q 2 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y ca-certificates > /dev/null

# Install Puppet Labs Repository for Trusty
RUN curl -o puppet.deb -s https://apt.puppetlabs.com/puppetlabs-release-trusty.deb && \
    DEBIAN_FRONTEND=noninteractive dpkg -i puppet.deb > /dev/null \
    && rm puppet.deb

# Install the latest stable Puppet client
RUN apt-get update -q 2 && DEBIAN_FRONTEND=noninteractive \
    apt-get install --yes -q 2 puppet >/dev/null

# Install runit startup script
ADD scripts/puppet-agent.sh /etc/service/puppet/run
RUN chmod +x /etc/service/puppet/run

# Use the runit init system.
CMD ["/sbin/my_init"]

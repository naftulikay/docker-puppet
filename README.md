docker-puppet
=============

A wondrous base image for Puppet-automated Docker instances.

Rather than write 10<sup>n</sup> disparate `Dockerfile`s which are tedious to maintain, difficult to test,
and prone to errors, why not just [automate all the things](http://i.imgur.com/IK8imUY.jpg) with Puppet? 
This Docker container makes it trivial to setup Puppet-enabled Docker images in no time, flat.

## Built on Phusion's Excellent Docker baseimage

Most Docker base images don't include a proper init system, system logging, or simple facilities like SSH.
[Phusion](https://phusion.nl) provides an excellent Docker [baseimage](https://github.com/phusion/baseimage-docker) 
container based on Ubuntu 14.04 LTS which fixes all of these problems. This means that `syslog` works as
planned, `cron` jobs actually run, and you can `ssh` into the machine with a only a dash of extra
[configuration](https://github.com/phusion/baseimage-docker#login-to-the-container-via-ssh).

## Get Started, Right Now

Stop messing around. Install this and start running things. 

    $ sudo docker pull rfkrocktk/puppet

Let's start up a new Docker Puppet container which looks for a Puppet Master at `ultramaster.example.com`,
exposes port 9999 to the host operating system, and shares its SSL certificates to the host filesystem at
`/var/lib/docker/dockercontainer/puppet/ssl`. We'll give it a hostname of `dockerduck`, the newest superhero
in our cosmic arsenal:

    $ sudo docker --name dockerduck --hostname dockerduck -e PUPPETMASTER_TCP_HOST=ultramaster.example.com \
        -v /var/lib/docker/dockercontainer/puppet/ssl:/var/lib/puppet/ssl rfkrocktk/puppet

Next, connect to your Puppet Master and validate the certificate fingerprint for `dockerduck`:

    $ ssh ultramaster
    ultramaster:~ $ puppet cert list
    dockerduck (FD:E7:41:C9:2C:B7:5C:27:11:0C:8F:9C:1D:F6:F9:46)

Wow, it's totally the right certificate. Sign it, and then `dockerduck` will be successfully connected
to the Puppet Master `ultramaster`:

    ultramaster:~ $ puppet cert sign dockerduck

The next time that `dockerduck` connects to `ultramaster`, its connection will be approved and 
the Puppet Master will serve configuration down to it. Congratulations, you've just setup a 
Puppet Client and with a Puppet Master, only this Puppet Client is a shreddable Docker container!

### Puppet Docker Configuration to Configure Docker Puppet

I heard you like using Docker so we put Puppet Docker on your Puppet host so you can... well,
nevermind. This whole thing is getting too recursive for my brain.

The following requires the [garethr/docker](https://forge.puppetlabs.com/garethr/docker) Puppet
module for managing Docker.

Behold, awesome Puppet configuration for managing your Docker Puppet images on your actual hosts:

**manifests/dockerhost.pp**

```
node dockerhost {
    include 'docker'

    docker::image { 'rfkrocktk/puppet': }
    
    docker::run { 'dockercontainer':
        image     => 'rfkrocktk/puppet',
        ports    => [3306],
        hostname => 'dockercontainer',
        env      => ['PUPPETMASTER_TCP_HOST=ultramaster.example.com'],
        volumes  => ['/var/lib/docker/dockercontainer/ssl:/var/lib/puppet/ssl']
    }
}
```

**manifests/dockercontainer.pp**

```
node dockercontainer {
    package { 'mysql-server': 
        ensure => present
    }
}
```

The above example installs a Docker Puppet container on `dockerhost` and will also configure
the `dockercontainer` Docker container running Puppet to install MySQL. How awesome is that?

## Advanced Configuration

You can also do all the advanced things if you want, namely environment configuration, building
from source, and configuring important mount points.

### Building from Source

Building the Docker image is fairly simple. First, clone the repository:

    $ git clone https://github.com/rfkrocktk/docker-puppet.git

Next, `cd` into the repository and build it:

    $ cd docker-puppet
    $ sudo docker build --tag rfkrocktk/puppet .

Docker will build the image and you'll now see it available:

    $ sudo docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
    rfkrocktk/puppet    latest              1da181a318e7        38 minutes ago      454.6 MB

### Environment Variables

We currently support the following environment variables:

| Variable Name         | Required  | Description                                                 |
|-----------------------|-----------|-------------------------------------------------------------|
|`PUPPETMASTER_TCP_HOST`| _kind of_ | The TCP host of the Puppet Master. (DNS name or IP address) |
|`PUPPETMASTER_TCP_PORT`| nope      | The TCP port number of the Puppet Master. Defaults to 8140. |

Though `PUPPETMASTER_TCP_HOST` isn't _exactly_ required, it's a pretty good idea to set this to your
Puppet Master's host address. If you don't, the Puppet client won't really do anything for now. We
have plans to add some manual `puppet apply` `cron` job for masterless configurations, but be patient
or submit it in a pull-request.

### Volume Mount Points

We haven't done too much in the area of highly-customized Docker volume locations, but there are a few
interesting locations which you'll probably want to mount outside of your container to be able to 
automate moar things.

| Internal Location     | Description                                                                                  |
|-----------------------|----------------------------------------------------------------------------------------------|
| `/var/log/puppet`     | You know, where the logs are kept and stuff. Also see syslog.                                |
| `/var/lib/puppet/ssl` | This is where all SSL certificates will be stored as they are generated by the Puppet Agent. |

You'll probably be most interested in `/var/lib/puppet/ssl`, as you can thus even keep your Docker Puppet
containers' private keys in your Puppet configuration and deploy them, speeding up deployment by not requiring
you to manually sign all of your Docker Puppet containers' keys. Again, [automate all the things](http://i.imgur.com/IK8imUY.jpg).

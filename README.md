# iea-server
Server software stack for NOAA's Integrated Ecosystem Assessment (IEA) program, containerized using Docker

Contents:
<!-- 
To update table of contents run: `cat README.md | ./gh-md-toc -` 
Uses: https://github.com/ekalinin/github-markdown-toc
-->

* [Server software](#server-software)
* [Shell into server](#shell-into-server)
* [Install docker, docker-compose](#install-docker-docker-compose)
   * [docker](#docker)
   * [docker-compose](#docker-compose)
   * [OLD: Move docker storage](#old-move-docker-storage)
   * [update 2019-12-17](#update-2019-12-17)
* [Build containers](#build-containers)
   * [Test webserver](#test-webserver)
   * [ships4whales](#ships4whales)
   * [DNS manage *.ships4whales.org](#dns-manage-ships4whalesorg)
   * [rstudio-shiny](#rstudio-shiny)
* [Docker maintenance](#docker-maintenance)
   * [Push docker image](#push-docker-image)
   * [Develop on local host](#develop-on-local-host)
   * [Operate on all docker containers](#operate-on-all-docker-containers)
   * [Inspect docker logs](#inspect-docker-logs)
* [TODO](#todo)


## Server software

- Content management system:
  - [WordPress](https://wordpress.com)<br>
    **ships4whales.org**
  - [MySQL](https://www.mysql.com/)<br>
    ships4whales.org **:3306**
- Analytical apps:
  - [Shiny](https://shiny.rstudio.com)<br>
    **shiny.** ships4whales.org
  - [RStudio](https://rstudio.com/products/rstudio/#rstudio-server)<br>
    **rstudio.** ships4whales.org
- Spatial engine:
  - [GeoServer](http://geoserver.org)<br>
    **gs.** ships4whales.org
  - [PostGIS](https://postgis.net)<br>
    ships4whales.org **:5432**
- Containerized using:
  - [docker](https://docs.docker.com/engine/installation/)
  - [docker-compose](https://docs.docker.com/compose/install/)
  - [nginx-proxy](https://github.com/jwilder/nginx-proxy)

## Shell into server

1. Connect to UCSB VPN via Secure Pulse
1. SSH, eg for Ben:
    ```bash
    
    ssh -i ~/.ssh/id_rsa.pem bbest@ec2-34-220-29-172.us-west-2.compute.amazonaws.com
    ```

## Install docker, docker-compose

Using Ubuntu on Amazon EC2 with 40 GB Amazon EBS volume at `/data` (where linked `/var/lib/docker`) and connecting to Amazon RDS Postgres.

### docker

Reference:

- [How To Install and Use Docker on Ubuntu 18.04 | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04)

```bash
# confirm architecture
uname -a
# Linux ip-10-242-0-52 4.15.0-1051-aws #53-Ubuntu SMP Wed Sep 18 13:35:53 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux

# update packages
sudo apt update

# install a few prerequisite packages which let apt use packages over HTTPS
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# add the GPG key for the official Docker repository to your system
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# add the Docker repository to APT sources
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

# update the package database with the Docker packages from the newly added repo:
sudo apt update

# make sure you are about to install from the Docker repo instead of the default Ubuntu repo
apt-cache policy docker-ce

# install Docker
sudo apt install docker-ce

# Docker should now be installed, the daemon started, and the process enabled to start on boot. 
# check that it’s running
sudo systemctl status docker

# If you want to avoid typing sudo whenever you run the docker command, 
# add your username to the docker group
sudo usermod -aG docker ${USER}

# to apply the new group membership, log out of the server and back in, or type the following:
sudo su - ${USER}
```

### docker-compose

References:

- [How To Install Docker Compose on Ubuntu 18.04 | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-18-04)
- [Install Docker Compose | Docker Documentation](https://docs.docker.com/compose/install/)

```bash
# download current stable release
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# apply executable permissions to the binary
sudo chmod +x /usr/local/bin/docker-compose

# test the installation
docker-compose --version
```

### OLD: Move docker storage

Because ran out of room in root drive `/` when subsequently install images:

```bash
df -h
```

```
Filesystem      Size  Used Avail Use% Mounted on
udev            3.8G     0  3.8G   0% /dev
tmpfs           763M  800K  762M   1% /run
/dev/nvme1n1p1  7.7G  5.8G  2.0G  76% /
tmpfs           3.8G     0  3.8G   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           3.8G     0  3.8G   0% /sys/fs/cgroup
/dev/loop1       18M   18M     0 100% /snap/amazon-ssm-agent/1480
/dev/nvme0n1     50G   84M   50G   1% /data
/dev/loop4       90M   90M     0 100% /snap/core/8213
/dev/loop0       90M   90M     0 100% /snap/core/8268
tmpfs           763M     0  763M   0% /run/user/1002
```

Note: 50GB volume mounted on `/data`.

So moved to `/var/lib/docker` to `/data/.`:

```bash
sudo systemctl stop docker
sudo mv /var/lib/docker /data/docker
sudo ln -s /data/docker /var/lib/docker
sudo systemctl start docker
```

### update 2019-12-17

```
bbest@ip-10-242-0-20:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            3.8G     0  3.8G   0% /dev
tmpfs           763M  860K  762M   1% /run
/dev/nvme1n1p1   49G  1.8G   47G   4% /
tmpfs           3.8G     0  3.8G   0% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           3.8G     0  3.8G   0% /sys/fs/cgroup
/dev/loop0       90M   90M     0 100% /snap/core/7713
/dev/loop1       18M   18M     0 100% /snap/amazon-ssm-agent/1480
tmpfs           763M     0  763M   0% /run/user/1003
```

## Build containers

### Test webserver

Reference:

- [How To Run Nginx in a Docker Container on Ubuntu 14.04 | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-run-nginx-in-a-docker-container-on-ubuntu-14-04)

```bash
docker run --name nginx -p 80:80 -d nginx

# confirm working
docker ps
curl http://localhost
```

returns:
```
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

### ships4whales

References:

- [Quickstart: Compose and WordPress | Docker Documentation](https://docs.docker.com/compose/wordpress/)
- [docker-compose.yml · kartoza/docker-geoserver](https://github.com/kartoza/docker-geoserver/blob/master/docker-compose.yml)
- [How To Install WordPress With Docker Compose | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-docker-compose)

You will need access to the following secure files in Google Docs:

- [tech-aws notes | ship-strike](https://docs.google.com/document/d/1-iAlUOVzjw7Ejdlvmt2jVWdG6XhFqm13gWS3hZJ9mDc/edit#)
- [amazon_rds.yml](https://drive.google.com/open?id=1eddyoeFO5bslUakzireH1NFh8UsGBfEY)


First, you will create the environment `.env` file to specify password and host:

- NOTE: Set `PASSWORD`, substituting "CHANGEME" with password from [tech-aws notes | ship-strike - Google Docs](https://docs.google.com/document/d/1-iAlUOVzjw7Ejdlvmt2jVWdG6XhFqm13gWS3hZJ9mDc/edit#). The [docker-compose.yml](https://github.com/BenioffOceanInitiative/s4w-docker/blob/master/docker-compose.yml) uses [variable substitution in Docker](https://docs.docker.com/compose/compose-file/#variable-substitution).

```bash
# get latest docker-compose files
git clone https://github.com/BenioffOceanInitiative/s4w-docker.git
cd ~/s4w-docker

# set environment variables
echo "PASSWORD=CHANGEME" > .env
echo "HOST=ships4whales.org" >> .env
cat .env

# launch
docker-compose up -d

# OR update
git pull; docker-compose up -d

# OR build if Dockerfile updated in subfolder
git pull; docker-compose up --build -d

# OR reload
docker-compose restart

# OR stop
docker-compose stop
```

### DNS manage *.ships4whales.org

- Using new public ip address: `34.220.29.172`

- DNS matched to ships4whales.org via [Google Domains]( https://domains.google.com/m/registrar/ships4whales.org/dns), plus the following subdomains added under **Custom resource records** with Type:**A**, Data:**34.220.29.172** and Name:

  - **wp**
  - **gs**
  - **rstudio**
  - **shiny**

### rstudio-shiny 

Haven't figured out how to RUN these commands after user admin is created in rstudio-shiny container.

1. Setup **permissions and shortcuts** for admin in rstudio.
    
    After logging into rstudio.ships4hwales.org, to go to Terminal window and run:
    
    ```bash
    sudo su -
    ln -s /srv/shiny-server /home/admin/shiny-apps
    ln -s /var/log/shiny-server /home/admin/shiny-logs
    chown -R admin /srv/shiny-server
    ```
  
1. Copy [**amazon_rds.yml**](https://drive.google.com/open?id=1eddyoeFO5bslUakzireH1NFh8UsGBfEY) into `/srv/shiny-server/.rds_amazon.yml` for connecting to the Amazon PostgreSQL/PostGIS relational database service (RDS).

1. Go to shiny-apps/shiny_ships and run in rstudio to generate cache which otherwise times out when visiting site shiny.ships4whales.org/shiny_ships.

## Docker maintenance

### Push docker image

Since rstudio-shiny is a custom image `bdbest/rstudio-shiny:s4w`, I [docker-compose push](https://docs.docker.com/compose/reference/push/) to [bdbest/rstudio-shiny:s4w | Docker Hub](https://hub.docker.com/layers/bdbest/rstudio-shiny/s4w/images/sha256-134b85760fc6f383309e71490be99b8a50ab1db6b0bc864861f9341bf6517eca).

```bash
# login to docker hub
docker login --username=bdbest

# push updated image
docker-compose push
```

### Develop on local host

Note setting of `HOST` to `local` vs `ships4whales.org`:

```bash
# get latest docker-compose files
git clone https://github.com/BenioffOceanInitiative/s4w-docker.git
cd ~/s4w-docker

# set environment variables
echo "PASSWORD=CHANGEME" > .env
echo "HOST=local" >> .env
cat .env

# launch
docker-compose up -d

# see all containers
docker ps -a
```

Then visit http://localhost or http://rstudio.localhost.

TODO: try migrating volumes in /var/lib/docker onto local machine.


### Operate on all docker containers

```bash
# stop all running containers
docker stop $(docker ps -q)

# remove all containers
docker rm $(docker ps -aq)

# remove all image
docker rmi $(docker images -q)

# remove all stopped containers
docker container prune
```

### Inspect docker logs

To tail the logs from the Docker containers in realtime, run:

```bash
docker-compose logs -f

docker inspect rstudio-shiny
```

## TODO

- try test migration of volumes in /data/docker on a local machine
- add https
  - "Step 4 — Obtaining SSL Certificates and Credentials" in [How To Install WordPress With Docker Compose | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-docker-compose#step-4-%E2%80%94-obtaining-ssl-certificates-and-credentials)
  - docker-letsencrypt-nginx-proxy-companion:
  - [Hosting multiple SSL-enabled sites with Docker and Nginx | Serverwise](https://blog.ssdnodes.com/blog/host-multiple-ssl-websites-docker-nginx/)
  - cron job to renew
- add phpmyadmin for web interface to mysql wordpress database
  - [Setting up WordPress with Docker - Containerizers](https://cntnr.io/setting-up-wordpress-with-docker-262571249d50)

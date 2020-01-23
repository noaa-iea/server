# iea-server
Server software stack for NOAA's Integrated Ecosystem Assessment (IEA) program, containerized using Docker

Contents:
<!-- 
To update table of contents run: `cat README.md | ./gh-md-toc -` 
Uses: https://github.com/ekalinin/github-markdown-toc
-->

* [Server software](#server-software)
* [Shell into server](#shell-into-server)
* [Create Server](#create-server)
* [Install docker, docker-compose](#install-docker-docker-compose)
   * [docker](#docker)
   * [docker-compose](#docker-compose)
* [Build containers](#build-containers)
   * [Test webserver](#test-webserver)
* [Setup domain iea-ne.us](#setup-domain-iea-neus)
   * [ships4whales](#ships4whales)
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
    **iea-ne.us**
  - [MySQL](https://www.mysql.com/)<br>
    iea-ne.us **:3306**
- Analytical apps:
  - [Shiny](https://shiny.rstudio.com)<br>
    **shiny.** iea-ne.us
  - [RStudio](https://rstudio.com/products/rstudio/#rstudio-server)<br>
    **rstudio.** iea-ne.us
- Spatial engine:
  - [GeoServer](http://geoserver.org)<br>
    **gs.** iea-ne.us
  - [PostGIS](https://postgis.net)<br>
    iea-ne.us **:5432**
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

## Create Server

Created droplet at https://digitalocean.com with ben@ecoquants.com (Google login):

- Choose an image : Distributions : Marketplace : 
  - **Docker** by DigitalOcean VERSION 18.06.1 OS Ubuntu 18.04
- Choose a plan : Standard : 
  - **$20 /mo** $0.030 /hour
  - 4 GB / 2 CPUs
  - 80 GB SSD disk
  - 4 TB transfer
- Choose a datacenter region :
  - **San Francisco** (New York currently experiencing issues)
- Authentication :
  - **One-time password**
    Emails a one-time root password to you (less secure)
- How many Droplets?
  - **1  Droplet**
- Choose a hostname :
  - **docker-iea-ne.us**

Emailed:

> Your new Droplet is all set to go! You can access it using the following credentials:
> 
> Droplet Name: docker-iea-ne.us
> IP Address: 64.225.118.240
> Username: root
> Password: acaee0eca8104652ce35d830ba

Saved on my Mac to a local file:

```bash
ssh root@64.225.118.240
# enter password from above
# you will be asked to change it upon login
```

```bash
echo S3cr!tpw > ~/private/password_docker-iea-ne.us
cat ~/private/password_docker-iea-ne.us
```

## Install docker, docker-compose

Since we used an image with `docker` and `docker-compose` already installed, we can skip this step.

References:

- [How To Install and Use Docker on Ubuntu 18.04 | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04) for more.

### docker

```bash
# confirm architecture
uname -a
# Linux docker-iea-ne 4.15.0-58-generic #64-Ubuntu SMP Tue Aug 6 11:12:41 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux

# update packages
sudo apt update

# check that it’s running
systemctl status docker
```

### docker-compose

References:

- [How To Install Docker Compose on Ubuntu 18.04 | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-18-04)
- [Install Docker Compose | Docker Documentation](https://docs.docker.com/compose/install/)

```bash
# test the installation
docker-compose --version
# docker-compose version 1.22.0, build f46880fe
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

## Setup domain iea-ne.us

- Bought domain **iea-ne.us** for **$12/yr** with account bdbest@gmail.com.

- DNS matched to server IP `64.225.118.240` to domain **iea-ne.us** via [Google Domains]( https://domains.google.com/m/registrar/iea-ne.us/dns), plus the following subdomains added under **Custom resource records** with:

- Type: **A**, Data:**64.225.118.240** and Name:
  - **@**
  - **wp**
  - **gs**
  - **rstudio**
  - **shiny**
- Name: **www**, Type: **CNAME**, Data:**iea-ne.us**

### ships4whales

References:

- [Quickstart: Compose and WordPress | Docker Documentation](https://docs.docker.com/compose/wordpress/)
- [docker-compose.yml · kartoza/docker-geoserver](https://github.com/kartoza/docker-geoserver/blob/master/docker-compose.yml)
- [How To Install WordPress With Docker Compose | DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-docker-compose)

You will need access to the following secure files in Google Docs:

- [tech-aws notes | ship-strike](https://docs.google.com/document/d/1-iAlUOVzjw7Ejdlvmt2jVWdG6XhFqm13gWS3hZJ9mDc/edit#)
- [amazon_rds.yml](https://drive.google.com/open?id=1eddyoeFO5bslUakzireH1NFh8UsGBfEY)


First, you will create the environment `.env` file to specify password and host:

- NOTE: Set `PASSWORD`, substituting "S3cr!tpw" with password from [tech-aws notes | ship-strike - Google Docs](https://docs.google.com/document/d/1-iAlUOVzjw7Ejdlvmt2jVWdG6XhFqm13gWS3hZJ9mDc/edit#). The [docker-compose.yml](https://github.com/BenioffOceanInitiative/s4w-docker/blob/master/docker-compose.yml) uses [variable substitution in Docker](https://docs.docker.com/compose/compose-file/#variable-substitution).

```bash
# get latest docker-compose files
git clone https://github.com/marinebon/iea-server.git
cd ~/iea-server

# set environment variables
echo "PASSWORD=S3cr!tpw" > .env
echo "HOST=iea-ne.us" >> .env
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

1. Go to shiny-apps/shiny_ships and run in rstudio to generate cache which otherwise times out when visiting site shiny.iea-ne.us/shiny_ships.

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

Note setting of `HOST` to `local` vs `iea-ne.us`:

```bash
# get latest docker-compose files
git clone https://github.com/BenioffOceanInitiative/s4w-docker.git
cd ~/s4w-docker

# set environment variables
echo "PASSWORD=S3cr!tpw" > .env
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

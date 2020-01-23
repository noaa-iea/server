FROM axiom/docker-erddap:latest

# install erddap config files
WORKDIR /usr/local/tomcat/content/erddap
COPY setup.xml setup.xml
COPY datasets.xml datasets.xml

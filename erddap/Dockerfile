FROM axiom/docker-erddap:latest

# Java options
COPY setenv.sh ${CATALINA_HOME}/bin/setenv.sh

# install erddap config files
WORKDIR /usr/local/tomcat/content/erddap
COPY setup.xml setup.xml
COPY datasets.xml datasets.xml

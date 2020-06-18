FROM rocker/geospatial:latest
MAINTAINER "Ben Best" ben@ecoquants.com

# install extra packages 
RUN install2.r --error \
  # for shiny:
  Rcpp \
  httpuv \
  shiny \
  # for app: https://github.com/BenioffOceanInitiative/ships4whales-app/blob/master/shiny_ships/app.R
  dbplyr \
  fs \
  glue \
  gstat \
  here \
  leaflet \
  plotly \
  DT \
  rintrojs \
  scales \
  units \
  RColorBrewer \
  RPostgreSQL \
  RPostgres \
  shinydashboard \
  shinythemes \
  plumber \
  # already included: https://tidyverse.tidyverse.org
  #   dplyr
  #   lubridate
  # already included: https://github.com/rocker-org/geospatial
  #   maptools
  #   raster
  #   rgdal
  #   rgeos
  #   sf
  #   sp
  #   tmap
  
# add Shiny, per https://github.com/rocker-org/rocker/issues/235#issuecomment-299036810
RUN export ADD=shiny && bash /etc/cont-init.d/add

# install Shiny apps
#RUN cd /srv && rm -rf shiny-server && \
RUN mkdir /share/github && cd /share/github && \
  git clone https://github.com/marinebon/iea-uploader.git && \
  ln -s iea-uploader /srv/shiny-server/uploader && \
  git clone https://github.com/marinebon/edna-vis.git && \
  ln -s shiny /srv/shiny-server/edna-vis

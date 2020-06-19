# `etc/cont-init.d/add: No such file or directory` with 4.0.0
#   https://github.com/rocker-org/rocker-versioned/issues/219#issuecomment-633680843
FROM rocker/geospatial:3.6.3
MAINTAINER "Ben Best" ben@ecoquants.com

# install extra packages 
RUN install2.r --error \
  dbplyr \
  DT \
  fs \
  glue \
  gstat \
  here \
  httpuv \
  leaflet \
  plotly \
  plumber \
  RColorBrewer \
  Rcpp \
  rintrojs \
  RPostgreSQL \
  RPostgres \
  scales \
  shiny \
  shinydashboard \
  shinymanager \
  shinythemes \
  units
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

RUN mkdir -p /share/github
WORKDIR /share/github

RUN if [ ! -d "iea-uploader" ] ; then \
  git clone https://github.com/marinebon/iea-uploader.git ; \
  ln -s iea-uploader /srv/shiny-server/uploader ; fi \
RUN if [ ! -d "edna-vis" ] ; then \
  git clone https://github.com/marinebon/edna-vis.git ; \
  ln -s edna-vis /srv/shiny-server/edna-vis ; fi \

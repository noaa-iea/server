# install Shiny apps
RUN mkdir /share/github && cd /share/github && \
  git clone https://github.com/marinebon/iea-uploader.git && \
  ln -s iea-uploader /srv/shiny-server/uploader && \
  git clone https://github.com/marinebon/edna-vis.git && \
  ln -s shiny /srv/shiny-server/edna-vis
# install infographic site from Github
RUN apt-get update; apt-get --assume-yes install git
RUN mkdir /share/github && cd /share/github && \
  git clone https://github.com/marinebon/iea-ne_info.git \
  mv /usr/share/nginx/html /usr/share/nginx/html_0 \
  ln -s iea-ne_info /usr/share/nginx/html
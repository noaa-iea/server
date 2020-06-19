FROM nginx:stable

COPY docker-start.sh /docker-start.sh

RUN apt-get update && apt-get --assume-yes install git

RUN mkdir -p /share/github

ENV repo=iea-ne_info
RUN if [ ! -d "/share/github/$repo" ] ; then \
  cd /share/github ; \
  git clone https://github.com/marinebon/$repo.git ; \
  mv /usr/share/nginx/html /usr/share/nginx/html_0 ; \
  ln -s $repo /usr/share/nginx/html ; \
fi

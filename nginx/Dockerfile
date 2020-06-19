FROM nginx:stable

RUN apt-get update && apt-get --assume-yes install git

RUN mkdir -p /share/github

ENV repo=iea-ne_info
RUN if [ ! -d "/share/github/$repo" ] ; then \
  git clone https://github.com/marinebon/$repo.git /share/github/$repo ; \
  mv /usr/share/nginx/html /usr/share/nginx/html_0 ; \
  ln -s /share/github/$repo /usr/share/nginx/html ; \
fi

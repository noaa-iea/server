FROM nginx:stable



# install infographic site from Github
RUN apt-get update; apt-get --assume-yes install git
RUN cd /usr/share/nginx && rm -rf html && \
    git clone https://github.com/marinebon/iea-ne_info.git html

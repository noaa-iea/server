[ ! -d "/share/github" ] && mkdir /share/github
cd /share/github

repo=iea-ne_info
if [ ! -d "/share/github/$repo" ]
then 
  git clone https://github.com/marinebon/$repo.git
  mv /usr/share/nginx/html /usr/share/nginx/html_0
  ln -s iea-ne_info /usr/share/nginx/html
fi
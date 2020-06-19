if [ ! -d "/share/github" ]
then
  echo "mkdir /share/github"
  mkdir /share/github
else
  echo "/share/github already exists"
fi

repo=iea-ne_info
if [ ! -d "/share/github/$repo" ]
then 
  cd /share/github
  git clone https://github.com/marinebon/$repo.git
  mv /usr/share/nginx/html /usr/share/nginx/html_0
  ln -s $repo /usr/share/nginx/html
else
  echo "/share/github/$repo already exists"
fi

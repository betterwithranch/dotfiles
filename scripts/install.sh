# /bin/bash
sudo rm /usr/bin/hack
sudo rm /usr/bin/ship

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/../
DIR="$( cd "$( dirname $DIR )/.." && pwd)"/usr/bin
sudo ln -s $DIR/hack /usr/bin/hack
chmod +x /usr/bin/hack
sudo ln -s $DIR/ship /usr/bin/ship
chmod +x /usr/bin/ship

ln -s $PWD/heroku/deploy /usr/bin/herokudeploy

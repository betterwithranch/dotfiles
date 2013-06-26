# /bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/../
DIR="$( cd "$( dirname $DIR )/.." && pwd)"/usr/bin
sudo ln -s $DIR/hack /usr/bin/hack
chmod +x /usr/bin/hack
sudo ln -s $DIR/ship /usr/bin/ship
chmod +x /usr/bin/ship

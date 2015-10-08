#!/bin/bash

# Source env variables including node version
. /opt/elasticbeanstalk/env.vars

function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}

# Download and extract desired node.js version
echo "checking node..."
OUT=$( [ ! -d "/opt/elasticbeanstalk/node-install" ] && echo "trying to install node $NODE_VER"   && mkdir /opt/elasticbeanstalk/node-install ; cd /opt/elasticbeanstalk/node-install/ && \
  wget -nc http://nodejs.org/dist/v$NODE_VER/node-v$NODE_VER-linux-$ARCH.tar.gz && \
  tar --skip-old-files -xzpf node-v$NODE_VER-linux-$ARCH.tar.gz) || error_exit "Failed to UPDATE node version. $OUT" $?.
echo $OUT


# UNCOMMENT to update npm, otherwise will be updated on instance init or rebuild
rm -f /opt/elasticbeanstalk/node-install/npm_updated

echo $OUT

# Create symlinks
if [ ! -L /usr/bin/node ]; then
  ln -s /opt/elasticbeanstalk/node-install/node-v$NODE_VER-linux-$ARCH/bin/node /usr/bin/node
fi

if [ ! -L /usr/bin/npm ]; then
ln -s /opt/elasticbeanstalk/node-install/node-v$NODE_VER-linux-$ARCH/bin/npm /usr/bin/npm
fi

if [ ! -L /usr/bin/node-gyp ]; then
ln -s /opt/elasticbeanstalk/node-install/node-v$NODE_VER-linux-$ARCH/lib/node_modules/npm/node_modules/.bin/node-gyp /usr/bin/node-gyp
fi

echo "checking npm..."
if [ ! -f "/opt/elasticbeanstalk/node-install/npm_updated" ]; then
cd /opt/elasticbeanstalk/node-install/node-v$NODE_VER-linux-$ARCH/bin/ && /opt/elasticbeanstalk/node-install/node-v$NODE_VER-linux-$ARCH/bin/npm update npm -g
touch /opt/elasticbeanstalk/node-install/npm_updated
echo "YAY! Updated global NPM version to `npm -v`"
else
  echo "Skipping NPM -g version update. To update, please uncomment 40install_node.sh:20"
fi


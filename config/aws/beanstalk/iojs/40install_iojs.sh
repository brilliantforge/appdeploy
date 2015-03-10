#!/bin/bash
#source env variables including iojs version
. /opt/elasticbeanstalk/env.vars

function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}

#download and extract desired io.js version
echo "checking iojs..."
OUT=$( [ ! -d "/opt/elasticbeanstalk/iojs-install" ] && echo "trying to install iojs $IOJS_VER"   && mkdir /opt/elasticbeanstalk/iojs-install ; cd /opt/elasticbeanstalk/iojs-install/ && \
  wget -nc http://iojs.org/dist/v$IOJS_VER/iojs-v$IOJS_VER-linux-$ARCH.tar.gz && \
  tar --skip-old-files -xzpf iojs-v$IOJS_VER-linux-$ARCH.tar.gz) || error_exit "Failed to UPDATE iojs version. $OUT" $?.
echo $OUT


#UNCOMMENT to update npm, otherwise will be updated on instance init or rebuild
rm -f /opt/elasticbeanstalk/iojs-install/npm_updated

echo $OUT

#make sure iojs binaries can be found globally
if [ ! -L /usr/bin/node ]; then
  ln -s /opt/elasticbeanstalk/iojs-install/iojs-v$IOJS_VER-linux-$ARCH/bin/iojs /usr/bin/node
fi

if [ ! -L /usr/bin/iojs ]; then
  ln -s /opt/elasticbeanstalk/iojs-install/iojs-v$IOJS_VER-linux-$ARCH/bin/iojs /usr/bin/iojs
fi

if [ ! -L /usr/bin/npm ]; then
ln -s /opt/elasticbeanstalk/iojs-install/iojs-v$IOJS_VER-linux-$ARCH/bin/npm /usr/bin/npm
fi

echo "checking npm..."
if [ ! -f "/opt/elasticbeanstalk/iojs-install/npm_updated" ]; then
cd /opt/elasticbeanstalk/iojs-install/iojs-v$IOJS_VER-linux-$ARCH/bin/ && /opt/elasticbeanstalk/iojs-install/iojs-v$IOJS_VER-linux-$ARCH/bin/npm update npm -g
touch /opt/elasticbeanstalk/iojs-install/npm_updated
echo "YAY! Updated global NPM version to `npm -v`"
else
  echo "Skipping NPM -g version update. To update, please uncomment 40install_iojs.sh:20"
fi


#! /bin/bash

#
# This script is executed as 'source'. Do not do 'exit'.
#

#
# Get this directory
#
myname="${BASH_SOURCE:-$0}"
mydir=$(cd -P -- $(dirname -- "${myname}"); pwd)

#
# Set environment variables
#
source "${mydir}/set-env.sh"

#
# Ant
#
echo "Install Ant ${ANT_VERSION}"

# Create dir to invalidate any preinstalled Ant
if [ ! -d "${ANT_HOME}" ]; then
    mkdir -p "${ANT_HOME}"
fi

curl -fsSL --retry 5 "http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz" \
| tar -x -z -C "${ANT_HOME}/.." \
|| return

#
# Other deps
#
echo "Install the other deps"
ant -buildfile "${mydir}/build_install-deps.xml"

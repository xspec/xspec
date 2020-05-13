#! /bin/bash

# Select the mainstream by default
if [ -z "${XSPEC_TEST_ENV}" ]; then
    XSPEC_TEST_ENV=saxon-9-9
fi
echo "Setting up ${XSPEC_TEST_ENV}"

myname="${BASH_SOURCE:-$0}"
mydir=$(cd -P -- $(dirname -- "${myname}"); pwd)

for f in \
    "${mydir}/env/global.env" \
    "${mydir}/env/${XSPEC_TEST_ENV}.env"
do
    # * "Set environment variables from file of key/value pairs": https://stackoverflow.com/a/49674707
    # * "Process substitution to 'source' do not work on Mac OS": https://stackoverflow.com/a/56060300
    declares=$(egrep -v '^#|^$' "${f}" | sed -e 's/.*/declare -x "&"/g')
    eval "${declares}"
done

#!/bin/bash

TAR=/bin/tar
GZIP=/bin/gzip
MEDIA_DIR=/usr/openv/media
NB71_DIR=NetBackup_7.1_LinuxR_x86_64
AUX_DIR="${MEDIA_DIR}/${NB71_DIR}"
NB71_FILE=${NB71_DIR}.tar.gz
INSTALL_WRAPPER=/usr/local/steng/backup/nbuinstall/nbu71inst-wrapper.rb
INSTALL_LOG=/root/nb71install.log

exit_msg () {
  exit_code=$1
  msg=$2
  echo "MSG:$msg" 1>&2
  exit $exit_code
}

if [ ! -f "${MEDIA_DIR}/${NB71_FILE}" ]; then
  echo Media not present 1>&2
fi

pushd ${MEDIA_DIR} > /dev/null

echo "Unpacking media" 1>&2
${TAR} xzf "${NB71_FILE}" || exit_msg 1 "failed untar"

pushd ${AUX_DIR} > /dev/null

echo "Starting install" 1>&2
${INSTALL_WRAPPER} || exit_msg 1 "Failed install"

echo "Removing media" 1>&2 
if [ -d "${AUX_DIR}" ]; then
  /bin/rm -rf "${AUX_DIR}"
fi

popd 
popd 

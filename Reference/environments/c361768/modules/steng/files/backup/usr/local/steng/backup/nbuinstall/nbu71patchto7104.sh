#!/bin/bash

TAR=/bin/tar
GZIP=/bin/gzip
MEDIA_DIR=/usr/openv/media
HALF_1="NB_CLT_7.1.0.4-tar-split.1of2"
HALF_2="NB_CLT_7.1.0.4-tar-split.2of2"
TARGET_TAR="NB_CLT_7.1.0.4.tar"
PATCH_DIR="patch"
PATCH_WRAPPER=/usr/local/steng/backup/nbuinstall/nbu71patch7104-wrapper.rb
NB_SVC=/etc/init.d/netbackup

exit_msg () {
  exit_code=$1
  msg=$2
  echo "MSG:$msg" 1>&2
  exit $exit_code
}


echo "Stopping NB" 1>&2
${NB_SVC} stop || exit_msg 1 "Failed to stop NB"


echo "Unpacking media" 1>&2

mkdir "${MEDIA_DIR}/${PATCH_DIR}"

if [ ! -f "${MEDIA_DIR}/${HALF_1}" -or ! -f "${MEDIA_DIR}/${HALF_2}" ]; then
  echo Media not present 1>&2
fi

pushd "${MEDIA_DIR}"

cat "${HALF_1}" "${HALF_2}" > "${MEDIA_DIR}/${PATCH_DIR}/${TARGET_TAR}" || exit_msg 1 "Not able to create tar file ${TARGET_TAR}"

pushd "${PATCH_DIR}"

${TAR} xf "${TARGET_TAR}"  || exit_msg 1 "Failed untar"

echo "Starting patch" 1>&2
${PATCH_WRAPPER} || exit_msg 1 "Failed patch"

popd 

echo "Removing media" 1>&2 
if [ -d "${PATCH_DIR}" ]; then
  /bin/rm -rf "${PATCH_DIR}"
  /bin/rm -f "${TARGET_TAR}"
fi

popd

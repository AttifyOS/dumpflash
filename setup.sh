#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${APM_TMP_DIR}" ]]; then
    echo "APM_TMP_DIR is not set"
    exit 1
  
  elif [[ -z "${APM_PKG_INSTALL_DIR}" ]]; then
    echo "APM_PKG_INSTALL_DIR is not set"
    exit 1
  
  elif [[ -z "${APM_PKG_BIN_DIR}" ]]; then
    echo "APM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  wget https://github.com/indygreg/python-build-standalone/releases/download/20220802/cpython-3.9.13+20220802-x86_64-unknown-linux-gnu-install_only.tar.gz -O $APM_TMP_DIR/cpython-3.9.13.tar.gz
  tar xf $APM_TMP_DIR/cpython-3.9.13.tar.gz -C $APM_PKG_INSTALL_DIR
  rm $APM_TMP_DIR/cpython-3.9.13.tar.gz

  wget https://github.com/ohjeongwook/dumpflash/archive/fc0c3e13909c9f08e8a4ad90a5a7e0bc02ae1544.tar.gz -O $APM_TMP_DIR/dumpflash.tar.gz
  tar xf $APM_TMP_DIR/dumpflash.tar.gz -C $APM_PKG_INSTALL_DIR
  rm $APM_TMP_DIR/dumpflash.tar.gz
  mv $APM_PKG_INSTALL_DIR/dumpflash-fc0c3e13909c9f08e8a4ad90a5a7e0bc02ae1544 $APM_PKG_INSTALL_DIR/dumpflash
  
  $APM_PKG_INSTALL_DIR/python/bin/pip3.9 install pyftdi pyusb libusb1

  for tool in dumpflash dumpjffs2
  do
    echo '#!/usr/bin/env sh' > $APM_PKG_BIN_DIR/$tool
    echo -ne "$APM_PKG_INSTALL_DIR/python/bin/python3.9 $APM_PKG_INSTALL_DIR/dumpflash/dumpflash/$tool.py " >> $APM_PKG_BIN_DIR/$tool
    echo '"$@"' >> $APM_PKG_BIN_DIR/$tool
    chmod +x $APM_PKG_BIN_DIR/$tool
  done

  echo "This package adds the commands:"
  echo " - dumpflash"
  echo " - dumpjffs2"
}

uninstall() {
  rm -rf $APM_PKG_BIN_DIR/python
  rm $APM_PKG_BIN_DIR/dumpflash
  rm $APM_PKG_BIN_DIR/dumpjffs2  
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1
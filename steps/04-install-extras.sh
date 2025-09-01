#!/bin/bash -eux

PATH_FILE=${GITHUB_PATH:-$PWD/.path}
SOURCE="${PDFium_SOURCE_DIR:-pdfium}"
OS="${PDFium_TARGET_OS:?}"
CPU="${PDFium_TARGET_CPU:?}"

pushd "$SOURCE"

case "$OS" in
  linux)
    build/install-build-deps.sh
    echo "rename back the folder to pdfium250901"
    cd ../
    ls -al
    mv $PWD/pdfium $PWD/pdfium250901
    cd pdfium250901
    gclient runhooks
    echo "rename the folder to pdfium"
    cd ../
    ls -al
    mv $PWD/pdfium250901 $PWD/pdfium
    cd pdfium
    build/linux/sysroot_scripts/install-sysroot.py "--arch=$CPU"
    ;;

  android)
    build/install-build-deps.sh --android
    gclient runhooks
    ;;

  emscripten)
    pushd third_party
    if [ -e "emsdk" ]; then
      git -C "emsdk" pull
    else
      git clone https://github.com/emscripten-core/emsdk.git
    fi
    cd emsdk
    ./emsdk install ${EMSDK_VERSION:-latest}
    ./emsdk activate ${EMSDK_VERSION:-latest}
    echo "$PWD/upstream/emscripten" >> "$PATH_FILE"
    echo "$PWD/upstream/bin" >> "$PATH_FILE"
    popd
    ;;
esac

popd

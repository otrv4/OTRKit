#!/bin/bash
set -e

if [ ! -e "LATEST.tar.gz" ]; then
   curl -LO "https://download.libsodium.org/libsodium/releases/LATEST.tar.gz"  --retry 5
fi

# Extract source
rm -rf "libsodium-LATEST"
tar zxf "LATEST.tar.gz"

pushd "libsodium-LATEST"

   LDFLAGS="-L${ARCH_BUILT_LIBS_DIR} -fPIE ${PLATFORM_VERSION_MIN} -fembed-bitcode"
   CFLAGS=" -arch ${ARCH} -fPIE -isysroot ${SDK_PATH} -I${ARCH_BUILT_HEADERS_DIR} ${PLATFORM_VERSION_MIN} -fembed-bitcode"
   CPPFLAGS=" -arch ${ARCH} -fPIE -isysroot ${SDK_PATH} -I${ARCH_BUILT_HEADERS_DIR} ${PLATFORM_VERSION_MIN} -fembed-bitcode"

   if [ "${ARCH}" == "i386" ] || [ "${ARCH}" == "x86_64" ];
      then
      EXTRA_CONFIG="--host ${ARCH}-apple-darwin"
   else
      EXTRA_CONFIG="--host=arm-apple-darwin"
   fi

   ./configure --disable-shared --enable-static --with-pic ${EXTRA_CONFIG} \
   --with-sysroot="${SDK_PATH}" \
   --prefix="${ROOTDIR}" \
   LDFLAGS="${LDFLAGS}" \
   CFLAGS="${CFLAGS}" \
   CPPLAGS="${CPPFLAGS}"

   make
   make install

   # Copy the build results
   cp "${ROOTDIR}/lib/libsodium.a" "${ARCH_BUILT_LIBS_DIR}"
   cp -R ${ROOTDIR}/include/* "${ARCH_BUILT_HEADERS_DIR}"
   cp -R ${ROOTDIR}/bin/* "${ARCH_BUILT_BIN_DIR}"

popd

# Clean up
rm -rf "libsodium-LATEST"

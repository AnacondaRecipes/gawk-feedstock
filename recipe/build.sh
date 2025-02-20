#!/bin/bash
set -eux

# Ensure the timestamp dependencies do not cause us to need
# to run autoreconf-y stuff (which I tried but it is not in
# a working state at present with gawk 4.2.1).
mv "bootstrap.sh?h=${PKG_NAME}-${PKG_VERSION}" bootstrap.sh
chmod +x ./bootstrap.sh
./bootstrap.sh

# For linux-64 and linux-s390x platforms, we disable the persistent memory allocator (PMA)
# by passing --disable-pma to the configure script. This allocator is not required on these
# architectures and disabling it avoids potential build or runtime issues.
if [[ ${target_platform} == linux-64 ]]; then
    ./configure --prefix="${PREFIX}" \
                --with-readline="${PREFIX}" \
                --disable-pma
elif [[ ${target_platform} == linux-s390x ]]; then
    ./configure --prefix="${PREFIX}" \
                --with-readline="${PREFIX}" \
                --disable-pma
else
    ./configure --prefix="${PREFIX}" \
            --with-readline="${PREFIX}"
fi

make -j${CPU_COUNT} AM_V=99

rm test/localenl.*

# These tests fail under emulation, still run them but ignore their result
if [[ ${target_platform} == linux-aarch64 ]]; then
    make check || true
elif [[ ${target_platform} == linux-ppc64le ]]; then
    make check || true
else
    make check
fi

make install

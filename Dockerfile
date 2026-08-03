FROM ubuntu:24.04

# Note: this image is published as a multi-arch manifest (linux/amd64 + linux/arm64) so
# that each Amalgam arch builds natively on a runner of the same arch. No cross-compilers
# and no qemu-user: arm64 is no longer cross-compiled or emulated.
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
&& DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
   apt-transport-https software-properties-common ca-certificates gpg \
   sudo build-essential gcc-14 g++-14 git wget python3 \
   pipx python-is-python3 tzdata locales clang \
   cmake ninja-build \
&& apt-get autoremove -y \
&& apt-get purge -y --auto-remove \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/

RUN apt-cache policy gcc-14

# Print version info
# Note: Ubuntu 24.04 ships CMake 3.28, which satisfies Amalgam's 3.26 minimum, so the
# Kitware apt repo that the previous 20.04 based image needed is no longer required.
RUN cmake --version
RUN ninja --version
RUN ldd --version

# Locale update:
RUN locale-gen es_ES.utf8 \
&& update-locale

# Default GCC:
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 100 --slave /usr/bin/g++ g++ /usr/bin/g++-14 --slave /usr/bin/gcov gcov /usr/bin/gcov-14 \
&& update-alternatives --config gcc

RUN gcc --version

# WASM compiler:
# Note: wasm64 is only built on amd64, so emsdk is skipped on arm64 to avoid a slow
# emulated install when this image is built as a multi-arch manifest. The arch is read
# from dpkg rather than the TARGETARCH build arg so this behaves the same whether or not
# the image is built through buildx.
RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then \
    mkdir -p /wasm \
    && git clone https://github.com/emscripten-core/emsdk.git /wasm/emsdk \
    && cd /wasm/emsdk \
    && ./emsdk install 3.1.67 \
    && ./emsdk activate 3.1.67; \
    fi
ENV PATH="/wasm/emsdk/upstream/emscripten:${PATH}"

# tzdata for WASM:
RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then \
    cd /wasm \
    && mkdir tzdata && mkdir etc \
    && wget https://data.iana.org/time-zones/releases/tzdata2024b.tar.gz \
    && tar -xzf tzdata*.tar.gz -C tzdata \
    && echo "Etc/UTC" > ./etc/timezone; \
    fi

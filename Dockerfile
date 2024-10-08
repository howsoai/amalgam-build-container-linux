FROM ubuntu:20.04

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
&& DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
   apt-transport-https software-properties-common \
   sudo build-essential gcc-10 g++-10 git wget python3 \
   pipx python-is-python3 tzdata locales clang \
   gcc-10-aarch64-linux-gnu g++-10-aarch64-linux-gnu \
   binutils-aarch64-linux-gnu qemu-user \
&& apt-get autoremove -y \
&& apt-get purge -y --auto-remove \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/

RUN apt-cache policy gcc-10

# Secondary installs
RUN apt-get install -y ca-certificates gpg
RUN test -f /usr/share/doc/kitware-archive-keyring/copyright || wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null
RUN apt-get update
RUN apt list -a cmake
RUN apt-get install -y cmake ninja-build

# Print version info
RUN cmake --version
RUN ninja --version
RUN ldd --version

# Locale update:
RUN locale-gen es_ES.utf8 \
&& update-locale

# Default GCC:
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 --slave /usr/bin/g++ g++ /usr/bin/g++-10 --slave /usr/bin/gcov gcov /usr/bin/gcov-10 \
&& update-alternatives --config gcc

RUN gcc --version

# WASM compiler:
RUN mkdir -p /wasm \
&& git clone https://github.com/emscripten-core/emsdk.git /wasm/emsdk \
&& cd /wasm/emsdk \
&& ./emsdk install 3.1.67 \
&& ./emsdk activate 3.1.67
ENV PATH="/wasm/emsdk/upstream/emscripten:${PATH}"

# tzdata for WASM:
RUN cd /wasm \
&& mkdir tzdata && mkdir etc \
&& wget https://data.iana.org/time-zones/releases/tzdata2024b.tar.gz \
&& tar -xzf tzdata*.tar.gz -C tzdata \
&& echo "Etc/UTC" > ./etc/timezone

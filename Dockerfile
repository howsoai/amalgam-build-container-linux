FROM ubuntu:24.04

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
&& DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
   apt-transport-https software-properties-common \
   sudo build-essential gcc-13 g++-13 git wget python3 \
   pipx python-is-python3 tzdata locales clang \
   gcc-13-aarch64-linux-gnu g++-13-aarch64-linux-gnu \
   binutils-aarch64-linux-gnu qemu-user \
&& apt-get autoremove -y \
&& apt-get purge -y --auto-remove \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/

RUN apt-cache policy gcc-13

# Secondary installs
RUN pipx install cmake ninja

# Locale update:
RUN locale-gen es_ES.utf8 \
&& update-locale

# Default GCC:
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 --slave /usr/bin/g++ g++ /usr/bin/g++-13 --slave /usr/bin/gcov gcov /usr/bin/gcov-13 \
&& update-alternatives --config gcc

RUN gcc --version

# WASM compiler:
RUN mkdir -p /wasm \
&& git clone https://github.com/emscripten-core/emsdk.git /wasm/emsdk \
&& cd /wasm/emsdk \
&& ./emsdk install 3.1.32 \
&& ./emsdk activate 3.1.32
ENV PATH="/wasm/emsdk/upstream/emscripten:${PATH}"

# tzdata for WASM:
RUN cd /wasm \
&& mkdir tzdata && mkdir etc \
&& wget https://data.iana.org/time-zones/releases/tzdata2023c.tar.gz \
&& tar -xzf tzdata*.tar.gz -C tzdata \
&& echo "Etc/UTC" > ./etc/timezone

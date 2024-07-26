FROM ubuntu:24.04

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
&& DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
   apt-transport-https software-properties-common \
   sudo build-essential gcc-14 g++-14 git wget python3 \
   pipx python-is-python3 tzdata locales clang \
   gcc-14-aarch64-linux-gnu g++-14-aarch64-linux-gnu \
   binutils-aarch64-linux-gnu qemu-user \
&& apt-get autoremove -y \
&& apt-get purge -y --auto-remove \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/

# Secondary installs
RUN pipx install cmake ninja

# Locale update:
RUN locale-gen es_ES.utf8 \
&& update-locale

# Default GCC:
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 100 --slave /usr/bin/g++ g++ /usr/bin/g++-14 --slave /usr/bin/gcov gcov /usr/bin/gcov-14 \
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

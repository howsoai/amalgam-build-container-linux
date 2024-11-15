# The purpose of this dockerfile is to generate a build container
# for Amalgam builds using GLIBC_2_28 so we can support Oracle
# Linx 8.x for an important customer.
FROM oraclelinux:8

# Install necessary tools
RUN dnf update -y \
    && dnf install -y \
       sudo gcc gcc-c++ make git wget python3 \
       python3-pip python3-setuptools python3-wheel tzdata clang \
       glibc glibc-locale-source glibc-langpack-en glibc-langpack-es binutils \
       epel-release \
    && dnf install -y \
       gcc-toolset-10-gcc gcc-toolset-10-gcc-c++ \
    && dnf clean all

# Set Timezone to be America/New_York aka Eastern Timezone.
RUN mkdir -p /zoneinfo && cp -r /usr/share/zoneinfo/* /zoneinfo
ENV TZ=America/New_York
RUN mkdir -p /etc \
   && sudo ln -snf /usr/share/zoneinfo/America/New_York /etc/localtime \
   && echo $TZ > /etc/timezone

# Set environment for GCC 10
ENV PATH=/opt/rh/gcc-toolset-10/root/usr/bin:$PATH

# Install cmake and ninja-build
RUN dnf install -y dnf-plugins-core \
    && dnf --enablerepo=ol8_codeready_builder install cmake ninja-build \
    && dnf clean all

# Print version info
RUN cmake --version \
    && ninja --version \
    && ldd --version

# Locale setup for Spanish (no locales package, use langpack instead)
ENV LANG=es_ES.UTF-8
RUN localedef -i es_ES -f UTF-8 es_ES.UTF-8

# Default GCC setup
RUN update-alternatives --install /usr/bin/gcc gcc /opt/rh/gcc-toolset-10/root/usr/bin/gcc 100 \
    --slave /usr/bin/g++ g++ /opt/rh/gcc-toolset-10/root/usr/bin/g++ \
    --slave /usr/bin/gcov gcov /opt/rh/gcc-toolset-10/root/usr/bin/gcov \
    && update-alternatives --set gcc /opt/rh/gcc-toolset-10/root/usr/bin/gcc

RUN gcc --version && ldd --version

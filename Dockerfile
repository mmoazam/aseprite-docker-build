# Use the official Ubuntu image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/root
ENV OPENSSL_ROOT_DIR=/usr/bin/openssl

# Update package list and install necessary packages
RUN apt-get update && \
    apt-get install -y \
    git \
    net-tools \
    iputils-ping \
    curl \
    wget \
    g++ \
    clang \
    libc++-dev \
    libc++abi-dev \
    cmake \
    ninja-build \
    libx11-dev \
    libxcursor-dev \
    libxi-dev \
    libgl1-mesa-dev \
    libfontconfig1-dev \
    python3 \
    python3-pip

# Create directory for dependencies
RUN mkdir -p $HOME/deps

# Clone depot_tools and skia
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $HOME/deps/depot_tools && \
    git clone -b aseprite-m102 https://github.com/aseprite/skia.git $HOME/deps/skia

# Set PATH for depot_tools
ENV PATH="$HOME/deps/depot_tools:$PATH"

# Sync skia dependencies and build skia
WORKDIR $HOME/deps/skia
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN python tools/git-sync-deps 
RUN gn gen out/Release-x64 --args='is_debug=false is_official_build=true skia_use_system_expat=false skia_use_system_icu=false skia_use_system_libjpeg_turbo=false skia_use_system_libpng=false skia_use_system_libwebp=false skia_use_system_zlib=false skia_use_sfntly=false skia_use_freetype=true skia_use_harfbuzz=true skia_pdf_subset_harfbuzz=true skia_use_system_freetype2=false skia_use_system_harfbuzz=false cc="clang" cxx="clang++" extra_cflags_cc=["-stdlib=libc++"] extra_ldflags=["-stdlib=libc++"]' 
RUN ninja -C out/Release-x64 skia modules

# Clone and build Aseprite
RUN git clone --recursive https://github.com/aseprite/aseprite.git $HOME/aseprite
WORKDIR $HOME/aseprite/build
RUN mkdir build && \
    export CC=clang && \
    export CXX=clang++ && \
    cmake \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_CXX_FLAGS:STRING=-stdlib=libc++ \
    -DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libc++ \
    -DLAF_BACKEND=skia \
    -DSKIA_DIR=$HOME/deps/skia \
    -DSKIA_LIBRARY_DIR=$HOME/deps/skia/out/Release-x64 \
    -DSKIA_LIBRARY=$HOME/deps/skia/out/Release-x64/libskia.a \
    -G Ninja \
    .. && \
    ninja aseprite

# Default command (change as needed)
CMD ["bash"]

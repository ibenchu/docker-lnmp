FROM alpine:3.4
MAINTAINER onni.hakala@geniem.com

ENV RESTY_VERSION=1.11.2.2 \
    RESTY_OPENSSL_VERSION=1.0.2j \
    RESTY_PCRE_VERSION=8.39 \
    RESTY_J=1 \
    #NGINX_VERSION=1.9.15 \
    PAGESPEED_VERSION=1.11.33.4 \
    SOURCE_DIR=/tmp/src \
    LIBPNG_LIB=libpng12 \
    LIBPNG_VERSION=1.2.56

RUN set -x && \

    # Install runtime dependencies
    apk --no-cache --update add \
        ca-certificates \
        libuuid \
        apr \
        apr-util \
        libjpeg-turbo \
        icu \
        icu-libs \
        openssl \
        pcre \
        gd \
        geoip \
        libgcc \
        libxslt \
        zlib && \
    
    # Install temporary build dependencies
    apk --no-cache --update add -t .build-deps \
        apache2-dev \
        apr-dev \
        apr-util-dev \
        build-base \
        icu-dev \
        libjpeg-turbo-dev \
        linux-headers \
        gperf \
        openssl-dev \
        pcre-dev \
        python \
        wget \
        curl \
        gd-dev \
        geoip-dev \
        libxslt-dev \
        make \
        readline-dev \
        zlib-dev && \
        
        
        
    # Create build directory
    mkdir ${SOURCE_DIR} && \
    cd ${SOURCE_DIR} && \

    ##
    # Download all needed custom packages
    ##
    
    # Pagespeed
    wget -O- https://dl.google.com/dl/linux/mod-pagespeed/tar/beta/mod-pagespeed-beta-${PAGESPEED_VERSION}-r0.tar.bz2 | tar -jx && \
    # openssl
    curl -fSL https://www.openssl.org/source/openssl-${RESTY_OPENSSL_VERSION}.tar.gz -o openssl-${RESTY_OPENSSL_VERSION}.tar.gz && \
    tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz && \
    curl -fSL https://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${RESTY_PCRE_VERSION}.tar.gz -o pcre-${RESTY_PCRE_VERSION}.tar.gz && \
    tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz && \
    # openresty
    curl -fSL https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz -o openresty-${RESTY_VERSION}.tar.gz && \
    tar xzf openresty-${RESTY_VERSION}.tar.gz && \
    # Psol for pagespeed
    wget -O- ftp://ftp.simplesystems.org/pub/libpng/png/src/${LIBPNG_LIB}/libpng-${LIBPNG_VERSION}.tar.gz | tar -zx && \

    # Libpng for psol
    wget -O- https://github.com/pagespeed/ngx_pagespeed/archive/v${PAGESPEED_VERSION}-beta.tar.gz | tar -zx && \

    # Use all cores available in the builds with -j${NPROC} flag
    readonly NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
    echo "using up to $NPROC threads" && \

    # Build libpng
    cd ${SOURCE_DIR}/libpng-${LIBPNG_VERSION} && \
    ./configure --build=$CBUILD --host=$CHOST --prefix=/usr --enable-shared --with-libpng-compat && \
    make -j${NPROC} && \
    make install -j${NPROC} && \

    # Download and use patches for pagespeed to compile in alpine
    cd ${SOURCE_DIR} && \
    wget https://raw.githubusercontent.com/iler/alpine-nginx-pagespeed/master/patches/automatic_makefile.patch && \
    wget https://raw.githubusercontent.com/iler/alpine-nginx-pagespeed/master/patches/libpng_cflags.patch && \
    wget https://raw.githubusercontent.com/iler/alpine-nginx-pagespeed/master/patches/pthread_nonrecursive_np.patch && \
    wget https://raw.githubusercontent.com/iler/alpine-nginx-pagespeed/master/patches/rename_c_symbols.patch && \
    wget https://raw.githubusercontent.com/iler/alpine-nginx-pagespeed/master/patches/stack_trace_posix.patch && \
    cd ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION} && \
    patch -p1 -i ${SOURCE_DIR}/automatic_makefile.patch && \
    patch -p1 -i ${SOURCE_DIR}/libpng_cflags.patch && \
    patch -p1 -i ${SOURCE_DIR}/pthread_nonrecursive_np.patch && \
    patch -p1 -i ${SOURCE_DIR}/rename_c_symbols.patch && \
    patch -p1 -i ${SOURCE_DIR}/stack_trace_posix.patch && \

    # Build pagespeed module
    ./generate.sh -D use_system_libs=1 -D _GLIBCXX_USE_CXX11_ABI=0 -D use_system_icu=1 && \
    cd ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src && \
    make BUILDTYPE=Release CXXFLAGS=" -I/usr/include/apr-1 -I${SOURCE_DIR}/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" CFLAGS=" -I/usr/include/apr-1 -I${SOURCE_DIR}/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" -j${NPROC} && \

    # Build psol
    cd ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src/pagespeed/automatic/ && \
    make psol BUILDTYPE=Release CXXFLAGS=" -I/usr/include/apr-1 -I${SOURCE_DIR}/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" CFLAGS=" -I/usr/include/apr-1 -I${SOURCE_DIR}/libpng-${LIBPNG_VERSION} -fPIC -D_GLIBCXX_USE_CXX11_ABI=0" -j${NPROC} && \

    # Copy psol and pagespeed modules to nginx build folder
    mkdir -p ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol && \
    mkdir -p ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/lib/Release/linux/x64 && \
    mkdir -p ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/out/Release && \
    cp -r ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src/out/Release/obj ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/out/Release/ && \
    cp -r ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src/net ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/ && \
    cp -r ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src/testing ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/ && \
    cp -r ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src/pagespeed ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/ && \
    cp -r ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src/third_party ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/ && \
    cp -r ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src/tools ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/include/ && \
    cp -r ${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/src/pagespeed/automatic/pagespeed_automatic.a ${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta/psol/lib/Release/linux/x64 && \

    # Build nginx
    cd ${SOURCE_DIR}/openresty-${RESTY_VERSION} && \
    LD_LIBRARY_PATH=${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/usr/lib ./configure --with-file-aio \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_geoip_module=dynamic \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module=dynamic \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_xslt_module=dynamic \
    --with-ipv6 \
    --with-mail \
    --with-mail_ssl_module \
    --with-md5-asm \
    --with-pcre-jit \
    --with-sha1-asm \
    --with-stream \
    --with-stream_ssl_module \
    --with-threads \
    --add-module=${SOURCE_DIR}/ngx_pagespeed-${PAGESPEED_VERSION}-beta \
    --with-cc-opt="-fPIC -I /usr/include/apr-1" \
    --with-ld-opt="-luuid -lapr-1 -laprutil-1 -licudata -licuuc -L${SOURCE_DIR}/modpagespeed-${PAGESPEED_VERSION}/usr/lib -lpng12 -lturbojpeg -ljpeg" && \
    make -j${NPROC} && \
    make install -j${NPROC} && \

    # Cleanup
    apk del .build-deps && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \

    # Symlink log files to system output
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Make our nginx.conf available on the container
ADD conf/nginx.conf /etc/nginx/nginx.conf
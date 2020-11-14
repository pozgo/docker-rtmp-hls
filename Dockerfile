FROM alpine:latest as builder

ENV   NGINX_VERSION=1.19.4 \
      NGINX_RTMP_MODULE_VERSION=1.2.1 \
      FFMPEG_VERSION=4.3.1

RUN apk update  && \
  apk --no-cache add \
    bash \
    build-base \
    ca-certificates \
    openssl \
    openssl-dev \
    make \
    unzip \
    gcc \
    libgcc \
    libc-dev \
    libaio \
    libaio-dev \
    rtmpdump-dev \
    zlib-dev \
    musl-dev \
    pcre \
    pcre-dev \
    lame-dev \
    yasm \
    pkgconf \
    pkgconfig \
    libtheora-dev \
    libvorbis-dev \
    libvpx-dev \
    freetype-dev \
    x264-dev \
    x265-dev && \
  rm -rf /var/lib/apt/lists/* && \  
  mkdir -p /tmp/build && \
  cd /tmp/build && \
  wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
  tar zxf nginx-${NGINX_VERSION}.tar.gz && \
  rm nginx-${NGINX_VERSION}.tar.gz && \
  cd /tmp/build && \
  wget https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_MODULE_VERSION}.tar.gz && \
  tar zxf v${NGINX_RTMP_MODULE_VERSION}.tar.gz && \
  rm v${NGINX_RTMP_MODULE_VERSION}.tar.gz && \
  cd /tmp/build/nginx-${NGINX_VERSION} && \
    ./configure \
      --user=www \
      --group=www \
      --sbin-path=/usr/local/sbin/nginx \
      --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/var/log/nginx/error.log \
      --http-log-path=/var/log/nginx/access.log \
      --pid-path=/var/run/nginx/nginx.pid \
      --lock-path=/var/lock/nginx.lock \
      --http-client-body-temp-path=/tmp/nginx-client-body \
      --with-http_gzip_static_module \
      --with-http_stub_status_module \
      --with-http_ssl_module \
      --with-pcre \
      --with-http_realip_module \
      --with-http_v2_module \
      --with-threads \
      --with-ipv6 \
      --with-debug \
      --add-module=/tmp/build/nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION} && \
  make CFLAGS=-Wno-error -j $(getconf _NPROCESSORS_ONLN) && \
  make install && \
  cd /tmp/build && \
  wget http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz && \
  tar zxf ffmpeg-${FFMPEG_VERSION}.tar.gz && \
  rm ffmpeg-${FFMPEG_VERSION}.tar.gz && \
  cd /tmp/build/ffmpeg-${FFMPEG_VERSION} && \
  ./configure \
    --enable-version3 \
    --enable-gpl \
    --enable-small \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libvpx \
    --enable-libtheora \
    --enable-libvorbis \
    --enable-librtmp \
    --enable-postproc \
    --enable-avresample \
    --enable-swresample \ 
    --enable-libfreetype \
    --enable-libmp3lame \
    --disable-debug \
    --disable-doc \
    --disable-ffplay \
    --extra-libs="-lpthread -lm" && \
  make -j $(getconf _NPROCESSORS_ONLN) && \
  make install && \
  cp /tmp/build/nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}/stat.xsl /usr/local/nginx/html/stat.xsl && \
  rm -rf /tmp/build && \
  tar czvf /stage.tgz /usr/local /etc/nginx /var/log/nginx /var/lock /var/run/nginx

FROM polinux/supervisor:alpine 

COPY --from=builder /stage.tgz /stage.tgz

RUN apk update  && \
  apk --no-cache add \
    bash \
    ca-certificates \
    openssl \
    pcre \
    libtheora \
    libvorbis \
    libvpx \
    librtmp \
    x264-dev \
    x265-dev \
    freetype \
    lame && \
  rm -rf /var/lib/apt/lists/* && \  
  tar zxvf /stage.tgz && \
  rm -rf /stage.tgz && \
  adduser --shell /bin/bash --disabled-password www www && \
  ln -sf /dev/stdout /var/log/nginx/access.log && \
  ln -sf /dev/stderr /var/log/nginx/error.log

ADD container-files /

EXPOSE 1935 8080

FROM hhcordero/docker-centos-base-dev:latest

MAINTAINER DDTech

ENV HTTPD_PREFIX /usr/local/apache2
ENV PATH $PATH:$HTTPD_PREFIX/bin
RUN mkdir -p "$HTTPD_PREFIX"

WORKDIR $HTTPD_PREFIX

RUN yum -y -q install \
        apr \
        apr-devel \
        apr-util \
        apr-util-devel \
        openssl \
        openssl-devel \
        pcre \
        pcre-devel

# see https://httpd.apache.org/download.cgi#verify
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys A93D62ECC3C8EA12DB220EC934EA76E6791485A8

ENV HTTPD_VERSION 2.4.17
ENV HTTPD_BZ2_URL https://www.apache.org/dist/httpd/httpd-$HTTPD_VERSION.tar.bz2

RUN curl -SL "$HTTPD_BZ2_URL" -o httpd.tar.bz2 && \
    curl -SL "$HTTPD_BZ2_URL.asc" -o httpd.tar.bz2.asc && \
    gpg --verify httpd.tar.bz2.asc && \
    mkdir -p src/httpd && \
    tar -xvf httpd.tar.bz2 -C src/httpd --strip-components=1 && \
    rm httpd.tar.bz2* && \
    cd src/httpd && \
    ./configure \
        --enable-so \
        --enable-ssl \
        --prefix=$HTTPD_PREFIX \
        --with-mpm=prefork && \
    make -j"$(nproc)" && \
    make install
    #cd ../../ && \
    #rm -r src/httpd && \
    #sed -ri ' \
    #    s!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g; \
    #    s!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g; \
    #    ' /usr/local/apache2/conf/httpd.conf

COPY httpd-foreground /usr/local/bin/

EXPOSE 80
CMD ["httpd-foreground"]

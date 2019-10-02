###############################################################################
# The FUSE driver needs elevated privileges, run Docker with --privileged=true
###############################################################################

FROM alpine:3.3

ENV MNT_POINT /var/s3
ENV S3_REGION ''
ENV S3_ENDPOINT 'https://s3.amazonaws.com/'
ENV S3_CONNECT_TIMEOUT 10
ENV S3_MAX_CACHE_SIZE 1000
ENV S3_CACHE_EXPIRY 900
ENV S3_RETRIES 5

ARG S3FS_VERSION=v1.83

RUN apk --update --no-cache add fuse alpine-sdk automake autoconf libxml2-dev fuse-dev curl-dev git bash; \
    git clone https://github.com/s3fs-fuse/s3fs-fuse.git; \
    cd s3fs-fuse; \
    git checkout tags/${S3FS_VERSION}; \
    ./autogen.sh; \
    ./configure --prefix=/usr; \
    make; \
    make install; \
    make clean; \
    rm -rf /var/cache/apk/*; \
    apk del git automake autoconf;

RUN mkdir -p "$MNT_POINT"

CMD echo "${AWS_KEY}:${AWS_SECRET_KEY}" > /etc/passwd-s3fs && \
    chmod 0400 /etc/passwd-s3fs && \
    /usr/bin/s3fs $S3_BUCKET $MNT_POINT -f -o url=${S3_ENDPOINT},allow_other,use_path_request_style,use_cache=/tmp,max_stat_cache_size=${S3_MAX_CACHE_SIZE},stat_cache_expire=${S3_CACHE_EXPIRY},retries=${S3_RETRIES},connect_timeout=${S3_CONNECT_TIMEOUT}

FROM node:10-alpine as builder

ARG INSTALL_DIR=/var/primecms

WORKDIR ${INSTALL_DIR}
COPY ./node_modules ./node_modules
COPY ./packages ./packages
RUN echo "require('@primecms/core');" > index.js

FROM alpine:3.10

RUN apk add --no-cache npm

ARG INSTALL_DIR=/var/primecms
ENV INSTALL_DIR ${INSTALL_DIR}
COPY --from=builder ${INSTALL_DIR} ${INSTALL_DIR}

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

WORKDIR ${INSTALL_DIR}
ENTRYPOINT ["sh"]
CMD ["/usr/local/bin/entrypoint"]

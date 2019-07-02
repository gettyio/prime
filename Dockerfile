FROM node:alpine as builder
LABEL org.label-schema.vendor = "Astzweig UG(haftungsbeschränkt) & Co. KG"
LABEL org.label-schema.version = "1.0.0"
LABEL org.label-schema.description = "A docker container to build Prime CMS."
LABEL org.label-schema.vcs-url = "https://github.com/astzweig/docker-primecms"
LABEL org.label-schema.schema-version = "1.0"

RUN apk add --no-cache git npm jq

# If you change these values, do not forget to update it in all the other
# stages too.
ARG BUILD_DIR=/root/primecms
ARG INSTALL_DIR=/var/primecms
ARG PRIMECMS_GIT_REPO=https://github.com/birkir/prime.git
ENV NODE_ENV=production

WORKDIR ${BUILD_DIR}
RUN git clone "${PRIMECMS_GIT_REPO}" "${BUILD_DIR}" && \
    cd "${BUILD_DIR}" && \
    rm -fr .git
RUN while true; do yarn install --silent; test $? -eq 0 && break; sleep 1; done;
RUN yarn setup
RUN yarn compile

WORKDIR ${INSTALL_DIR}/node_modules/@primecms
RUN for dir in "${BUILD_DIR}"/packages/*; do \
        NEW_NAME="$(basename "$dir" | cut -d- -f2-)"; \
        mv "${dir}" "./${NEW_NAME}"; \
        cd "${NEW_NAME}"; \
        yarn install --silent; \
        cd ..; \
    done
RUN rm -fr ${BUILD_DIR}

WORKDIR ${INSTALL_DIR}
RUN echo "require('@primecms/core');" > index.js


FROM alpine:latest
LABEL org.label-schema.vendor = "Astzweig UG(haftungsbeschränkt) & Co. KG"
LABEL org.label-schema.version = "1.0.0"
LABEL org.label-schema.description = "A docker container to run Prime CMS."
LABEL org.label-schema.vcs-url = "https://github.com/astzweig/docker-primecms"
LABEL org.label-schema.schema-version = "1.0"
RUN apk add --no-cache dumb-init npm

ARG INSTALL_DIR=/var/primecms
ENV INSTALL_DIR ${INSTALL_DIR}
COPY --from=builder ${INSTALL_DIR} ${INSTALL_DIR}

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

WORKDIR ${INSTALL_DIR}
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD entrypoint

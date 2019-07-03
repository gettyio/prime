FROM node:10-alpine

ARG INSTALL_DIR=/var/primecms
ENV INSTALL_DIR ${INSTALL_DIR}
WORKDIR ${INSTALL_DIR}

RUN chown -R node:node ${INSTALL_DIR}

USER node

COPY --chown=node:node ./node_modules ./node_modules
COPY --chown=node:node ./packages ./packages
RUN echo "require('@primecms/core');" > index.js

COPY --chown=node:root entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

ENTRYPOINT ["sh"]
CMD ["/usr/local/bin/entrypoint"]

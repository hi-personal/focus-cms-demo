FROM node:20

ARG UID=1000
ARG GID=1000
ARG USERNAME=istvan

RUN set -eux; \
    if ! getent group ${GID} >/dev/null; then \
        groupadd -g ${GID} ${USERNAME}; \
    fi; \
    if ! id -u ${UID} >/dev/null 2>&1; then \
        useradd -u ${UID} -g ${GID} -m ${USERNAME}; \
    fi

USER ${USERNAME}
WORKDIR /var/www/focuscms

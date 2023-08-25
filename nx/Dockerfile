ARG NODE_IMAGE
FROM $NODE_IMAGE AS build
ARG NX_VERSION
ARG PNPM_VERSION
ARG YARN_VERSION
# RUN apk add --update --no-cache python3 make g++ gcompat &&\
#     ln -sf python3 /usr/bin/python
# RUN python3 -m ensurepip
ENV PNPM_HOME /usr/bin/
RUN corepack enable &&\
    corepack prepare pnpm@$PNPM_VERSION --activate &&\
    yarn set version $YARN_VERSION &&\
    pnpm install -g nx@$NX_VERSION
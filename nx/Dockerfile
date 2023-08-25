ARG NODE_IMAGE
FROM $NODE_IMAGE AS build
ARG NX_VERSION
ARG PNPM_VERSION
ARG YARN_VERSION
ENV PNPM_HOME /usr/bin/
RUN corepack enable &&\
    corepack prepare pnpm@$PNPM_VERSION --activate &&\
    yarn set version $YARN_VERSION &&\
    pnpm install -g nx@$NX_VERSION
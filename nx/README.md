# NX

Base image for projects that use [NX](https://nx.dev/) as their build system. The focus of this image is to be used as a build stage in a multi-stage container build. As such it does not have a huge emphasis on image size.

## Tag structure

Tags are organized by the following structure:

`nx:<nx-version>-<node-image>`

### `nx-version`

This part specifies the version of NX that is installed in the image.

### `node-image`

This part specifies which [node](https://hub.docker.com/_/node) image was used as base to create the nx image.

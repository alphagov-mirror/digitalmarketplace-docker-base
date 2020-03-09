# digitalmarketplace-docker-base
Digital Marketplace base docker images

## Building new images

If you want to build images on your machine, use the `Makefile` and it will take care of everything for you; it will make sure you build off the latest version of the Python base image, label the builds with the date and time of build and tag them as well.

    $ make build
    ...
    $ docker images
    REPOSITORY                          TAG                      IMAGE ID            CREATED             SIZE
    digitalmarketplace/base-frontend    3.3.0                    ffab96c99623        2 weeks ago         610MB
    digitalmarketplace/base-frontend    3.3.0-20180813T135211Z   ffab96c99623        2 weeks ago         610MB
    digitalmarketplace/base-frontend    latest                   ffab96c99623        2 weeks ago         610MB
    digitalmarketplace/base-api         3.3.0                    648b914dd28c        2 weeks ago         610MB
    digitalmarketplace/base-api         3.3.0-20180813T135211Z   648b914dd28c        2 weeks ago         610MB
    digitalmarketplace/base-api         latest                   648b914dd28c        2 weeks ago         610MB
    digitalmarketplace/base             3.3.0                    987aeb4f0121        2 weeks ago         610MB
    digitalmarketplace/base             3.3.0-20180813T135211Z   987aeb4f0121        2 weeks ago         610MB
    digitalmarketplace/base             latest                   987aeb4f0121        2 weeks ago         610MB

## Sharing images

Once you're happy with the result, remember to push them to DockerHub so they can be used for the Digital Marketplace apps

    $ make push
  
It will ask you to log in if you haven't already.

## Debugging containers

Sometimes it's useful to know what's happening inside a container built from an image.

To start a container from an image and get a bash prompt:

    $ docker run -it <image_name>:<image_tag> bash

## Upgrading Node

If you are upgrading the Node version on the `frontend.docker` image, include the hash of the tarball. You
can generate this by downloading the tarball locally from https://nodejs.org/en/blog/release/ and running:

    $ sha256sum node-<VERSION>-linux-x64.tar.xz | cut -d " " -f 1

Note that this is not a guarantee of a secure download, but it does ensure we're getting a more reproducible image.

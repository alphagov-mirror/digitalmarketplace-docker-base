# Digital Marketplace base Docker image

Records breaking changes from major version bumps

## Unreleased

Upgrade to Python 3.7.

## 9.0.0

Remove `nodejs` from `-api` image, adding it only in the `-frontend` image. Also bump it to 10.18.1.

PR: [#68](https://github.com/alphagov/digitalmarketplace-docker-base/pull/68)

## 8.0.0

Upgrade supervisor from v3 to v4 to remove redundant Python2 install. Python2 is no longer installed in these images.

PR: [#65](https://github.com/alphagov/digitalmarketplace-docker-base/pull/65)

## 7.0.0

Switch base to `python:3.6-slim-buster`. Many underlying package versions will have changed, so it's best to be
a bit cautious with this bump and check everything's operating correctly. References to `stretch` in downstream
`Dockerfile`s should be updated to `buster`.

## 6.0.0

Remove yarn, we're now using npm instead

## 5.0.0

Updated the base version of Node to 10.16.3 (LTS) as the previous version (8.12.0) was reaching end of life.

## 4.0.0

PR [#36](https://github.com/alphagov/digitalmarketplace-docker-base/pull/36)

### What changed?

We've updated the base version of Node to 8.12.0, as the previous version (6.12.2) was reaching end of life.

## 3.0.0

PR: [#21](https://github.com/alphagov/digitalmarketplace-docker-base/pull/21)

### What changed?

We're now using yarn (see what version [here](https://github.com/alphagov/digitalmarketplace-docker-base/blob/master/base.docker#L6)) instead of bower and npm. Also updates the base image to the current stable distribution of Debian (version 9, codenamed stretch)

## 2.0.0

PR: [#13](https://github.com/alphagov/digitalmarketplace-docker-base/pull/13)

### What changed?

The base image is now created from a Python 3 base image. This means that apps will run on Python 3. Python 3 versions are being run with a separate VERSION file and base docker image, as we will need to run Python 2 and Python 3 apps while we make the transition, starting with the API.

Having a separate VERSION file (PY2VERSION for Python 2) will allow us to build a push docker images for both versions simultaneously.

## 1.0.0

Initial version.

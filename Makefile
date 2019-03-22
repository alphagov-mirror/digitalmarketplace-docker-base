
# Manage Digital Marketplace Docker base images.
#
# This Makefile is designed to make it easy to manage the container images in
# the digitalmarketplace-docker-base repo (base, base-api, base-frontend). You
# can build, push, and scan these images, either all in one go, or
# individually. If you specify an individual image, make will try and use the
# latest version of the image that you have built locally.
#
# Usage:
#   make <target>
#   make build[-<image>] [options]
#   make push[-<image>] [options]
#   make scan[-<image>] [SCAN_UPLOAD=(true|false)] [SCAN_REPORTS=<dir>] [options]
#
# Options:
#   LATEST=(true|false)  Tell Docker to treat the image(s) as the best
#                        available for that version/tag [default: false].
#   TAG=<tag>            Specify an optional tag to be able to identify an
#                        image more easily. If not provided the default
#                        behaviour is to tag the image with the repo version.
#
# Targets:
#   build          Build all images.
#   push           Push all images to Docker Hub.
#   scan           Scan all images using Snyk.
#
#   build-<image>  Build the specified image.
#   push-<image>   Push the specified image.
#   scan-<image>   Scan the specified image using Snyk.
#                  Make exits with a non-zero status if any of the images have
#                  vulnerabilities. Detailed scan reports are kept in the
#                  SCAN_REPORTS folder. By default the scan reports are also
#                  uploaded to snyk.io using the credentials from the
#                  DM_CREDENTIALS_REPO, this can be overrided by specifying
#                  SCAN_UPLOAD=false on the command line.
#
#   clean  Remove temporary files including scan reports.
#          Docker images will not be deleted.
#   help   Show this help message.

ifeq (${TAG}, latest)
	LATEST := true
	override undefine TAG
endif

ifeq (${LATEST}, false)
	override undefine LATEST
endif

SCAN_UPLOAD := true
SCAN_REPORTS := .snyk_reports

BUILD_DATE := $(shell date -u '+%Y%m%dT%H%M%SZ')
BUILD_VERSION := $(shell cat VERSION)

BUILD_TAG := $(if ${TAG},${TAG}-${BUILD_VERSION},${BUILD_VERSION})

IMAGES := base base-api base-frontend

# Show help message.
.PHONY: help
help:
	@awk 'BEGIN {s=0} /^#.*/ {s=1; print $$0} /^$$/ { if (s) exit }' ${MAKEFILE_LIST} | sed 's/^#\(.*\)/ \1/'

.stamp:
	@mkdir .stamp
	@echo '*' > .stamp/.gitignore

${SCAN_REPORTS}:
	@mkdir ${SCAN_REPORTS}
	@echo '*' > ${SCAN_REPORTS}/.gitignore

# Clean temporary files including scan reports.
.PHONY: clean
clean:
	@rm -rf .stamp
	@rm -rf ${SCAN_REPORTS}

# Build the digitalmarketplace/base image.
.stamp/base-${BUILD_TAG}: base.docker .stamp
	$(eval BUILD_ARGS := --build-arg BUILD_DATE=${BUILD_DATE} --build-arg BUILD_VERSION=${BUILD_VERSION})
	docker build \
		--pull \
		${BUILD_ARGS} \
		-t digitalmarketplace/base:${BUILD_TAG}-${BUILD_DATE} \
		$(if ${LATEST},-t digitalmarketplace/base:${BUILD_TAG}) \
		$(if ${TAG},-t digitalmarketplace/base:${TAG} ) \
		-f base.docker .

	echo ${BUILD_DATE} > $@

# Build the digitalmarketplace/base-% image.
.stamp/base-%-${BUILD_TAG}: %.docker .stamp/base-${BUILD_TAG} .stamp
	$(eval BASE_BUILD_DATE := $(shell cat .stamp/base-${BUILD_TAG}))
	docker build \
		--cache-from digitalmarketplace/base:${BUILD_TAG}-${BASE_BUILD_DATE} \
		-t digitalmarketplace/base-$*:${BUILD_TAG}-${BUILD_DATE} \
		$(if ${LATEST},-t digitalmarketplace/base-$*:${BUILD_TAG}) \
		$(if ${TAG},-t digitalmarketplace/base-$*:${TAG} ) \
		-f $*.docker .

	echo ${BUILD_DATE} > $@

# Build the % image.
$(patsubst %,build-%,${IMAGES}): build-%: .stamp/%-${BUILD_TAG}

# Push the % image.
push-%: .stamp/%-${BUILD_TAG}
	$(eval BUILD_DATE := $(shell cat .stamp/$*-${BUILD_TAG}))
	docker push digitalmarketplace/$*:${BUILD_TAG}-${BUILD_DATE}
	$(if ${LATEST}, docker push digitalmarketplace/$*:${BUILD_TAG})
	$(if ${TAG}, docker push digitalmarketplace/$*:${TAG})

# Scan the % image.
scan-%: .stamp/%-${BUILD_TAG}
	$(eval BUILD_DATE := $(shell cat .stamp/$*-${BUILD_TAG}))
	$(eval export MONITOR := ${SCAN_UPLOAD})
	$(if $(findstring ${SCAN_UPLOAD},true), ${DM_CREDENTIALS_REPO}/sops-wrapper -v > /dev/null)

	./docker-scan.sh \
		-o ${REPORTS}/digitalmarketplace_$*_${BUILD_TAG}_${BUILD_DATE} \
		digitalmarketplace/$*:${BUILD_TAG}-${BUILD_DATE} \
		$*.docker

# Build all images.
.PHONY: build
build: $(patsubst %,build-%,${IMAGES})

# Push all images to Docker Hub.
.PHONY: push
push: $(patsubst %,push-%,${IMAGES})

# Scan all images using Snyk.
.PHONY: scan
scan: $(patsubst %,scan-%,${IMAGES})

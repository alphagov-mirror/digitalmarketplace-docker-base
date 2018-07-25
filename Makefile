BUILD_VERSION := $(shell cat VERSION)
BUILD_DATE := $(shell date -u '+%Y%m%dT%H%M%SZ')

.PHONY: build
build:
	docker pull digitalmarketplace/base
	docker build --cache-from digitalmarketplace/base -t digitalmarketplace/base -f base.docker .
	docker tag digitalmarketplace/base digitalmarketplace/base:${BUILD_VERSION}
	docker tag digitalmarketplace/base digitalmarketplace/base:${BUILD_VERSION}-${BUILD_DATE}

	docker build -t digitalmarketplace/base-api -f api.docker .
	docker tag digitalmarketplace/base-api digitalmarketplace/base-api:${BUILD_VERSION}
	docker tag digitalmarketplace/base-api digitalmarketplace/base-api:${BUILD_VERSION}-${BUILD_DATE}

	docker build -t digitalmarketplace/base-frontend -f frontend.docker .
	docker tag digitalmarketplace/base-frontend digitalmarketplace/base-frontend:${BUILD_VERSION}
	docker tag digitalmarketplace/base-frontend digitalmarketplace/base-frontend:${BUILD_VERSION}-${BUILD_DATE}

.PHONY: push
push:
	docker push digitalmarketplace/base:${BUILD_VERSION}
	docker push digitalmarketplace/base:${BUILD_VERSION}-${BUILD_DATE}
	docker push digitalmarketplace/base:latest

	docker push digitalmarketplace/base-api:${BUILD_VERSION}
	docker push digitalmarketplace/base-api:${BUILD_VERSION}-${BUILD_DATE}
	docker push digitalmarketplace/base-api:latest

	docker push digitalmarketplace/base-frontend:${BUILD_VERSION}
	docker push digitalmarketplace/base-frontend:${BUILD_VERSION}-${BUILD_DATE}
	docker push digitalmarketplace/base-frontend:latest

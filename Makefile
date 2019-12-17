BUILD_VERSION := $(shell cat VERSION)

.PHONY: build
build:
	$(eval BUILD_DATE := $(shell date -u '+%Y%m%dT%H%M%SZ'))
	$(eval BUILD_ARGS := --build-arg BUILD_DATE=${BUILD_DATE} --build-arg BUILD_VERSION=${BUILD_VERSION})

	docker pull digitalmarketplace/python
	docker build --pull --cache-from digitalmarketplace/python ${BUILD_ARGS} -t digitalmarketplace/python -f python.docker .
	docker tag digitalmarketplace/python digitalmarketplace/python:${BUILD_VERSION}

	docker build -t digitalmarketplace/builder -f builder.docker .
	docker tag digitalmarketplace/builder digitalmarketplace/builder:${BUILD_VERSION}

	docker build -t digitalmarketplace/base -f base.docker .
	docker tag digitalmarketplace/base digitalmarketplace/base:${BUILD_VERSION}

	docker build -t digitalmarketplace/base-api -f api.docker .
	docker tag digitalmarketplace/base-api digitalmarketplace/base-api:${BUILD_VERSION}

	docker build -t digitalmarketplace/base-frontend -f frontend.docker .
	docker tag digitalmarketplace/base-frontend digitalmarketplace/base-frontend:${BUILD_VERSION}

.PHONY: push
push:
	$(eval BUILD_DATE := $(shell docker inspect --format '{{.Config.Labels.BUILD_DATE}}' digitalmarketplace/base))

	docker push digitalmarketplace/base:${BUILD_VERSION}
	if [ -z $$NOT_LATEST ]; then docker push digitalmarketplace/base:latest; fi

	docker push digitalmarketplace/base-api:${BUILD_VERSION}
	if [ -z $$NOT_LATEST ]; then docker push digitalmarketplace/base-api:latest; fi

	docker push digitalmarketplace/base-frontend:${BUILD_VERSION}
	if [ -z $$NOT_LATEST ]; then docker push digitalmarketplace/base-frontend:latest; fi

.PHONY: scan
scan:
	$(eval REPORTS := $(shell mktemp -d /tmp/docker-base-scan.XXX))
	$(eval export MONITOR := 'true')

	${DM_CREDENTIALS_REPO}/sops-wrapper -v > /dev/null

	docker pull digitalmarketplace/app:${BUILD_VERSION}
	./docker-scan.sh \
		-o ${REPORTS}/digitalmarketplace_app_${BUILD_VERSION} \
		digitalmarketplace/app:${BUILD_VERSION} \
		app.docker

	docker pull digitalmarketplace/base-api:${BUILD_VERSION}
	./docker-scan.sh \
		-o ${REPORTS}/digitalmarketplace_base-api_${BUILD_VERSION} \
		digitalmarketplace/base-api:${BUILD_VERSION} \
		api.docker

	docker pull digitalmarketplace/base-frontend:${BUILD_VERSION}
	./docker-scan.sh \
		-o ${REPORTS}/digitalmarketplace_base-frontend_${BUILD_VERSION} \
		digitalmarketplace/base-frontend:${BUILD_VERSION} \
		frontend.docker

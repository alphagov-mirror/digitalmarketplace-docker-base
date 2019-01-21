#!/usr/bin/env bash

colorecho()
{
	tput setaf 6
	echo "$@"
	tput sgr0
}

DOCKER_REPO="$1"
DOCKER_FILE="$2"

# create a clean directory for output files
TMPDIR="$(mktemp -d /tmp/docker-scan.XXX)"
trap 'rm -rf "${TMPDIR}"' EXIT

cp "${DOCKER_FILE}" "${TMPDIR}"
DOCKER_FILE="$(basename ${DOCKER_FILE})"

# get SNYK_TOKEN from credentials repo
eval "$(${DM_CREDENTIALS_REPO}/sops-wrapper -d ${DM_CREDENTIALS_REPO}/jenkins-vars/snyk_credentials.env)"
if [ -z "$SNYK_TOKEN" ]; then
	>&2 echo "Error: sops failed getting SNYK_TOKEN"
	exit 2
fi
SNYK_ORG="${SNYK_ORG:-digital-marketplace}"

docker run --rm \
	-e MONITOR="${MONITOR}" \
	-e SNYK_TOKEN="${SNYK_TOKEN}" \
	-v "${TMPDIR}":/project:rw \
	-v /var/run/docker.sock:/var/run/docker.sock \
	digitalmarketplace/snyk-cli:docker \
	test \
	--json \
	--org="${SNYK_ORG}" \
	--docker "${DOCKER_REPO}" \
	--file="${DOCKER_FILE}" \
	>/dev/null \
	2>/dev/null \
;
STATUS="$?"

if [ -n "${OUTDIR}" ] && [ -d "${OUTDIR}" ]; then
	echo "Copying report files to ${OUTDIR}"
	cp "${TMPDIR}/snyk_report.css" "${TMPDIR}/snyk_report.html" "${TMPDIR}/snyk-result.json" "${TMPDIR}/snyk-error.log" "${OUTDIR}"
fi

if [ $STATUS -eq 1 ]; then
	COUNT="$(jq '.uniqueCount' ${TMPDIR}/snyk-result.json)"
	colorecho "Snyk found ${COUNT} vulns in ${DOCKER_REPO}. Uh-oh!"
elif [ $STATUS -eq 0 ]; then
	colorecho "Snyk gave ${DOCKER_REPO} a clean bill of health. You're good to go!"
fi

exit 0

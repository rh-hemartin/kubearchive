#!/bin/bash
set -o errexit  # -e
set -o xtrace  # -x

# Externally provided variables
# export OCI_REPOSITORY="quay.io/hemartin"
# export RELEASE_REPOSITORY="rh-hemartin/kubearchive"

# Variables
export GIT_AUTHOR_NAME="github-actions[bot]@users.noreply.github.com"
export GIT_AUTHOR_EMAIL="github-actions[bot]"
export BRANCH=main
export KO_DOCKER_REPO="${OCI_REPOSITORY}"
export CURR_VERSION=$(cat ./VERSION)

export START_SHA=$(git rev-list -n1 ${CURR_VERSION})
export END_SHA=$(git rev-list -n1 ${BRANCH})

release-notes generate \
    --required-author="" \
    --format json \
    --output ./release-notes.json \
    --repo kubearchive --org kubearchive
go run hack/get-next-version.go \
    --release-notes-file ./release-notes.json \
    --current-version ${CURR_VERSION} > ./VERSION
export NEXT_VERSION=$(cat ./VERSION)
rm ./release-notes.json

release-notes generate \
    --required-author="" \
    --output ./release-notes.md \
    --dependencies=false \
    --repo kubearchive --org kubearchive
echo -e "# Release notes for ${NEXT_VERSION}\n" >> ./release-notes-${NEXT_VERSION}.md
cat ./release-notes.md >> ./release-notes-${NEXT_VERSION}.md
rm ./release-notes.md

git add VERSION charts/kubearchive/Chart.yaml
git commit -s -m "Release ${NEXT_VERSION}"
git tag -a "${NEXT_VERSION}" -m "Release ${NEXT_VERSION}"
git push
git push --tags

# Build and push
bash cmd/operator/generate.sh
ko build github.com/kubearchive/kubearchive/cmd/sink --base-import-paths --tags=${NEXT_VERSION}
ko build github.com/kubearchive/kubearchive/cmd/api --base-import-paths --tags=${NEXT_VERSION}
ko build github.com/kubearchive/kubearchive/cmd/operator/ --base-import-paths --tags=${NEXT_VERSION}

helm package charts/kubearchive --app-version ${NEXT_VERSION} --version ${NEXT_VERSION}
helm push kubearchive-helm-${NEXT_VERSION}.tgz oci://${OCI_REPOSITORY}

gh release create "${NEXT_VERSION}" \
    --notes-file ./release-notes-${NEXT_VERSION}.md \
    --title "Release ${NEXT_VERSION}" \
    --repo ${RELEASE_REPOSITORY}
rm ./release-notes-${NEXT_VERSION}.md

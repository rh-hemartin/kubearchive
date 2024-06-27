# Releasing KubeArchive

## Requirements/Assumptions

* Using the release-notes tool that K8s uses
* Using `kind/breaking`, `kind/documentation`, `kind/bug` and `kind/feature` labels
* Using a code markdown block with release notes:
    ```release-note
    Something that will be added to the top of the release notes.
    ```
    or
    ```release-note
    NONE
    ```
* Chart version will be manually increased or will be the same as the application
version to simplifiy the process.
* No changelog, we can link to the branch comparison on GitHub, which will correspond
to what we understand as changelog
* Release notes are for users, we can delete the dependency information too, because it
is too "developery".

## Process

This document explains what the release workflow does, step by step:

1. Clone the repository
    ```
    git clone git@github.com:kubearchive/kubearchive.git
    ```

1. Install Kubernetes' `release-notes` tool:
    ````
    mkdir bin
    GOBIN=${PWD}/bin go install k8s.io/release/cmd/release-notes@latest
    ```

1. Export some variables:
    ```
    export ORG=kubearchive
    export REPO=kubearchive
    export BRANCH=main
    export GITHUB_TOKEN="xyz"
    export CURR_VERSION=$(cat ./VERSION)
    ```

1. Generate the release notes in JSON format:
    ```
    ./bin/release-notes generate --required-author="" --start-sha=$(git rev-list -n 1 ${CURR_VERSION}) --end-sha=$(git rev-list -n 1 ${BRANCH}) --format json --output ./release-notes.json
    ```

1. Determine the version and write the new `VERSION` file:
    ```
    go run hack/get-next-version.go --release-notes-file ./release-notes.json --curent-version ${CURR_VERSION} > ./VERSION
    export NEXT_VERSION=$(cat ./VERSION)
    ```

1. Generate the markdown release notes:
    ```
    echo -e "# Release notes for ${NEXT_VERSION}\n" >> ./release-notes/${NEXT_VERSION}.md
    ./bin/release-notes generate --required-author="" --start-sha=$(git rev-list -n 1 ${CURR_VERSION}) --end-sha=$(git rev-list -n 1 ${BRANCH}) --output ./release-notes.md
    cat ./release-notes.md >> ./release-notes/${NEXT_VERSION}.md
    rm ./release-notes.md
    ```

1. Move the release notes to their folder:
    ```
    mv ./release-notes.md release-notes/${NEXT_VERSION}.md
    TODO: title this
    ```

1. Update the `appVersion` and `version` on the Helm chart:
    ```
    GOBIN=${PWD}/bin go install github.com/mikefarah/yq/v4@latest
    ./bin/yq e -i '.appVersion=env(NEXT_VERSION)' charts/kubearchive/Chart.yaml
    ./bin/yq e -i '.version=env(NEXT_VERSION)' charts/kubearchive/Chart.yaml
    ```

**Note**: maintaing a different version for the Helm chart complicates the whole
release version calculation (what it is a helm change vs what it is not), for the sake
of simplicity we go with the same version.

1. Add and commit
    ```
    git add .
    git commit -s -m "Release ${NEXT_VERSION}"
    git tag -a "${NEXT_VERSION}" -m "Release ${NEXT_VERSION}"
    git push
    git push --tags
    ```

    Commited files:
    ```
    charts/kubearchive/Chart.yaml
    VERSION
    release-notes/${NEXT_VERSION}.md
    ```

1. Build the images with `ko`:
    ```
    
    export KO_DOCKER_REPO="quay.io/kubearchive"
    ko build github.com/kubearchive/kubearchive/cmd/sink --tags=${NEXT_VERSION}
    ko build github.com/kubearchive/kubearchive/cmd/api --tags=${NEXT_VERSION}
    ko build github.com/kubearchive/kubearchive/operator/cmd/ --tags=${NEXT_VERSION}
    ```

1. Build the helm chart:
    ```
    helm package charts/kubearchive
    helm push kubearchive-helm-${VERSION}.tgz oci://quay.io/kubearchive
    ```

1. Create the GitHub release from the tag with the release notes.
    ```
    gh release create "${NEXT_VERSION}" --notes-file ./release-notes/${NEXT_VERSION}.md --title "Release ${NEXT_VERSION}"
    ```
    **Note**: we can use this command to upload artifacts (maybe the SHAs of images,
    or something like that for validation)

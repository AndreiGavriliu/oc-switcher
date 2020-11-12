#!/bin/bash

# default config file location
OC_SWITCHER_CONFIG="${HOME}/.oc-switcher"

# add some color
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
NOCOLOR='\033[0m'

# shellcheck disable=SC1090
source "${OC_SWITCHER_CONFIG}"

# check if config file contains required varilables
if [ -z "$OC_REPOSITORY" ]; then
    echo -e "${YELLOW}WARNING:${NOCOLOR}"
    echo -e "    OC_REPOSITORY variable is not set."
    echo -en "    Adding default \"/usr/local/bin\" to ${OC_SWITCHER_CONFIG} ... "
    echo "OC_REPOSITORY=\"/usr/local/bin\" # path where you store your oc clients (e.g.: $HOME/scripts)" >> "${OC_SWITCHER_CONFIG}"
    echo -e "${GREEN}done${NOCOLOR}"
    # shellcheck disable=SC1090
    source "${OC_SWITCHER_CONFIG}"
fi
if [ -z "$OC_PREFIX" ]; then
    echo -e "${YELLOW}WARNING:${NOCOLOR}"
    echo -e "    OC_PREFIX variable is not set."
    echo -en "    Adding default \"openshift-oc-client-\" to ${OC_SWITCHER_CONFIG} ... "
    echo "OC_PREFIX=\"openshift-oc-client-\" # how do we know how to find them (e.g: openshift-oc-client-)" >> "${OC_SWITCHER_CONFIG}"
    echo -e "${GREEN}done${NOCOLOR}"
    # shellcheck disable=SC1090
    source "${OC_SWITCHER_CONFIG}"
fi
if [ -z "$OC_PATH" ]; then
    echo -e "${YELLOW}WARNING:${NOCOLOR}"
    echo -e "    OC_PATH variable is not set."
    echo -en "    Adding default \"/usr/local/bin\" to ${OC_SWITCHER_CONFIG} ... "
    echo "OC_PATH=\"/usr/local/bin\" # where do we create the symlink (must be somehwere in your PATH $PATH)" >> "${OC_SWITCHER_CONFIG}"
    echo -e "${GREEN}done${NOCOLOR}"
    # shellcheck disable=SC1090
    source "${OC_SWITCHER_CONFIG}"
fi

# shellcheck disable=SC1090
source "${OC_SWITCHER_CONFIG}"

# commands
OC_NEW_VERSION=${1}
OC_VERSIONS=$(find "${OC_REPOSITORY}" -maxdepth 1 -name "${OC_PREFIX}*" | awk -F/ '{print $NF}' | sort)
OC_CURRENT_VERSION=$(readlink "${OC_PATH}/oc")
OC_CHECK_TYPE=$(type -t oc)

# basic help mesage
function _usage {
    echo "usage: $0 <new_version>"
    echo ""
    _get_current_version
    echo ""
    _get_oc_versions
    echo ""
    exit 1
}

# get current version
function _get_current_version {
    if [ "${OC_CHECK_TYPE}" ]; then
        if [ "${OC_CHECK_TYPE}" == "file" ]; then
            echo -e "Currently running ${GREEN}${OC_CURRENT_VERSION}${NOCOLOR}"
        fi
        if [ "${OC_CHECK_TYPE}" == "alias" ]; then
            echo "Found an alias"
            unalias oc
            echo "'tis no more, we have removed it."
        fi
    fi
}

# get installed oc client versions
function _get_oc_versions {
    echo "Found the following oc-client versions in ${OC_REPOSITORY}:"
    for OC_VERSION in ${OC_VERSIONS}; do
        OC_VERSION="${OC_VERSION/$OC_PREFIX}"
        echo -n "=> "
        echo -e "${YELLOW}${OC_VERSION}${NOCOLOR}"
    done
    echo ""
    echo "To download a new version run eg. <oc-switcher v4.6.1>. I will try to find it and download it for you."
}

# add alias to bash profile
function _update_version {
    OC_REPOSITORY_FILE=${OC_REPOSITORY}/${OC_PREFIX}${OC_NEW_VERSION}
    OC_NEW_MAJOR_VERSION=$(echo "${OC_NEW_VERSION}" | cut -d. -f1)
    OC_NEW_VERSION=$(echo "${OC_NEW_VERSION}" | tr -d v)
    case $(uname -s) in
        Linux*)     OC_CLIENT_OS=linux;;
        Darwin*)    OC_CLIENT_OS=mac;;
        *)          OC_CLIENT_OS="UNKNOWN"
    esac
    if [ -f "$OC_REPOSITORY_FILE" ]; then
        echo -ne "Adding version ${YELLOW}${OC_NEW_VERSION}${NOCOLOR} "
        ln -sf "${OC_REPOSITORY_FILE}" "${OC_PATH}/oc"
        echo -e "....... ${GREEN}done${NOCOLOR}"
        # enable_bash_completion
    else
        echo "Version not available."
        # check if version is available online
        RESPONSE=$(curl --write-out '%{http_code}' --silent --output /dev/null "https://mirror.openshift.com/pub/openshift-${OC_NEW_MAJOR_VERSION}/clients/ocp/${OC_NEW_VERSION}/")
        # version is available
        if [ "${RESPONSE}" = "200" ]
        then
            echo "Requested version found online"
            # create temp folder
            mkdir -p /tmp/oc-switcher
            # switch to temp location
            cd /tmp/oc-switcher || exit
            # download file to temp location
            echo "Downloading file"
            curl --silent "https://mirror.openshift.com/pub/openshift-${OC_NEW_MAJOR_VERSION}/clients/ocp/${OC_NEW_VERSION}/openshift-client-${OC_CLIENT_OS}-${OC_NEW_VERSION}.tar.gz" -o "openshift-client-${OC_CLIENT_OS}-${OC_NEW_VERSION}.tar.gz"
            # extract file
            tar xf "/tmp/oc-switcher/openshift-client-${OC_CLIENT_OS}-${OC_NEW_VERSION}.tar.gz"
            # rename client
            mv "oc" "openshift-oc-client-v${OC_NEW_VERSION}"
            # move client to repository location
            echo "Moving oc-client to ${OC_REPOSITORY}"
            mv "openshift-oc-client-v${OC_NEW_VERSION}" "${OC_REPOSITORY}/openshift-oc-client-v${OC_NEW_VERSION}"
            # remove temporary folder
            rm -fr /tmp/oc-switcher
            echo "Done"
        else
            echo "No client with this version found"
        fi
        # echo $RESPONSE
    fi
}

# update version
if [ "${OC_NEW_VERSION}" ]
then
    _update_version "${OC_NEW_VERSION}"
fi

# show usage if no arguments provided
if [ -z "${1}" ]; then
    _usage
fi

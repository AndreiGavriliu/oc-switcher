#!/bin/bash

OC_SWITCHER_CONFIG="${HOME}/.oc-switcher"

# add some color
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[0;31m'
NOCOLOR='\033[0m'

# check if config file exists
if ! test -f "${OC_SWITCHER_CONFIG}"; then
    echo -e "${YELLOW}Warning:${NOCOLOR}"
    echo -e "    Config file ${OC_SWITCHER_CONFIG} not found"
    echo -en "    Creating a new one ... "
    echo "OC_REPOSITORY=\"/usr/local/bin\" # path where you store your oc clients (e.g.: $HOME/scripts)" > ${OC_SWITCHER_CONFIG}
    echo "OC_PREFIX=\"openshift-oc-client-\" # how do we know how to find them (e.g: openshift-oc-client-)" >> ${OC_SWITCHER_CONFIG}
    echo "OC_PATH=\"/usr/local/bin\" # where do we create the symlink (must be somehwere in your PATH $PATH)" >> ${OC_SWITCHER_CONFIG}
    echo -e "${GREEN}done${NOCOLOR}"
    echo -e ""
fi

# source config
source ${OC_SWITCHER_CONFIG}

# commands
OC_NEW_VERSION=$1
OC_VERSIONS=`ls ${OC_REPOSITORY} | grep ${OC_PREFIX} | sort -r`
OC_CURRENT_VERSION=`readlink ${OC_PATH}/oc`
OC_CHECK_TYPE=`type -t oc`

# check if config file contains required varilables
if [ -z "$OC_REPOSITORY" ]; then
    echo -e "${RED}ERROR:${NOCOLOR}"
    echo -e "    OC_REPOSITORY variable is not set"
fi
if [ -z "$OC_PREFIX" ]; then
    echo -e "${RED}ERROR:${NOCOLOR}"
    echo -e "    OC_PREFIX variable is not set"
fi
if [ -z "$OC_PATH" ]; then
    echo -e "${RED}ERROR:${NOCOLOR}"
    echo -e "    OC_PATH variable is not set"
fi

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
    if [ $OC_CHECK_TYPE ]; then
        if [ $OC_CHECK_TYPE == "file" ]; then
            echo -e "Currently running ${GREEN}${OC_CURRENT_VERSION}${NOCOLOR}"
        fi
        if [ $OC_CHECK_TYPE == "alias" ]; then
            echo "Found an alias"
            unalias oc
            echo "'tis no more, we have removed it."
        fi
    fi
}

# get installed oc client versions
function _get_oc_versions {
    echo "Found the following oc-client versions in ${OC_REPOSITORY}:"
    for OC_VERSION in $OC_VERSIONS; do
        OC_VERSION=${OC_VERSION/$OC_PREFIX}
        echo -n "=> "
        echo -e "${YELLOW}${OC_VERSION}${NOCOLOR}"
    done
}

# add alias to bash profile
function _update_version {
    OC_REPOSITORY_FILE=${OC_REPOSITORY}/${OC_PREFIX}${OC_NEW_VERSION}
    if [ -f "$OC_REPOSITORY_FILE" ]; then
        echo -ne "Adding version ${YELLOW}${OC_NEW_VERSION}${NOCOLOR} "
        ln -sf "$OC_REPOSITORY_FILE" $OC_PATH/oc
        echo -e "....... ${GREEN}done${NOCOLOR}"
        # enable_bash_completion
    else
        echo "Version not available."
        echo ""
        _get_oc_versions
    fi
}

# update version
if [ $OC_NEW_VERSION ]
then
    _update_version $OC_NEW_VERSION
fi

# show usage if no arguments provided
if [ -z $1 ]; then
    _usage
fi

#!/bin/bash

# ============================================================================================
# title         : oc-switcher.sh
# description   : The following script helps manage multiple OpenShift oc client versions. It
#                 creates a symlink of the oc client of your choice to a location within
#                 $PATH location. 
# author        : Andrei Gavriliu
# date          : 2019-12-13
# version       : 0.1
# usage         : bash oc-switcher.sh <new_version>
# ============================================================================================

OC_REPOSITORY="$HOME/scripts"       # path where you store your oc clients (e.g.: $HOME/scripts)
OC_PREFIX="openshift-oc-client-"    # how do we know how to find them (e.g: openshift-oc-client-)
OC_PATH="/usr/local/bin"            # where do we create the symlink (must be in $PATH)

OC_NEW_VERSION=$1
OC_VERSIONS=`ls ${OC_REPOSITORY} | grep ${OC_PREFIX} | sort -r`
OC_CURRENT_VERSION=`readlink ${OC_PATH}/oc`
OC_CHECK_TYPE=`type -t oc`

# basic help mesage
function usage {
    echo "usage: $0 <new_version>"
    get_current_version
    echo ""
    get_OC_VERSIONS
    echo ""
    exit 1
}

# get current version
function get_current_version {
    if [ $OC_CHECK_TYPE ]; then
        if [ $OC_CHECK_TYPE == "file" ]; then
            echo "Currently running ${OC_CURRENT_VERSION}"
        fi
        if [ $OC_CHECK_TYPE == "alias" ]; then
            echo "Found an alias"
            unalias oc
            echo "'tis no more, we have removed it."
        fi
    fi
}

# get installed oc client versions
function get_OC_VERSIONS {
    echo "Found the following oc-client versions in ${OC_REPOSITORY}:"
    for OC_VERSION in $OC_VERSIONS; do
        OC_VERSION=${OC_VERSION/$OC_PREFIX}
        echo "=> ${OC_VERSION}"
    done
}

# add alias to bash profile
function update_version {
    OC_REPOSITORY_FILE=${OC_REPOSITORY}/${OC_PREFIX}${OC_NEW_VERSION}
    if [ -f "$OC_REPOSITORY_FILE" ]; then
        echo -e "Adding version ${OC_NEW_VERSION}"
        ln -sf "$OC_REPOSITORY_FILE" $OC_PATH/oc
        echo "... done"
    else
        echo "Version not available."
        echo ""
        get_OC_VERSIONS
    fi
}

# update version
if [ $OC_NEW_VERSION ]
then
    update_version $OC_NEW_VERSION
fi

# show usage if no arguments provided
if [ -z $1 ]; then
    usage
fi

#!/bin/bash

function ssh_agent_add() {
    local LATEST
    local MONIKER
    local PREFIX
    PREFIX=$1
    if [ -z "$PREFIX" ]; then
        echo "SSH key name prefix is required."
        return
    fi
    MONIKER=$2
    if [ -z "$MONIKER" ]; then
        echo "SSH key moniker is required."
        return
    fi
    LATEST=$(gfind ~/.ssh -name "${PREFIX}-*-${MONIKER}" | grep -v -e .pub -e latest | sort -r | head -n 1 | xargs basename)
    if [ -z "$LATEST" ]; then
        echo "No matching SSH key found for ${PREFIX}-*-${MONIKER}"
        return
    fi
    echo "Latest SSH identity file is: ${LATEST}"
    ssh-add --apple-use-keychain ~/.ssh/"${LATEST}"
}

function ssh_agent_cleanup() {
    local LATEST
    local MONIKER
    local PREFIX
    PREFIX=$1
    if [ -z "$PREFIX" ]; then
        echo "SSH key name prefix is required."
        return
    fi
    MONIKER=$2
    if [ -z "$MONIKER" ]; then
        echo "SSH key moniker is required."
        return
    fi
    LATEST=$(gfind ~/.ssh -name "${PREFIX}-*-${MONIKER}" | grep -v -e .pub -e latest | sort -r | head -n 1 | xargs basename)
    if [ -z "$LATEST" ]; then
        LATEST="foo" # we just need something to prevent bad input to grep below
    fi
    echo "Latest SSH identity file is: ${LATEST}"
    for IDENT in $(ssh-add -l | \
        grep "${PREFIX}-.*${MONIKER}" | \
        grep -v "${LATEST}" | \
        awk '{print $3}'); do
        echo "Purgine identity file from ssh-agent: ${IDENT}"
        ssh-add -d ~/.ssh/"${IDENT}"
    done
}

function ssh_create_key() {
    local DATE
    local FILENAME
    local MONIKER
    local PREFIX
    PREFIX=$1
    if [ -z "$PREFIX" ]; then
        echo "SSH key name prefix is required."
        return
    fi
    MONIKER=$2
    if [ -z "$MONIKER" ]; then
        echo "SSH key moniker is required."
        return
    fi
    DATE=$(date +%F)
    FILENAME="${PREFIX}-${DATE}-${MONIKER}"
    echo "Generating identity file: ~/.ssh/${IDENT}"
    ssh-keygen -t rsa -b 2048 -C "${FILENAME}" -f ~/.ssh/"${FILENAME}"
}

function ssh_link_latest() {
    local FILENAME
    local LATEST
    local MONIKER
    local PREFIX
    PREFIX=$1
    if [ -z "$PREFIX" ]; then
        echo "SSH key name prefix is required."
        return
    fi
    MONIKER=$2
    if [ -z "$MONIKER" ]; then
        echo "SSH key moniker is required."
        return
    fi
    FILENAME=$(gfind ~/.ssh -name "${PREFIX}-*-${MONIKER}" | grep -v -e .pub -e latest | sort -r | head -n 1)
    if [ -z "$FILENAME" ]; then
        echo "No matching SSH key found for ${PREFIX}-*-${MONIKER}"
        return
    fi
    LATEST="${PREFIX}-latest-${MONIKER}"
    ln -sf "${FILENAME}" ~/.ssh/"${LATEST}"
    ln -sf "${FILENAME}.pub" ~/.ssh/"${LATEST}".pub
}

ssh_print_fingerprint() {
    local FILENAME
    local LATEST
    local MONIKER
    local PREFIX
    PREFIX=$1
    if [ -z "$PREFIX" ]; then
        echo "SSH key name prefix is required."
        return
    fi
    MONIKER=$2
    if [ -z "$MONIKER" ]; then
        echo "SSH key moniker is required."
        return
    fi
    FILENAME=$(gfind ~/.ssh/ -name "${PREFIX}-*-${MONIKER}" | grep -v -e .pub -e latest | sort -r | head -n 1 | xargs basename)
    if [ -z "$FILENAME" ]; then
        echo "No matching SSH key found for ${PREFIX}-*-${MONIKER}"
        return
    fi
    ssh-keygen -l -f ~/.ssh/"${FILENAME}".pub
}

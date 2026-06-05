#!/bin/bash

function ssh_agent_add() {
    local latest
    local moniker
    local prefix
    prefix=$1
    if [ -z "$prefix" ]; then
        echo "SSH key name prefix is required."
        return
    fi
    moniker=$2
    if [ -z "$moniker" ]; then
        echo "SSH key moniker is required."
        return
    fi
    latest=$(gfind ~/.ssh -name "${prefix}_${moniker}_*" | grep -v -e .pub -e latest | sort -r | head -n 1 | xargs basename)
    if [ -z "$latest" ]; then
        echo "No matching SSH key found for ${prefix}_${moniker}_*"
        return
    fi
    echo "Latest SSH identity file is: ${latest}"
    ssh-add --apple-use-keychain ~/.ssh/"${latest}"
}

function ssh_agent_cleanup() {
    local latest
    local moniker
    local prefix
    prefix=$1
    if [ -z "$prefix" ]; then
        echo "SSH key name prefix is required."
        return
    fi
    moniker=$2
    if [ -z "$moniker" ]; then
        echo "SSH key moniker is required."
        return
    fi
    latest=$(gfind ~/.ssh -name "${prefix}_${moniker}_*" | grep -v -e .pub -e latest | sort -r | head -n 1 | xargs basename)
    if [ -z "$latest" ]; then
        latest="foo" # we just need something to prevent bad input to grep below
    fi
    echo "Latest SSH identity file is: ${latest}"
    for identity in $(ssh-add -l | \
        grep "${prefix}_${moniker}_.*" | \
        grep -v "${latest}" | \
        awk '{print $3}'); do
        echo "Purging identity file from ssh-agent: ${identity}"
        ssh-add -d ~/.ssh/"${identity}"
    done
}

function ssh_create_key() {
    local date
    local filename
    local moniker
    local prefix
    prefix=$1
    if [ -z "$prefix" ]; then
        echo "SSH key name prefix is required."
        return
    fi
    moniker=$2
    if [ -z "$moniker" ]; then
        echo "SSH key moniker is required."
        return
    fi
    date=$(date +%F)
    filename="${prefix}_${moniker}_${date}"
    echo "Generating identity file: ~/.ssh/${filename}"
    ssh-keygen -t rsa -b 2048 -C "${filename}" -f ~/.ssh/"${filename}"
}

function ssh_link_latest() {
    local filename
    local latest
    local moniker
    local prefix
    prefix=$1
    if [ -z "$prefix" ]; then
        echo "SSH key name prefix is required."
        return
    fi
    moniker=$2
    if [ -z "$moniker" ]; then
        echo "SSH key moniker is required."
        return
    fi
    filename=$(gfind ~/.ssh -name "${prefix}_${moniker}_*" | grep -v -e .pub -e latest | sort -r | head -n 1)
    if [ -z "$filename" ]; then
        echo "No matching SSH key found for ${prefix}_${moniker}_*"
        return
    fi
    latest="${prefix}_${moniker}_latest"
    ln -sf "${filename}" ~/.ssh/"${latest}"
    ln -sf "${filename}.pub" ~/.ssh/"${latest}".pub
}

ssh_print_fingerprint() {
    local filename
    local moniker
    local prefix
    prefix=$1
    if [ -z "$prefix" ]; then
        echo "SSH key name prefix is required."
        return
    fi
    moniker=$2
    if [ -z "$moniker" ]; then
        echo "SSH key moniker is required."
        return
    fi
    filename=$(gfind ~/.ssh/ -name "${prefix}_${moniker}_*" | grep -v -e .pub -e latest | sort -r | head -n 1 | xargs basename)
    if [ -z "$filename" ]; then
        echo "No matching SSH key found for ${prefix}_${moniker}_*"
        return
    fi
    ssh-keygen -l -f ~/.ssh/"${filename}".pub
}

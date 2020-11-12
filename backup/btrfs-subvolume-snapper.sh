#!/usr/bin/env bash

src="${1}";
option="${2}";
date=$(date +%Y-%m-%d);

function usage() {
   echo "USAGE";
   exit 1;
}

function err() { 
   echo "$@" 1>&2;
}

function is_btrfs_subvolume() {
    btrfs subvolume show "$1" >/dev/null 2>&1
}

# check if dir exist
if [ ! -d "${src}" ]; then
        err "${src} does not exist!";
        usage;
fi


if [ ! -d "${src}/current" ]; then
        err "${src} does not contains current/";
        usage;
fi


if ! is_btrfs_subvolume "${src}/current"; then
        err "${src}/current is not btrfs subvolume";
        usage;
fi


if [ -d "${src}/${date}" ]; then
        if [[ "${option}" == "-f" ]]; then
                btrfs subvolume delete "${src}/${date}";
        else
                err "${src}/${date} already exist!";
                usage;
        fi
fi

btrfs subvolume snapshot "${src}/current/" "${src}/${date}";

existing_snapshots=($(ls "${src}/" | grep -v current | sort));
existing_snapshots_count="${#existing_snapshots[@]}";
treshold="30";
number_to_remove=$((existing_snapshots_count - treshold)); 
for (( i=0; i<number_to_remove; i++ )); do
        echo "${existing_snapshots[$i]}";
        btrfs subvolume delete "${src}/${existing_snapshots[$i]}";
done

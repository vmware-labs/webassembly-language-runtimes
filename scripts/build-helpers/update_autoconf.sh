#!/usr/bin/env bash

logStatus "Downloading latest config.guess and config.sub ... "

if [[ ! -f config.guess && "$1" != "--force" ]]
then
    wget -T 5 -O config.guess 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD' ||
        wget -T 5 -O config.guess https://cdn.jsdelivr.net/gh/gcc-mirror/gcc@master/config.guess ||
        wget -T 5 -O config.guess https://raw.githubusercontent.com/gcc-mirror/gcc/master/config.guess || exit 1

    chmod +x config.guess
fi

if [[ ! -f config.sub && "$1" != "--force" ]]
then
    wget -T 5 -O config.sub 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD' ||
        wget -T 5 -O config.sub https://cdn.jsdelivr.net/gh/gcc-mirror/gcc@master/config.sub ||
        wget -T 5 -O config.sub https://raw.githubusercontent.com/gcc-mirror/gcc/master/config.sub  || exit 1

    chmod +x config.sub
fi
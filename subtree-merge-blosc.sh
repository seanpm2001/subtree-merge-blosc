#!/bin/sh

# Script to automatically subtree merge a specifc version of blosc.

# TODO
# ----
#
# * Should probably check working tree and index are clean.
# * Check if we are in the top-level directory
# * Version number
# * Lisence
# * Author
# * Switch for alternate -Xsubtree -Xtheirs strategy
# * Hyperlink to script repository

# configure remote
remote="git://github.com/Blosc/c-blosc.git"
# regular expression for tag
tag_regex="^v[0-9]*\.[0-9]*\.[0-9]*$"

fatal () {
    echo $1
    exit 1
}

# check argument
if [ -z "$1" ] ; then
    fatal "usage: subtree-merge-blosc.sh <blosc-tag>"
fi

# check c-blosc subdirectory exists
if ! [ -d "c-blosc" ] ; then
    fatal "'c-blosc' subdirectory doesn't exist"
fi

# extract the blosc tag the user has requested
blosc_tag="$1"

# check that the tag is sane
if ! echo $blosc_tag | grep -q $tag_regex ; then
    fatal "Tag: '$1' doesn't match regex '$tag_regex'"
fi
blosc_tag_long="refs/tags/$1"

# check that it exists on the remote side
remote_ans=$( git ls-remote $remote $blosc_tag_long )
if [ -z "$remote_ans" ] ; then
    fatal "no remote tag '$1' found"
else
    echo "found remote tag: '$remote_ans'"
fi

# fetch the contents of this tag
git fetch $remote $blosc_tag_long || exit 1
# subtree merge it
git merge --squash -s subtree FETCH_HEAD || exit 1
if git diff --staged --quiet ; then
    fatal "nothing new to be committed"
else
    # set a custom commit message
    git commit -m "subtree merge blosc $blosc_tag" || exit 1
fi

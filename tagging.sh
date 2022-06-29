#!/bin/bash

#=======================================================================
# This command is used to help us generate the
# console command to deploy release or hotfix
#
# Sources:
#      https://danielkummer.github.io/git-flow-cheatsheet/index.html
#      https://gist.github.com/JamesMGreene/cdd0ac49f90c987e45ac
#=======================================================================

mainBranch="master"
devBranch="develop"

function dirty() {
    if [ $(git diff --name-only) ]; then
        echo "
        YOU HAVE UNCOMMITTED FILES, PLEASE CHECK!
        "
        exit 1
    fi
}

function print() {

    if [ "$1" != "release" ] && [ "$1" != "hotfix" ]; then
        echo "First argument must be release or hotfix!"
        exit 1
    fi

    if [ -z $2 ]; then
        echo "Provide the second param as the TAG version"
        exit 1
    fi

    echo "
git fetch

git checkout $mainBranch
git branch $devBranch -D
git checkout $devBranch
git branch $mainBranch -D
git checkout $mainBranch

git branch | grep release\* | xargs git branch -D
git branch | grep hotfix\* | xargs git branch -D

git tag -l | xargs git tag -d
git fetch --tags
"

    if [ "$1" = "release" ]; then
    echo "
git flow $1 start $2
git flow $1 publish $2
"
    fi

    if [ "$1" = "hotfix" ]; then
    echo "
git branch $1/$2 -D
git checkout $1/$2
"
    fi

    echo "
git checkout $mainBranch
git merge --no-ff --no-edit $1/$2
git tag -a $2 -m "$2"
git checkout $devBranch
git merge --no-ff --no-edit $2
git push origin $devBranch
git push origin $mainBranch
git push origin --tags
git branch -d $1/$2
"

    if [ "$1" = "release" ]; then
    echo "
git push origin -d $1/$2
"
    fi
}

dirty
print "$1" "$2"

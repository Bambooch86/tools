#!/bin/bash

listfile=$1
origindir=$(pwd)

while read LINE
do
    cd $LINE
    git add -A
    proname=$(basename $LINE)
    git commit -m "Init $proname"
    git push origin HEAD:lollipop
    cd $origindir
done < $listfile

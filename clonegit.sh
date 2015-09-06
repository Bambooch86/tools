#!/bin/bash

listfile=$1
prevurl=$2

while read LINE
do
    git clone $prevurl/$LINE $LINE
done < $listfile

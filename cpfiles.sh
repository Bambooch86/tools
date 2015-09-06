#!/bin/bash

listfile=$1
srcdir=$2

while read LINE
do
    mv $srcdir/$LINE/* $LINE
done < $listfile

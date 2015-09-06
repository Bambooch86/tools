#!/bin/bash

listfile=$1

while read LINE
do
    git init --bare $LINE
done < $listfile

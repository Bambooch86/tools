#!/bin/bash

DATE_STR=$(date +%Y%m%d)
BRANCH_LIST_FILE="/home/builder/branch.list"
PRODUCTS_DIR="/home/builder/products"

# for build branch
function build_branch()
{
    BRANCH_NAME=$1
    PROJ_NAME="${BRANCH_NAME}-${DATE_STR}"
    PROJ_DIR="${PRODUCTS_DIR=}/${PROJ_NAME}"
    IMGS_DIR="${PROJ_DIR}/out/target/product/armor"
    UPDATE_DIR="/home/fourtech-release/${PROJ_NAME}"

    rm -rf "${UPDATE_DIR}"
    cd "$PROJ_DIR"

    # sync
    repo sync

    # begin build
    . build/envsetup.sh
    lunch armor-userdebug

    make -j8

    # begin copy
    mkdir "${UPDATE_DIR}"
    cd "${UPDATE_DIR}"

    git clone git:mstar/release/update -b armor
    rm -rf update/.git

    cp "${IMGS_DIR}/boot.img" "${IMGS_DIR}/recovery.img" "${IMGS_DIR}/system.img.lzo" "${UPDATE_DIR}/update/images"

    # compress update
    7z a "${PROJ_NAME}.7z" update

}


#######################
#  build branch list  #
#######################
while read LINE
do
    build_branch "$LINE"
done < $BRANCH_LIST_FILE

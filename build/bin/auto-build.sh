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

    mkdir "$PROJ_DIR"
    cd "$PROJ_DIR"

    # repo init
    repo init -u git:mstar/platform/manifest.git --repo-url=git:git-repo.git -b "$BRANCH_NAME"
    repo sync

    rm -rf packages/apps/Camera/
    rm -rf packages/apps/Gallery2/

    # begin build
    . build/envsetup.sh
    lunch armor-userdebug

    make -j8 update-api
    make -j8
    repo sync packages/apps/Camera/
    repo sync packages/apps/Gallery2/
    mmm packages/apps/Camera/jni/
    mmm packages/apps/Gallery2/jni/
    mmm packages/apps/Gallery2/gallerycommon/
    mmm packages/apps/Gallery2/
    mmm frameworks/thirdparties/

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

##########################################
# remove the directory make 4 day before #
##########################################
find "${PRODUCTS_DIR}" -mindepth 1 -maxdepth 1 -type d -mtime +3 -exec rm -rf "{}" \;

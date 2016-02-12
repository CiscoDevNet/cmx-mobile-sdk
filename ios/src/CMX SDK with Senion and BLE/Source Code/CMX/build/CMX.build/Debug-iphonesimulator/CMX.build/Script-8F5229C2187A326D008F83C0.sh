#!/bin/sh
if [ ${CONFIGURATION} == "Release" ]; then
APPLEDOC_PATH=`which appledoc`
if [ $APPLEDOC_PATH ]; then
$APPLEDOC_PATH \
--project-name "Cisco CMX SDK v0.9" \
--project-company "Cisco" \
--company-id "com.cisco.documentation" \
--docset-bundle-name "Cisco CMX SDK v0.9" \
--logformat xcode \
--merge-categories \
--docset-platform-family iphoneos \
--ignore .m \
--ignore "CMXMenuItem.h" \
--ignore "CMXShapeView.h" \
--ignore "NSString+URLEncoding.h" \
--ignore "SvgToUIImage.h" \
--ignore "SMXMLDocument.h" \
--ignore "CMXLoadingView.h" \
--output ${PRODUCT_NAME}Docs \
--keep-undocumented-objects \
--keep-undocumented-members \
--keep-intermediate-files \
--no-repeat-first-par \
--no-warn-invalid-crossref \
--exit-threshold 2 \
--index-desc "${PROJECT_DIR}/readme.markdown" \
"${PROJECT_DIR}"
fi;
fi;

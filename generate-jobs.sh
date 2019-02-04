#!/bin/bash

INPUT_FILE=$1
TEMPLATE_FILE=$2
DRY_RUN=$3
OUT_DIR="$(pwd)/output"

[[ $# -lt 2 ]] && { echo -e "ERROR: Not enough arguments. \nExapmle: $0 buckets.csv my_template.yaml"; exit 1; }

DRY_RUN=${DRY_RUN:=false}
if [ ${DRY_RUN} == 'true' ]; then
  echo "Dry-run flag found. This srcript won't run any jobs but only generate the files."
fi

[[ -d ${OUT_DIR} ]] || mkdir -p ${OUT_DIR}
[[ -f ${INPUT_FILE} ]] || { echo "ERROR: Input file doesn't exist or can't be read.";  exit 1; }
[[ -f ${TEMPLATE_FILE} ]] || { echo "ERROR: Template file doesn't exist or can't be read.";  exit 1; }

K=0
G=0
while read -r line; do
  # 1st column - source bucket
  # 2nd column - destination bucket
  # 3rd column - AWS_ACCESS_KEY_ID
  # 4th column - AWS_SECRET_ACCESS_KEY
  # 5th column - k8s namespace
  S3_SRC=$(echo "$line" | cut -d";" -f1)
  S3_DEST=$(echo "$line" | cut -d";" -f2)
  S3_USER_KEY=$(echo "$line" | cut -d";" -f3)
  S3_USER_SECRET_KEY=$(echo "$line" | cut -d";" -f4)
  K8S_NS=$(echo "$line" | cut -d";" -f5)
  NEW_JOB_FILE="${OUT_DIR}/${S3_SRC}-job.yaml"
  cp -f ${TEMPLATE_FILE} ${NEW_JOB_FILE}
  echo "Processing file ${NEW_JOB_FILE}.."
  sed -i '' "s|_S3_SRC_BUCKET_|${S3_SRC}|g" ${NEW_JOB_FILE}
  sed -i '' "s|_S3_DEST_BUCKET_|${S3_DEST}|g" ${NEW_JOB_FILE}
  sed -i '' "s|_S3_SRC_USER_KEY_ID_|${S3_USER_KEY}|g" ${NEW_JOB_FILE}
  sed -i '' "s|_S3_SRC_USER_SECRET_KEY_|${S3_USER_SECRET_KEY}|g" ${NEW_JOB_FILE}
  sed -i '' "s|_NAMESPACE_|${K8S_NS}|g" ${NEW_JOB_FILE}
  ((K++))
  if [ ${DRY_RUN} == 'false' ]; then
    kubectl create -f ${NEW_JOB_FILE}
    [[ $? -eq 0 ]] && ((G++))
  fi
done < "${INPUT_FILE}"
echo -e "Processing completed.\n- Files generated: ${K}.\n- Jobs launched: ${G}."

[[ ${DRY_RUN} == 'false' ]] && { sleep 5s; kubectl -n "${K8S_NS}" get jobs; kubectl -n "${K8S_NS}" get pods; }

#!/usr/bin/env bash

# re-assigning to local variables
S3_SRC_BUCKET=${S3_SRC_BUCKET}
S3_SRC_USER_KEY_ID=${S3_SRC_USER_KEY_ID}
S3_SRC_USER_SECRET_KEY=${S3_SRC_USER_SECRET_KEY}
S3_DEST_BUCKET=${S3_DEST_BUCKET}
DEFAULT_REGION=${DEFAULT_REGION:=ap-southeast-2}
PREFIX=${PREFIX}

# creating AWS profile
AWS_DIR="/$(whoami)/.aws"
mkdir -p ${AWS_DIR}
AWS_FILE="${AWS_DIR}/credentials"
echo "[default]" > "${AWS_FILE}"
echo "aws_access_key_id=${S3_SRC_USER_KEY_ID}" >> "${AWS_FILE}"
echo "aws_secret_access_key=${S3_SRC_USER_SECRET_KEY}" >> "${AWS_FILE}"
echo "region=${DEFAULT_REGION}" >> "${AWS_FILE}"

# checking if we have everything set
[[ -z ${S3_SRC_BUCKET} ]] && { echo "Missing source bucket."; exit 1; }
[[ -z ${S3_DEST_BUCKET} ]] && { echo "Missing destination bucket."; exit 2; }
[[ -z ${S3_SRC_USER_KEY_ID} ]] && { echo "Missing AWS_ACCESS_KEY_ID."; exit 3; }
[[ -z ${S3_SRC_USER_SECRET_KEY} ]] && { echo "Missing AWS_SECRET_ACCESS_KEY."; exit 4; }

# flag " --acl bucket-owner-full-control" is required,
# otherwise the owner of the destination bucket won't be able to access the files (except delete them)
aws s3 sync --acl bucket-owner-full-control "s3://${S3_SRC_BUCKET}" "s3://${S3_DEST_BUCKET}/${PREFIX}${S3_SRC_BUCKET}"

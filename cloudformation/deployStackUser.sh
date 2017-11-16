#!/usr/bin/env bash
set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline


# Set magic variables for current file, directory, os, etc.
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"

if [ $# -ne 2 ]; then
    echo "$0: usage: ${__base} {stack_template.json} {piloto|dev|qa|pre|pro})"
    exit 1
fi

param1="$1"
param2="$2"
list=(pilot dev qa pre pro)

if [ ${param1##*.} == "json" ] || [ ${param1##*.} == "yaml" ]; then
    STACK_FILE=${param1%.*}
    CF_STACK=$(basename ${STACK_FILE})
    CF_TYPE=${param1##*.}
fi

if [[ " ${list[@]} " =~ " ${param2} " ]]; then
    CF_ENVIRONMENT=$param2
fi

if [ -z ${CF_STACK+x} ]; then
    echo "CloudFormation stack is required. Use valid stack, ex: 420-application-stack.{json|yaml}"
    exit 1
fi

if [ -z ${CF_ENVIRONMENT+x} ]; then
    echo "Environment is required. Valid options: testing, dev, pre, pro"
    exit 1
fi

echo -------------------------------------------------------------------------
echo Environment: $CF_ENVIRONMENT
echo CloudFormation Layer: $CF_STACK
echo CloudFormation Type: $CF_TYPE
echo -------------------------------------------------------------------------

# Params
CF_BUCKET="projectfoo-infra-${CF_ENVIRONMENT}"
CF_DIR="cloudformation"
CF_PROJECT="projectfoo"
AWS_REGION="eu-west-1"
AWS_COMMAND="aws --region ${AWS_REGION} "

echo "Enter your AWS Key:"
read AWS_KEY
echo "Enter your AWS Secret:"
read AWS_SECRET

export AWS_ACCESS_KEY_ID=$AWS_KEY
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET

if [[ $? != 0 ]]; then
    echo "Error: Fix Cloudformation templates"
    exit 1
fi

# Upload CloudFormation code to S3 bucket.
${AWS_COMMAND} s3 \
  sync \
  ${__dir}/../${CF_DIR} \
  s3://${CF_BUCKET}/${CF_DIR}/

if [[ $? != 0 ]]; then
    echo "Error: failed to copy templates to S3 buckets"
    exit 1
fi


# Check Stack existence
STACK_ARN=$(${AWS_COMMAND} cloudformation describe-stacks --stack-name "${CF_STACK}-${CF_ENVIRONMENT}" | jq -r ".Stacks[].StackId"  || true)

if [[ $CF_ENVIRONMENT == "dev" ]]; then
  echo "Rollback disabled"
  CF_ARGS="--disable-rollback"
else
  CF_ARGS=""
fi

if [[ -z $STACK_ARN ]]; then
  echo "Stack create: ${CF_STACK}-${CF_ENVIRONMENT}"
  ${AWS_COMMAND} cloudformation create-stack \
    --stack-name "${CF_STACK}-${CF_ENVIRONMENT}" \
    --template-url https://s3.amazonaws.com/${CF_BUCKET}/${CF_DIR}/${CF_STACK}.${CF_TYPE} \
    --parameters file://${__dir}/parameters/${CF_STACK}-parameters-${CF_ENVIRONMENT}.json \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM ${CF_ARGS}\
    && echo "Stack ${CF_STACK}-${CF_ENVIRONMENT} created successfully."
else
  echo "Stack update: ${CF_STACK}-${CF_ENVIRONMENT}"
  ${AWS_COMMAND} cloudformation update-stack \
    --stack-name "${CF_STACK}-${CF_ENVIRONMENT}" \
    --template-url https://s3.amazonaws.com/${CF_BUCKET}/${CF_DIR}/${CF_STACK}.${CF_TYPE} \
    --parameters file://${__dir}/parameters/${CF_STACK}-parameters-${CF_ENVIRONMENT}.json \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
  echo "Uptaded Stack ${CF_STACK}-${CF_ENVIRONMENT} with arn: ${STACK_ARN}"
fi

exit 0

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

# vim: syntax=sh cc=80 tw=79 ts=4 sw=4 sts=4 et sr


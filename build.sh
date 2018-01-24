#!/bin/bash

set -e 

if [[ -z $BUCKET_NAME ]]; then
	echo "Bucketname not set"
	exit 1
fi

if [[ -z $DISTRIBUTION_ID ]]; then
	echo "Distribution ID not set"
	exit 1
fi

if [[ -z $CODEBUILD_BUILD_ID && -z $AWS_ACCESS_KEY_ID ]]; then
	echo "AWS creds not set"
	exit 1
fi

if [[ -z $CODEBUILD_BUILD_ID && -z $AWS_SECRET_ACCESS_KEY ]]; then
	echo "AWS creds not set"
	exit 1
fi

# Build
hugo -v

# Sync
aws s3 sync --acl "public-read" --sse "AES256" public/ s3://$BUCKET_NAME --exclude 'post'

# in the codebuild environment we need to set this to gain access
aws configure set preview.cloudfront true
# Invalidate
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths /index.html / /page/*

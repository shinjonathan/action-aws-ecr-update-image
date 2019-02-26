#!/bin/bash

if [ -z "$LOGICAL_NAME" ]
then
      echo "The environment variable LOGICAL_NAME must be defined"
      exit 1
fi

ECR_REPOSITORY=`aws ecr get-login --no-include-email --region us-east-1 | awk 'NF{ print $NF }' | sed -e 's/^http:\/\///g' -e 's/^https:\/\///g'`
ECR_URI=$ECR_REPOSITORY/$LOGICAL_NAME
eval $(aws ecr get-login --no-include-email --region us-east-1)

echo -e "Creating ECR repository..."
aws ecr create-repository --repository-name $LOGICAL_NAME || true

echo -e "Building Docker..."
docker build -t $LOGICAL_NAME --build-arg ENV=$ENV . > /dev/null

echo -e "Tagging Image..."
docker tag $LOGICAL_NAME:latest $ECR_URI:latest

echo -e "Pushing to ECR..."
docker push $ECR_URI:latest

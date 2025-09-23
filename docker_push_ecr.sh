#!/bin/bash

if [ -z "$1" ]; then
  TAG="latest"
else
  TAG=$1
fi

# add awsume command
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 264309510997.dkr.ecr.eu-west-2.amazonaws.com/self-hosted-runners:${TAG}
docker build -t self-hosted-runners_image:${TAG} .
docker tag self-hosted-runners_image:${TAG} 264309510997.dkr.ecr.eu-west-2.amazonaws.com/self-hosted-runners:${TAG}
docker push 264309510997.dkr.ecr.eu-west-2.amazonaws.com/self-hosted-runners:${TAG}

declare -a DEL_IMGS=(`docker image ls | grep '264309510997.dkr.ecr.eu-west-2.amazonaws.com/self-hosted-runners' | awk '{print$1}'`)

echo -e "\nRemoving unused docker images..."

for i in ${DEL_IMGS}; do
    echo $i
    docker image rm $i
done 

echo -e "\n\nDONE PUSH ECR !!"

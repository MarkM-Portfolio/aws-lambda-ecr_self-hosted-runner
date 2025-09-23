#!/bin/bash

if [ -z "$1" ]; then
  TAG="latest"
else
  TAG=$1
fi

docker system prune -a --volumes --force # Enable to delete volumes & clear up some storage space
# add awsume command
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 264309510997.dkr.ecr.eu-west-2.amazonaws.com/self-hosted-runners:${TAG}
docker pull 264309510997.dkr.ecr.eu-west-2.amazonaws.com/self-hosted-runners:${TAG}
docker container stop self-hosted-runners_container >> /dev/null 2<&1
docker container rm self-hosted-runners_container >> /dev/null 2<&1
docker tag 264309510997.dkr.ecr.eu-west-2.amazonaws.com/self-hosted-runners:${TAG} self-hosted-runners_image:${TAG}
docker run -t -d -p 8080:8080 --name self-hosted-runners_container self-hosted-runners_image:${TAG}

declare -a DEL_IMGS=(`docker image ls | grep '264309510997.dkr.ecr.eu-west-2.amazonaws.com/self-hosted-runners' | awk '{print$1}'`)

echo -e "\nRemoving unused docker images..."

for i in ${DEL_IMGS}; do
    echo $i
    docker image rm $i
done 

echo -e "\n\nDONE PULL ECR !!"

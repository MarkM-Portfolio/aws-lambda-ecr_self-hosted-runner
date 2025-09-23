#!/bin/bash

if [ -z "$1" ]; then
  TAG="latest"
else
  TAG=$1
fi

# docker system prune -a --volumes --force # Enable to delete volumes & clear up some storage space
docker build -t self-hosted-runners_image:${TAG} .
docker container stop self-hosted-runners_container >> /dev/null 2<&1
docker container rm self-hosted-runners_container >> /dev/null 2<&1
docker run -t -d -p 8080:8080 --name self-hosted-runners_container self-hosted-runners_image:${TAG}
mkdir -p ./.ssh
echo -e "Host github.com\n    HostName github.com\n    User git\n    IdentityFile ~/.ssh/ecr-lambda\n    IdentitiesOnly yes\n    StrictHostKeyChecking no" > ./.ssh/config \
&& cp ~/.ssh/markmon-sapphire ./.ssh/ecr-lambda \
&& docker cp ./.ssh self-hosted-runners_container:/root \
&& rm -rf ./.ssh
docker cp ~/.aws self-hosted-runners_container:/root

declare -a DEL_IMGS=(`docker image ls | grep '264309510997.dkr.ecr.eu-west-2.amazonaws.com/self-hosted-runners\|<none>' | awk '{print$3}'`)

echo -e "\nRemoving unused docker images..."

for i in ${DEL_IMGS}; do
    echo $i
    docker image rm $i
done 

echo -e "\n\nDONE DOCKER BUILD !!"

#!/bin/bash --

docker_dir="$HOME/Projects/docker/crossfire-docker/"
pid=$(docker inspect -f '{{.State.Pid}}' crossfire-docker_crossfire_1)
echo $pid
mem_usage_percent=$(ps h -o %mem $pid)
#echo $mem_usage_percent
mem_limit_percent=35
#echo $mem_limit_percent
#echo "$mem_usage_percent > $mem_limit_percent"|bc -l

if [ $(echo "$mem_usage_percent > $mem_limit_percent"|bc -l) -eq 1 ]; then
    echo "Memory $mem_usage_percent>$mem_limit_percent - Recreate docker container"
    cd $docker_dir
    /usr/local/bin/docker-compose down
    /usr/local/bin/docker-compose up -d
else
    echo "Memory $mem_usage_percent<$mem_limit_percent - Don't restart"

fi

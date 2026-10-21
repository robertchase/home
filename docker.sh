alias dps="docker ps --format \"table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\""

function stop {
    local container_id
    container_id=$(docker ps -q --filter name=$1)
    if [ -z "$container_id" ]; then
        echo "container matching '$1' not found"
    else
        docker stop $container_id
        docker rm $container_id 2>/dev/null
    fi
}

function psql {
    local container_id
    container_id=$(docker ps -q --filter name=${PSQL_PG-postgres})
    if [ -z "$container_id" ]
    then
        echo "container matching '$1' not found"
    else
        docker exec -it $container_id psql -U ${PSQL_USER-postgres} -P pager=off $*
    fi
}

alias docker-redis="docker run -p 6379:6379 --name redis -v redis-data:/data -d redis redis-server --save 60 1 --appendonly yes"

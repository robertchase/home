alias podman-redis="podman run -p 6379:6379 --name redis -d redis"

function podman-mysql {
    podman run $OPT -p 3306:3306 --rm -d --name mysql --net test -v=${HOME}/git:/opt/git -v=${HOME}/play:/opt/play -v=${HOME}/mysql_data/:/var/lib/mysql/ -e MYSQL_ALLOW_EMPTY_PASSWORD=yes arm64v8/mysql:latest
}

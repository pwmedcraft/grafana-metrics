#!/usr/bin/env bash
set -e
versionvar=${BUILD_NUMBER}
dockerRegistry=local-reg

printf "\n*** Stop current metrics dashboard\n"
docker stop metrics-dashboard-current ||: && docker rm metrics-dashboard-current ||:

printf "\n*** Build and Save Docker for version ${versionvar}\n"
docker build --no-cache -t ${dockerRegistry}/metrics-dashboard-${versionvar} .
#docker push ${dockerRegistry}/metrics-dashboard-${versionvar}

printf "\n*** Tidying up Docker images\n"
#docker rmi ${dockerRegistry}/metrics-dashboard-${versionvar}
#docker image prune -fa

#docker pull ${dockerRegistry}/metrics-dashboard-${versionvar}

printf "\n*** Start metrics-dashboard..."
docker run --name metrics-dashboard-current -t -d -h=localhost \
-p 80:80 \
-p 81:81 \
-p 8125:8125/udp \
-p 8126:8126 \
-p 2003:2003 \
--network="host" \
--restart always \
-v ~/metrics-dashboard/data/whisper:/opt/graphite/storage/whisper \
-v ~/metrics-dashboard/data/grafana:/opt/grafana/data \
-v ~/metrics-dashboard/log/graphite:/opt/graphite/storage/log \
-v ~/metrics-dashboard/log/graphite/webapp:/opt/graphite/storage/log/webapp \
-v ~/metrics-dashboard/log/supervisor:/var/log/supervisor \
${dockerRegistry}/metrics-dashboard-${versionvar}
printf "\n*** Deploy complete"

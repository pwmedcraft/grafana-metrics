# Application Metrics Dashboard

Produces a Docker image containing StatsD, Graphite, Grafana, a script to collect DropWizard metrics in JSON format from an HTTP endpoint and sample dashboards.

Based on https://github.com/kamon-io/docker-grafana-graphite

## Data Retention

Data is stored /opt/graphite/storage/whisper in the Docker container, which is mapped to ~/metrics-dashboard/data/whisper by the deploy script.

Both Statsd and Graphite are configured to retain data at 10s resolution for 7 days: datapoints older than 7 days are deleted.

To change this for Statsd, edit statsd/config.js. To change it for Graphite, you'll need to change the Dockerfile to delete /opt/graphite/conf/storage-schemas.conf from the base image and 
replace it with an edited copy of the one from the base image, as we do for the Statsd config file.

As statsd is forwarding to Graphite, it might be possible to change retention on Statsd to a much lower value - needs research and experimentation!
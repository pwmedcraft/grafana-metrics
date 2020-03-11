FROM    kamon/grafana_graphite

# Replace statsd config from base image so we can set deleteGauges to true
RUN 	rm /src/statsd/config.js
COPY    ./statsd/config.js /src/statsd/

# Remove dashboards included in base image
RUN 	rm /src/dashboards/*.*

# Copy across sample dashboards
COPY    ./dashboards/*.* /src/dashboards/

# Copy across collection script
RUN     mkdir /opt/collection
COPY    ./collection/*.* /opt/collection/
RUN     chmod +x /opt/collection/collect.sh

# Replace supervisor config from base image so we can run collection script as daemon
RUN 	rm /etc/supervisor/conf.d/supervisord.conf
COPY    ./supervisor/supervisord.conf /etc/supervisor/conf.d/

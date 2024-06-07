FROM envoyproxy/envoy:dev
COPY envoy.yaml /etc/envoy/envoy.yaml
RUN chmod go+r /etc/envoy/envoy.yaml
RUN mkdir /certs
COPY server.crt /certs/server.crt
COPY server.key /certs/server.key
RUN chmod go+r /certs/server.crt && chmod go+r /certs/server.key

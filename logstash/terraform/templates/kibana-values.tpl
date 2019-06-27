files:
  kibana.yml:
    ## Default Kibana configuration from kibana-docker.
    server.name: kibana
    server.host: "0"
    elasticsearch.hosts: http://elasticsearch-client:9200

initContainers: 
  es-check:
    image: "appropriate/curl:latest"
    imagePullPolicy: "IfNotPresent"
    command:
      - "/bin/sh"
      - "-c"
      - |
        is_down=true
        while "$is_down"; do
          if curl -sSf --fail-early --connect-timeout 5 http://elasticsearch-client:9200; then
            is_down=false
          else
            sleep 5
          fi
        done

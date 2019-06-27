elasticsearch:
  host: elasticsearch-client.default.svc.cluster.local
  port: 9200

inputs:
  main: |-
    input {
      azure_event_hubs {
        event_hub_connections => [
            "${eventhub_connection_string}"
          ]
        threads => 8
        decorate_events => true
        consumer_group => "$Default"
        storage_connection => "${storage_connection_string}"
      }
    }

outputs:
  main: |-
    output {
      elasticsearch {
        hosts => ["elasticsearch-client.default.svc:9200"]
        manage_template => false
        index => "%%{[@metadata][beat]}-%%{+YYYY.MM.dd}"
        document_type => "%%{[@metadata][type]}"
      }
    }

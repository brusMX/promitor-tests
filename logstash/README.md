# Sending Azure Logs to Logstash

Log into ELK Stack:
```
ssh user@<SERVER-IP>
```


Load the ELK environment:
```
sudo /opt/bitnami/use_elk
```


Stop Logstash service:
```
sudo /opt/bitnami/ctlscript.sh stop logstash
```


Create the file /opt/bitnami/logstash/conf/azure-eh.conf, where EntityPath is the Event Hub:
```
input {
   azure_event_hubs {
      event_hub_connections => ["Endpoint=sb://example1...EntityPath=insights-logs-errors", "Endpoint=sb://example2...EntityPath=insights-metrics-pt1m"]
      threads => 8
      decorate_events => true
      consumer_group => "logstash"
      storage_connection => "DefaultEndpointsProtocol=https;AccountName=example...."
   }
}

output {
    elasticsearch {
        hosts => [ "127.0.0.1:9200" ]
    }
}
```


Check that your configuration is OK, 
```
/opt/bitnami/logstash/bin/logstash -f /opt/bitnami/logstash/conf/ --config.test_and_exit
```


Start the Logstash service:
```
sudo /opt/bitnami/ctlscript.sh start logstash
```


Check Elasticsearch:
```
curl 'localhost:9200/_cat/indices?v'
```


Visualizing Data:
```
http://<SERVER-IP>/elk/app/kibana
```


Obtain credentials:
```
cat ./bitnami_credentials
```

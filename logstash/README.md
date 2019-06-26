# Sending Azure Logs to Logstash

## Kubernetes Logstash

helm install --name elasticsearch stable/elasticsearch
helm install stable/logstash --name logstash -f helm/values.yaml
helm install --name kibana stable/kibana -f helm/kibana-values.yaml

Get the current pods:
```
kubectl get po
NAME                                             READY   STATUS    RESTARTS   AGE
elasticsearch-client-6d4cc47b8c-k27qx            1/1     Running   0          29m
elasticsearch-client-6d4cc47b8c-r78z5            1/1     Running   0          29m
elasticsearch-data-0                             1/1     Running   0          29m
elasticsearch-data-1                             1/1     Running   0          26m
elasticsearch-master-0                           1/1     Running   0          29m
elasticsearch-master-1                           1/1     Running   0          28m
elasticsearch-master-2                           1/1     Running   0          27m
kibana-cd6c8579b-n59l9                           1/1     Running   0          24m
logstash-0                                       1/1     Running   0          6m24s
```

Forward the traffic:
```
kubectl port-forward kibana-cd6c8579b-n59l9 5601:5061
```

Navigate to `localhost:5601` in your broser to access your Kibana dashboard, and view the logs pushed into ElasticSearch.

## Bitnami ELK Stack on Azure:

Create the resource via Azure portal.

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
      event_hub_connections => [
          "Endpoint=sb://example1...EntityPath=insights-logs-errors", "Endpoint=sb://example2...EntityPath=insights-metrics-pt1m"
        ]
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

Obtain credentials:
```
cat ./bitnami_credentials
```

Log into Kibana:
```
http://<SERVER-IP>/elk/app/kibana
```

data "template_file" "elasticsearch-values" {
  template = "${file("templates/elasticsearch-values.tpl")}"
  vars = {
  }
}

data "template_file" "kibana-values" {
  template = "${file("templates/kibana-values.tpl")}"
  vars = {
  }
}

data "template_file" "logstash-values" {
  template = "${file("templates/logstash-values.tpl")}"
  vars = {
    eventhub_connection_string = "${azurerm_eventhub_namespace_authorization_rule.logging.primary_connection_string};EntityPath=${azurerm_eventhub.logging_postgresql.name}"
    storage_connection_string = "${azurerm_storage_account.logging.primary_connection_string}"
  }
}

resource "null_resource" "install_tiller" {
  provisioner "local-exec" {
    command = "helm init --kubeconfig kube-cluster-${lower(random_id.logging_kubernetes.hex)} --wait"
  }

  depends_on = ["local_file.kube_config"]
}

resource "local_file" "elasticsearch-values" {
  content = "${data.template_file.elasticsearch-values.rendered}"
  filename = "elasticsearch-values.yaml"

  provisioner "local-exec" {
    command = "helm install --kubeconfig kube-cluster-${lower(random_id.logging_kubernetes.hex)} --name elasticsearch stable/elasticsearch -f elasticsearch-values.yaml --wait"
  }

  depends_on = ["null_resource.install_tiller"]
}

resource "local_file" "kibana-values" {
  content = "${data.template_file.kibana-values.rendered}"
  filename = "kibana-values.yaml"

  provisioner "local-exec" {
    command = "helm install --kubeconfig kube-cluster-${lower(random_id.logging_kubernetes.hex)} --name kibana stable/kibana -f kibana-values.yaml --wait"
  }

  depends_on = ["null_resource.install_tiller"]
}

resource "local_file" "logstash-values" {
  content = "${data.template_file.logstash-values.rendered}"
  filename = "logstash-values.yaml"

  provisioner "local-exec" {
    command = "helm install --kubeconfig kube-cluster-${lower(random_id.logging_kubernetes.hex)} --name logstash stable/logstash -f logstash-values.yaml --wait"
  }

  depends_on = ["null_resource.install_tiller"]
}


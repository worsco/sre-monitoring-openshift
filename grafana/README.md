# Deploy managed Grafana for openshift-monitoring

Run this as a cluster admin.

## Setup

```sh
export deploy_namespace=openshift-monitoring-ext
```

Optional - add network policies and quota to mimic production env

```sh
helm upgrade -i --create-namespace admin helm/admin -n ${deploy_namespace}
```

## Deploy

```sh
helm upgrade -i --create-namespace grafana-operator helm/operator -n ${deploy_namespace}
helm upgrade -i --create-namespace grafana-operator helm/operator -n ${deploy_namespace} --set grafana_operator.installPlanApproval="Manual"

helm upgrade -i --create-namespace grafana helm/grafana -n ${deploy_namespace} --set grafana.datasources.prometheus.openshift_monitoring.password=$(oc extract secret/grafana-datasources -n openshift-monitoring --keys=prometheus.yaml --to=- | grep -zoP '"basicAuthPassword":\s*"\K[^\s,]*(?=\s*",)')
```

# Deploy managed Grafana for openshift-monitoring

Run this as a cluster admin.

## Setup

```sh
export DEPLOYNAMESPACE=my-grafana
```

## Create namespace

```sh
oc new-project $DEPLOYNAMESPACE
```

Optional - add network policies and quota to mimic production env 

```sh
helm upgrade -i --create-namespace admin helm/admin -n ${DEPLOYNAMESPACE}
```

## Deploy operator

```sh
helm upgrade -i --create-namespace grafana-operator helm/operator -n ${DEPLOYNAMESPACE}
```

## Manually approve the InstallPlan to install the grafana-operator

```sh
oc get installplans -n ${DEPLOYNAMESPACE}
```

```sh
oc patch installplan <INSTALLPLAN> n ${DEPLOYNAMESPACE} --type merge -p '{"spec":{"approved":true}}'
```

## Patch the CSV so that it is using a named registry in the image instead of defaulting to "grafana/grafana"

```sh
oc patch csv grafana-operator.v3.5.0 --type='json' \
-p='[{"op": "replace", "path": "/spec/install/spec/deployments/0/spec/template/spec/containers/0/args", "value":["--grafana-image=quay.io/app-sre/grafana","--grafana-image-tag=6.5.1"]}]' \
-n ${DEPLOYNAMESPACE}
```

## Optional - update dashboards for your OCP version

This will update the json files within helm/grafana/dashboards/openshift-monitoring.

```sh
./export-openshift-monitoring-dashboards.sh
```

## Deploy grafana

```sh
helm upgrade -i --create-namespace grafana helm/grafana -n ${deploy_namespace} --set grafana.datasources.prometheus.openshift_monitoring.password=$(oc extract secret/grafana-datasources -n openshift-monitoring --keys=prometheus.yaml --to=- | grep -zoP '"basicAuthPassword":\s*"\K[^\s,]*(?=\s*",)')
```

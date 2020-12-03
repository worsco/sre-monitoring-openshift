#!/bin/bash

oc get configmap -n openshift-monitoring -o name | egrep grafana-dashboard- | while read configmap; do 
  oc extract $configmap -n openshift-monitoring --to=helm/grafana/dashboards/openshift-monitoring --confirm
done

exit 0
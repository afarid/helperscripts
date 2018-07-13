#!/bin/bash

# Get all namespaces 
kubectl get --export -o=json ns | jq '.items[] | select(.metadata.name!="kube-system") | select(.metadata.name!="default") | del(.status, .metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation )' > ./ns.json


for ns in $(jq -r '.metadata.name' < ./ns.json)
do 
echo "Namespace: $ns" 
kubectl --namespace="${ns}" get --export -o=json svc,secrets,ds,deploy,configmap,statefulset,ing | 
jq '.items[] | select(.type!="kubernetes.io/service-account-token") | del( .spec.clusterIP, .metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .metadata.annotations."kubectl.kubernetes.io/last-applied-configuration", .metadata.annotations."deployment.kubernetes.io/revision", .status, .spec.template.spec.securityContext, .spec.template.spec.dnsPolicy, .spec.template.spec.terminationGracePeriodSeconds, .spec.template.spec.restartPolicy )' >> "./cluster-dump.json" 
done

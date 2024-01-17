#!/bin/bash

kubectl delete --ignore-not-found=true clusterrolebindings.rbac.authorization.k8s.io stackgres-operator-init

kubectl -n "$NAMESPACE" delete --ignore-not-found=true certs --all

kubectl -n "$NAMESPACE" delete --ignore-not-found=true secrets stackgres-operator-certs stackgres-operator-web-certs

kubectl -n "$NAMESPACE" delete --ignore-not-found=true issuers.cert-manager.io stackgres-operator-ca-issuer stackgres-operator-self-signed-issuer

kubectl -n "$NAMESPACE" rollout restart deployment stackgres-operator

kubectl -n "$NAMESPACE" rollout restart deployment stackgres-restapi
#!/bin/bash

kubectl -n "$NAMESPACE" delete clusterrolebindings.rbac.authorization.k8s.io stackgres-operator-init

kubectl -n "$NAMESPACE" delete certs --all

kubectl -n "$NAMESPACE" delete secrets stackgres-operator-certs stackgres-operator-web-certs

kubectl -n "$NAMESPACE" delete issuers.cert-manager.io stackgres-operator-ca-issuer stackgres-operator-self-signed-issuer

#!/bin/bash

pw=$(kubectl -n "$NAMESPACE" get secret stackgres-restapi -o jsonpath="{.data.password}")
if [ -z "$pw" ]
then
  echo "setting password"
  pw=$(openssl rand -base64 40)
  pw64=$(echo -n "$pw" | base64 -w0)
  pwSha64=$(echo -n "$USER""$pw" | sha256sum | awk -F' ' '{printf($1)}' | base64 -w0)

  patch=$(printf "{\"data\": {\"clearPassword\": \"%s\",\"password\":\"%s\"}}" "$pw64" "$pwSha64")
  kubectl -n "$NAMESPACE" patch secret stackgres-restapi --patch "$patch"
else
  echo "password already set"
fi

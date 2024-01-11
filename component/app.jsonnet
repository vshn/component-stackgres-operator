local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.stackgres_operator;
local argocd = import 'lib/argocd.libjsonnet';
local instance = inv.parameters._instance;

local app = argocd.App(instance, params.namespace) +
            {
              spec+: {
                syncPolicy+: {
                  syncOptions+: [
                    'ServerSideApply=true',
                  ],
                },
                ignoreDifferences+: [
                  {
                    group: 'admissionregistration.k8s.io',
                    kind: 'ValidatingWebhookConfiguration',
                    jqPathExpressions: [
                      '.webhooks[]?.clientConfig.caBundle',
                    ],
                  },
                  {
                    group: 'admissionregistration.k8s.io',
                    kind: 'MutatingWebhookConfiguration',
                    jqPathExpressions: [
                      '.webhooks[]?.clientConfig.caBundle',
                    ],
                  },
                  {
                    group: 'cert-manager.io',
                    kind: 'Certificate',
                    jsonPointers: [
                      '/spec/duration',
                      '/spec/renewBefore',
                    ],
                  },
                  {
                    group: 'stackgres.io',
                    kind: 'SGConfig',
                    jsonPointers: [
                      '/spec/rbac',
                    ],
                  },
                  // catching "nullable": "false"
                  {
                    group: 'apiextensions.k8s.io',
                    kind: 'CustomResourceDefinition',
                    name: 'sgdbops.stackgres.io',
                    jqPathExpressions: [
                      '.spec.versions[]?.schema.openAPIV3Schema.properties.status.properties.benchmark.properties.pgbench',
                    ],
                  },
                ],
              },
            };

{
  [instance]: app,
}

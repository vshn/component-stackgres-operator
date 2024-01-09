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
                    group: 'apps',
                    kind: 'Deployment',
                    jsonPointers: [
                      '/spec/replicas',
                    ],
                  },
                  {
                    group: 'admissionregistration.k8s.io',
                    kind: 'ValidatingWebhookConfiguration',
                    jqPathExpression: [
                      '.webhooks[]?.clientConfig.caBundle',
                    ],
                  },
                  {
                    group: 'admissionregistration.k8s.io',
                    kind: 'MutatingWebhookConfiguration',
                    jqPathExpression: [
                      '.webhooks[]?.clientConfig.caBundle',
                    ],
                  },
                ],
              },
            };

{
  [instance]: app,
}

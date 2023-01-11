local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.stackgres_operator;
local argocd = import 'lib/argocd.libjsonnet';
local instance = inv.parameters._instance;

local app = argocd.App(instance, params.namespace) {
  spec+: {
    ignoreDifferences+: [
      {
        group: 'apps',
        kind: 'Deployment',
        jsonPointers: [
          '/spec/replicas',
        ],
      },
    ],
  },
};

{
  [instance]: app,
}

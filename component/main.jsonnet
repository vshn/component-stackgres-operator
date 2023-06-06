// main template for stackgres-operator
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.stackgres_operator;

local networkPolicy = kube.NetworkPolicy('allow-stackgres-api') + {
  metadata+: {
    namespace: params.namespace,
  },
  spec+: {
    policyTypes: [ 'Ingress' ],
    podSelector: {
      matchLabels: {
        app: 'stackgres-restapi',
      },
    },
    ingress: [
      {
        from: [
          {
            namespaceSelector: {},
          },
        ],
        ports: [
          {
            protocol: 'TCP',
            port: 8443,
          },
        ],
      },
    ],
  },
};

// Define outputs below
{
  '00_namespace': kube.Namespace(params.namespace),
  '01_network_policy': networkPolicy,
}

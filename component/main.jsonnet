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
            namespaceSelector: {
              matchLabels: {
                'appuio.io/billing-name': 'appcat-postgresql',
              },
            },
          },
        ],
      },
    ],
  },
};

local pw = std.get(
  std.get(params.helmValues, 'authentication', default={}),
  'password',
  default=''
);
local user = std.get(
  std.get(params.helmValues, 'authentication', default={}),
  'user',
  default='admin'
);

local setRestAPIPwJob = kube.Job('stackgres-restapi-set-password') {
  local commonLabels = {
    app: 'stackgres-restapi-set-password',
    job: 'set-password',
    scope: 'init',
  },
  metadata+: {
    annotations: {
      'helm.sh/hook': 'post-install,post-upgrade',
      'helm.sh/hook-delete-policy': 'before-hook-creation,hook-succeeded',
      'helm.sh/hook-weight': '10',
    },
    labels: commonLabels,
    namespace: params.namespace,
  },
  spec+: {
    template: {
      metadata: {
        labels: commonLabels,
      },
      spec: {
        containers: [
          kube.Container('set-password') {
            image: '%(s)s/bitnami/kubectl:%(s)s' % [ params.images.kubectl.registry, params.kubernetesVersion ],
            command: [ '/bin/bash', '-ecx', importstr 'scripts/set-password.sh' ],
            env_+: {
              NAMESPACE: params.namespace,
              USER: user,
            },
          },
        ],
        restartPolicy: 'OnFailure',
        serviceAccountName: 'stackgres-operator-init',
        ttlSecondsAfterFinished: 5,
      },
    },
  },
};


// Define outputs below
{
  '00_namespace': kube.Namespace(params.namespace) {
    metadata+: {
      labels+: params.namespaceLabels,
      annotations+: params.namespaceAnnotations,
    },
  },
  '01_network_policy': networkPolicy,
  [if pw == '' then '02_set_restAPI_password_job']: setRestAPIPwJob,
}

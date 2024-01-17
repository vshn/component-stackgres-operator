/*
    This Job ensures smooth upgrade of Stackgres from version > 1.5.
    It solves issues with breaking changes introduced in helm charts, as well as egg-chicken (certs, issuers, secrets) issues during upgrade.
*/

local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local kube = import 'lib/kube.libjsonnet';
local params = inv.parameters.stackgres_operator;
local instance = inv.parameters._instance;


local CleanCertsJobName = 'clean-certificates-job';

local job = kube.Job('') {
  metadata: {
    generateName: CleanCertsJobName + '-',
    annotations: {
      'argocd.argoproj.io/hook': 'PreSync',
    },
  },
  spec: {
    template: {
      spec: {
        containers: [
          {
            args: [],
            command: [
              '/bin/bash',
              '-cex',
              importstr 'scripts/preCleanCerts.sh',
            ],
            env+: [
              {
                name: 'NAMESPACE',
                value: params.namespace,
              },
            ],
            image: params.images.registry + '/appuio/oc:v4.14',
            name: 'kubectl',
          },
        ],
        restartPolicy: 'OnFailure',
        serviceAccountName: 'stackgres-init-additional-permissions',
        ttlSecondsAfterFinished: 5,
      },
    },
  },
};

{
  '02_CleanCertsJobName': job,
}

/*
    This Job ensures smooth upgrade of Stackgres from version > 1.5.
    It solves issues with breaking changes introduced in helm charts, as well as egg-chicken (certs, issuers, secrets) issues during upgrade. 
*/

local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local kube = import 'lib/kube.libjsonnet';
local params = inv.parameters.stackgres_operator;
local instance = inv.parameters._instance;


local role = 'additionalRolePermissions';

local job = kube.Role('stackgres-operator-init') {
  metadata: {
    generateName: role + '-',
    annotations: {
      'argocd.argoproj.io/hook': 'PreSync',
    },
  },
  spec: {
  },
};

{
  role: job,
}

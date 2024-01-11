/*
    This Job ensures smooth upgrade of Stackgres from version > 1.5.
    It solves issues with breaking changes introduced in helm charts, as well as egg-chicken (certs, issuers, secrets) issues during upgrade.
*/

local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local kube = import 'lib/kube.libjsonnet';
local params = inv.parameters.stackgres_operator;
local instance = inv.parameters._instance;


local rolename = 'stackgres-init-additional-permissions';

local role = kube.Role(rolename) {
  metadata+: {
    annotations: {
      'argocd.argoproj.io/hook': 'PreSync',
    },
  },
  rules: [
    {
      apiGroups: [ '' ],
      resources: [ 'secrets' ],
      verbs: [ 'get', 'list', 'watch', 'create', 'update', 'delete' ],
    },
    {

      apiGroups: [ '' ],
      resources: [ 'clusterrolebindings' ],
      verbs: [ 'delete' ],
    },
    {

      apiGroups: [ 'cert-manager.io' ],
      resources: [ 'certificates', 'issuers' ],
      verbs: [ 'delete' ],
    },
  ],
};

local roleBinding = kube.RoleBinding(rolename + '-rolebinding') {
  metadata+: {
    annotations: {
      'argocd.argoproj.io/hook': 'PreSync',
    },
  },
  roleRef: {
    kind: 'Role',
    name: rolename,
    apiGroup: 'rbac.authorization.k8s.io',
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: 'stackgres-operator-init',
    },
  ],
};
{
  '01_role': role,
  '01_rolebinding': roleBinding,
}

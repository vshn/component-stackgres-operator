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

local sa = kube.ServiceAccount(rolename) {
  metadata+: {
    annotations: {
      'argocd.argoproj.io/hook': 'PreSync',
    },
  },
};

local clusterRole = kube.ClusterRole(rolename) {
  metadata+: {
    annotations: {
      'argocd.argoproj.io/hook': 'PreSync',
    },
  },
  rules: [
    {
      apiGroups: [ 'rbac.authorization.k8s.io' ],
      resources: [ 'clusterrolebindings' ],
      verbs: [ 'delete', 'get', 'list', 'watch' ],
    },
  ],
};

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
      apiGroups: [ 'cert-manager.io' ],
      resources: [ 'certificates', 'issuers' ],
      verbs: [ 'delete', 'get', 'list' ],
    },
  ],
};

local clusterRoleBinding = kube.ClusterRoleBinding(rolename) {
  metadata+: {
    annotations: {
      'argocd.argoproj.io/hook': 'PreSync',
    },
  },
  roleRef: {
    kind: 'ClusterRole',
    name: rolename,
    apiGroup: 'rbac.authorization.k8s.io',
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: rolename,
      namespace: params.namespace,
    },
  ],
};

local rolebinding = kube.RoleBinding(rolename) {
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
      name: rolename,
      namespace: params.namespace,
    },
  ],
};


{
  '01_sa': sa,  
  '01_role': role,
  '01_clusterRole': clusterRole,
  '01_rolebinding': rolebinding,
  '01_clusterRoleBinding': clusterRoleBinding,
}

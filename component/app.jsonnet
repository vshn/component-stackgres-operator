local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.stackgres_operator;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('stackgres-operator', params.namespace);

{
  'stackgres-operator': app,
}

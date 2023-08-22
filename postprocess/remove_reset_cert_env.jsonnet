/**
 * We need to remove the `DISABLE_RECONCILIATION` generate by helm for the operator,
 * as this env variable will then be hardcordd by argocd and disable reconcilation permanently.
 */
local com = import 'lib/commodore.libjsonnet';
local inv = com.inventory();
local params = inv.parameters.stackgres_operator;

local file_extension = '.yaml';
local file_operator = 'operator-deployment';
local file_restapi = 'webapi-deployment';

local operator_override = com.yaml_load(std.extVar('output_path') + '/' + file_operator + file_extension) {
  spec+: {
    template+: {
      spec+: {
        containers: [
          c {
            env: [
              if e.name == 'RESET_CERTS' && e.value == 'true' then
                null
              else
                e
              for e in super.env
            ],

          }
          for c in super.containers
        ],
      },
    },
  },
};

local restapi_override = com.yaml_load(std.extVar('output_path') + '/' + file_restapi + file_extension) {
  spec+: {
    template+: {
      spec+: {
        containers: [
          c {
            env: [
              if e.name == 'RESET_CERTS' && e.value == 'true' then
                null
              else
                e
              for e in super.env
            ],

          }
          for c in super.containers
        ],
      },
    },
  },
};

{
  [file_operator]: std.prune(operator_override),
  [file_restapi]: std.prune(restapi_override),
}

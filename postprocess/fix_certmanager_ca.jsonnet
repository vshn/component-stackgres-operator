/**
 * Adjust generated yamls by helm template
 */
local com = import 'lib/commodore.libjsonnet';
local inv = com.inventory();
local params = inv.parameters.stackgres_operator;

local file_extension = '.yaml';
local file = 'create-certificate-job';

local patch_webook_cmd = |||
  kubectl annotate --overwrite validatingwebhookconfigurations stackgres-operator cert-manager.io/inject-ca-from=%(namespace)s/stackgres-operator-cert
  kubectl annotate --overwrite mutatingwebhookconfigurations stackgres-operator cert-manager.io/inject-ca-from=%(namespace)s/stackgres-operator-cert
||| % params;

{
  [if params.helmValues.cert.certManager.autoConfigure then file]: com.yaml_load(std.extVar('output_path') + '/' + file + file_extension) {
    spec+: {
      template+: {
        spec+: {
          containers: [
            if c.name == 'create-certificate' then
              c {
                command: [
                  super.command[0],
                  super.command[1],
                  super.command[2] + patch_webook_cmd,
                ],
              }
            else
              c
            for c in super.containers
          ],
        },
      },
    },
  },
}

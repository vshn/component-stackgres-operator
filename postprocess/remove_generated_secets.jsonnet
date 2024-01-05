/**
 * We need to remove secrets generate by helm as they are not stable
 * Secrets will be genereated through a job
 */
local com = import 'lib/commodore.libjsonnet';
local inv = com.inventory();
local params = inv.parameters.stackgres_operator;

local file_extension = '.yaml';
local file = 'webapi-authentication-secret';

local pw = std.get(
  std.get(params.helmValues, 'authentication', default={}),
  'password',
  default=''
);

{
  [if pw == '' then file]: com.yaml_load(std.extVar('output_path') + '/' + file + file_extension) {
    data+: {
      password:: '',
      clearPassword:: '',
    },
  },
}

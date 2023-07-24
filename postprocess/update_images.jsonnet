/**
 * Adjust generated yamls by helm template
 */
local com = import 'lib/commodore.libjsonnet';
local inv = com.inventory();
local params = inv.parameters.stackgres_operator;

local file_extension = '.yaml';
local file_names_kubectl_image = [
  'create-certificate-job',
  'set-crd-version-job',
  'wait-job',
  'wait-webhooks-job',
];

local file_names_operator_image = [
  'operator-deployment',
];

local file_names_restapi_image = [
  'webapi-deployment',
];

local file_names_jobs_image = [
  'cr-updater-job',
  'crd-upgrade-job',
  'crd-webhooks-job',
];

local set_image_registry(c, image_param, super_image) =
  if std.objectHas(image_param, 'tag') && image_param.tag != null && image_param.tag != '' then
    c {
      image: '%s/%s:%s' % [ image_param.repository, image_param.image, image_param.tag ],
    }
  else
    c {
      image: '%s/%s:%s' % [ image_param.repository, image_param.image, std.split(super_image, ':')[1] ],
    }
;

{
  [file]: com.yaml_load(std.extVar('output_path') + '/' + file + file_extension) {
    spec+: {
      template+: {
        spec+: {
          containers: [
            if std.startsWith(c.image, 'ongres/kubectl') then
              set_image_registry(c, params.images.kubectl, c.image)
            else
              c
            for c in super.containers
          ],
        },
      },
    },
  }
  for file in file_names_kubectl_image
} +
{
  [file]: com.yaml_load(std.extVar('output_path') + '/' + file + file_extension) {
    spec+: {
      template+: {
        spec+: {
          containers: [
            if std.startsWith(c.image, 'stackgres/operator') then
              set_image_registry(c, params.images.stackgres_operator, c.image)
            else
              c
            for c in super.containers
          ],
        },
      },
    },
  }
  for file in file_names_operator_image
} +
{
  [file]: com.yaml_load(std.extVar('output_path') + '/' + file + file_extension) {
    spec+: {
      template+: {
        spec+: {
          containers: [
            if std.startsWith(c.image, 'stackgres/restapi') then
              set_image_registry(c, params.images.stackgres_restapi, c.image)
            else if std.startsWith(c.image, 'stackgres/admin-ui') then
              set_image_registry(c, params.images.stackgres_adminui, c.image)
            else
              c
            for c in super.containers
          ],
        },
      },
    },
  }
  for file in file_names_restapi_image
} +
{
  [file]: com.yaml_load(std.extVar('output_path') + '/' + file + file_extension) {
    spec+: {
      template+: {
        spec+: {
          containers: [
            if std.startsWith(c.image, 'stackgres/jobs') then
              set_image_registry(c, params.images.stackgres_jobs, c.image)
            else
              c
            for c in super.containers
          ],
        },
      },
    },
  }
  for file in file_names_jobs_image
}

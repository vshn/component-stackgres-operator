/**
 * Adjust generated yamls by helm template
 */
local com = import 'lib/commodore.libjsonnet';
local inv = com.inventory();
local params = inv.parameters.stackgres_operator;

local file_extension = '.yaml';
local file_names = [
  'create-certificate-job',
  'set-crd-version-job',
  'wait-job',
  'wait-webhooks-job',
];

local image = '%s/%s:%s' % [ params.images.kubectl.repository, params.images.kubectl.image, params.images.kubectl.tag ];

{
  [file]: com.yaml_load(std.extVar('output_path') + '/' + file + file_extension) {
    spec+: {
      template+: {
        spec+: {
          containers: [
            if std.startsWith(c.image, 'ongres/kubectl') then
              c {
                image: image,
              }
            else
              c
            for c in super.containers
          ],
        },
      },
    },
  }
  for file in file_names
}

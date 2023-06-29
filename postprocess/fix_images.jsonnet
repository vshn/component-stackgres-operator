/**
 * Fixup images that are missing tags
 *
 * We have the feature that if we do not set tags for stackgres images, we use the tag defined by the stackgres helm chart.
 * This, however, means, that we can't directly use these image tags for additional jobs defined outside of the helm chart.
 *
 * This post processing step gets the complete image from the output of the helmchart redner and patches the additional jobs.
 */
local com = import 'lib/commodore.libjsonnet';
local inv = com.inventory();
local params = inv.parameters.stackgres_operator;

local reference_kubectl_image_file = com.yaml_load(std.extVar('output_path') + '/01_helmchart/stackgres-operator/templates/create-certificate-job.yaml');
local reference_kubectl_image = reference_kubectl_image_file.spec.template.spec.containers[0].image;

local file_extension = '.yaml';
local file_names_kubectl_image = [
  '02_set_restAPI_password_job',
];


{
  [file]: com.yaml_load(std.extVar('output_path') + '/' + file + file_extension) {
    spec+: {
      template+: {
        spec+: {
          containers: [
            if std.startsWith(c.image, '%(repository)s/%(image)s' % params.images.kubectl) then
              c {
                image: reference_kubectl_image,
              }
            else
              c
            for c in super.containers
          ],
        },
      },
    },
  }
  for file in file_names_kubectl_image
}

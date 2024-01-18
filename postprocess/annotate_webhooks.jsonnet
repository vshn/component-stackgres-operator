local com = import 'lib/commodore.libjsonnet';


local template_files = [
  'mutating-webhook-configuration',
  'validating-webhook-configuration',
];

local templates = [
  {
    name: template_file,
    content: com.yaml_load_all(std.extVar('output_path') + '/' + template_file + '.yaml'),
  }
  for template_file in template_files
];

{
  [template.name]: {
    metadata+: {
      annotations+: {
        stackgres_version: com.inventory().parameters.stackgres_operator.version,
      },
    },
  }
  for template in templates
}

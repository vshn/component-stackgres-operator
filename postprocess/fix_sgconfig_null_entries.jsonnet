local com = import 'lib/commodore.libjsonnet';

local file_extension = '.yaml';
local file_sgconfig = 'sgconfig';

local sgconfig = 
{
    name: file_sgconfig,
    content: com.yaml_load_all(std.extVar('output_path') + '/' + file_sgconfig + file_extension),
}
;

{
  [sgconfig.name]: std.prune(sgconfig.content)
}

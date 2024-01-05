local com = import 'lib/commodore.libjsonnet';

local crd_files = [
'SGBackup',
'SGCluster',
'SGConfig',
'SGDbOps',
'SGDistributedLogs',
'SGInstanceProfile',
'SGObjectStorage',
'SGPoolingConfig',
'SGPostgresConfig',
'SGScript',
'SGShardedBackup',
'SGShardedCluster',
'SGShardedDbOps',
];

local crds = [
  {
    name: crd_file,
    content: com.yaml_load_all(std.extVar('output_path') + '/' + crd_file + '.yaml'),
  }
  for crd_file in crd_files
];

{
  [crd.name]: std.filter(function(it) it != null, crd.content)
  for crd in crds
}

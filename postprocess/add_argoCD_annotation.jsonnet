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
  // TODO: replace that part
  // broken [crd.name]: std.map(function(it) [it.metadata : annotations["argocd.argoproj.io/sync-options"]="ServerSideApply=true"], crd.content)
  // [crd.name]: std.map(function(it) [std.trace("%s" % [it.metadata],it)], crd.content),
  [crd.name]: std.map(function(it) { it: { metadata: { annotations: { a: 1 } } } }, crd.content)
  // [crd.name]: std.map(function(it) [std.trace("%s" % [it.metadata],it)], crd.content),
  for crd in crds
}

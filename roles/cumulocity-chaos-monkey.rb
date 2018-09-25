name 'cumulocity-chaos-monkey'
description 'Role that determines nodes which should be terminated within chaos-monkey tests'

run_list(
  'recipe[cumulocity-chaos-monkey::server_terminations]'
)
#!/bin/bash


# mv provision/$infra to .infra/$infra/provision
for dir in provision/*; do

  if [[ $dir =~ ^provision/(.+)$ ]]; then
    infra=${BASH_REMATCH[1]}
    if [[ -d "$dir" && "$infra" != "apps" ]]; then
      echo "Migrating provision files for $infra ..."
      mkdir -p ".infra/$infra"
      cp -R provision/$infra .infra/$infra/provision
    fi
  fi
done

# mv infra-$infra.yaml .infra/$infra/descriptor.yml
for file in infra-*.yml; do
  if [[ $file =~ ^infra-(.+)\.yml$ ]]; then
      infra=${BASH_REMATCH[1]}
      echo "Converting docker-compose file for $infra ..."
      cp $file .infra/${infra}/descriptor.yml
  fi
done;


# change reference to provision/global/libs/functions.sh to
# .infra/global/libs/functions.sh
find .infra -name "*.sh" | xargs -I {} echo sed -i "''" -e "'s#source provision/global/libs/functions.sh#source .infra/global/libs/functions.sh#'" {} > fix.sh

# change reference to ./.state to ../../.state
find .infra -name "descriptor.yml" | xargs -I {} echo sed -i "''" -e "'s#./.state#../../.state#'" {} > fix.sh

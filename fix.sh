
# # Migrate apps
# for dir in .apps/*; do
#   if [[ $dir =~ ^.apps/(.+)$ ]]; then
#     app=${BASH_REMATCH[1]}
#     if [[ -d "$dir" ]]; then
#       echo "Migrating provision files for $app ..."
#       mkdir -p ".apps/$app/provision"
#       mv .apps/$app/* .apps/$app/provision
#     fi
#   fi
# done
#
#
for file in app-*.yml; do
  if [[ $file =~ ^app-(.+)\.yml$ ]]; then
      app=${BASH_REMATCH[1]}
      echo "Converting docker-compose file for $app ..."
      cp $file .apps/${app}/descriptor.yml
  fi
done;



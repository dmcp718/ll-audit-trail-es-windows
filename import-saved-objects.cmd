@echo off
setlocal enabledelayedexpansion

set "ELASTIC_PASSWORD=changeme"
set "KIBANA_PASSWORD=changeme"
set "KIBANA_PORT=5601"

echo Importing saved objects to Kibana...
curl -X POST "http://localhost:%KIBANA_PORT%/api/saved_objects/_import?overwrite=true" ^
    -H "kbn-xsrf: true" ^
    --form file=@imports.ndjson ^
    -u elastic:%ELASTIC_PASSWORD%

echo Import complete!

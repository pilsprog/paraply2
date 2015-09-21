#!/bin/bash
set -e

sed 's,${FACEBOOK_APP_ID},'"${FACEBOOK_APP_ID}"',g' -i /usr/src/app/config/config.tmpl
sed 's,${FACEBOOK_SECRET_KEY},'"${FACEBOOK_SECRET_KEY}"',g' -i /usr/src/app/config/config.tmpl
sed 's,${MEETUP_KEY},'"${MEETUP_KEY}"',g' -i /usr/src/app/config/config.tmpl
sed 's,${EVENTBRITE_APP_KEY},'"${EVENTBRITE_APP_KEY}"',g' -i /usr/src/app/config/config.tmpl
sed 's,${ELASTICSEARCH_HOST_PORT},'"${ELASTICSEARCH_HOST_PORT}"',g' -i /usr/src/app/config/config.tmpl
sed 's,${GEO_CENTER_LAT},'"${GEO_CENTER_LAT}"',g' -i /usr/src/app/config/config.tmpl
sed 's,${GEO_CENTER_LON},'"${GEO_CENTER_LON}"',g' -i /usr/src/app/config/config.tmpl
sed 's,${GEO_CENTER_LON},'"${GEO_CENTER_LON}"',g' -i /usr/src/app/config/config.tmpl
sed 's,${GEO_MAX_DIST_KILOMETERS},'"${GEO_MAX_DIST_KILOMETERS}"',g' -i /usr/src/app/config/config.tmpl

cp /usr/src/app/config/config.tmpl /usr/src/app/config/config.coffee

exec "$@"

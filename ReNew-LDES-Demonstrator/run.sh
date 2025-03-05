#!/bin/sh

#Start docker containers
docker compose up -d
echo "Program launching..."
#Wait the system starts
sleep 30s

echo "Press Enter to post observations stream.."
read
#Post the stream configuration
curl -X POST 'http://localhost:8087/admin/api/v1/eventstreams' -H 'Content-Type: text/turtle' -d '@./configs/ldes-server/renew-observations/renew-observations.ttl'
if [ $? != 0 ]
    then exit $?
fi

# The stream locates at http://localhost:8088/renew-observations

echo "Press Enter to post observations time-based view.."
read
#Post the stream configuration
curl -X POST 'http://localhost:8087/admin/api/v1/eventstreams/renew-observations/views' -H 'Content-Type: text/turtle' -d '@./configs/ldes-server/renew-observations/renew-observations.by-time.ttl'
if [ $? != 0 ]
    then exit $?
fi

#Start client for observations
echo "Press Enter to start client for observations."
read
docker compose up ldio-workbench-observations -d
#!/bin/bash -e

# Watch directory
python3 /home/watch_and_send2vdms.py /var/www/streams &

# UDF server
cd /home/remote_function/
python3 udf_server.py 5011 &

# run tornado
exec /home/manage.py

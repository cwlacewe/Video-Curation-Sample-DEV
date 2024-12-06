#!/usr/bin/env python3

import os
import sys
from inotify.adapters import Inotify
from kafka import KafkaProducer
from shutil import copyfile
import socket
import datetime
import logging
import kafka.errors as Errors
import traceback
import vdms


# SETUP LOGGER
logger = logging.getLogger(__name__)
fmt_str = "[%(filename)s:line %(lineno)d] %(levelname)s:: %(message)s"
formatter = logging.Formatter(fmt_str)

stream_handler = logging.StreamHandler()
stream_handler.setLevel(logging.INFO)
stream_handler.setFormatter(formatter)
logger.addHandler(stream_handler)
logger.info('Video: Watch & Ingest')

topic="video_curation_sched"
clientid=socket.gethostname()

kkhost=os.environ["KKHOST"]
dbhost="vdms-service"   #os.environ["DBHOST"]
dbport = 55555
ingestion=os.environ["INGESTION"]
in_source=os.environ["IN_SOURCE"]
video_store_dir="/home/remote_function/functions/files"
# video_store_dir="/var/www/mp4"


def ingest_video(db, ingest_mode, filename_path):
    # filename_path = "1191560.mp4"
    query = {
        "AddVideo": {
            "from_server_file": filename_path, #from_server_file, from_file_path
            "properties" : {
                "name" : "activity_test",
                "category" : "video_path_rop"
            },
            "operations" : [
                {
                    "type": "remoteOp",
                    "url": "http://video-service:5011/video",
                    "options": {
                        "id": "metadata",
                        "otype": "face",
                        "media_type": "video",
                    }
                }
            ]
        }
    }

    video_blob = []
    with open(filename_path, "rb") as fd:
        video_blob.append(fd.read())
    res, res_arr = db.query([query], [video_blob])


def  main(watch_folder=os.getcwd()):

    db = vdms.vdms()
    db.connect(dbhost, dbport)
    # producer = KafkaProducer(bootstrap_servers=kkhost,
    #             client_id=clientid, api_version=(0,10))

    if "videos" in in_source:
        for filename in os.listdir(video_store_dir):
            if filename.endswith(".mp4"):
                filename_path = os.path.join(video_store_dir, filename)
                # copyfile(filename_path, os.path.join("/home/remote_function/functions/files", filename))
                for ingest_mode in ingestion.split(','):
                    # strvalue = "{},{}".format(ingest_mode, filename)
                    # send_producer_msg(producer, topic, strvalue)
                    ingest_video(db, ingest_mode, filename_path)

                # with open('/var/www/mp4/last_video.log', 'w') as f:
                #     f.write("{},{},extract metadata".format(ingest_mode, filename))

    if "stream" in in_source:
        i = Inotify()
        i.add_watch(watch_folder)

        for event in i.event_gen(yield_nones=False):
            (_, type_names, path, filename) = event
            filename_path = os.path.join(video_store_dir, filename)

            # on file write completion, we publish to topic
            if 'IN_CLOSE_WRITE' in type_names and not os.path.exists(filename_path):
                copyfile(os.path.join(path, filename), filename_path)
                for ingest_mode in ingestion.split(','):
                    # strvalue = "{},{}".format(ingest_mode, filename)
                    # send_producer_msg(producer, topic, strvalue)
                    ingest_video(ingest_mode, filename_path)
                # with open('/var/www/mp4/last_video.log', 'w') as f:
                #     f.write("{},{},extract metadata".format(ingest_mode, filename))

if __name__ == '__main__':
    if len(sys.argv) == 2:
        main(sys.argv[1])
    else:
        main()

version: "3.7"

services:

include(zookeeper.m4)
include(kafka.m4)
include(frontend.m4)
include(vdms.m4)
include(stream.m4)
include(video_stream.m4)
include(secret.m4)
include(network.m4)


volumes:
    stream-content:

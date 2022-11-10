
    vdms-service:
        image: intellabs/vdms:latest
        command: ["/bin/sh","-c","cd /vdms/build;./vdms"]
        ports:
            - target: 55555
              published: 55555
              protocol: tcp
              mode: host
        volumes:
            - /etc/localtime:/etc/localtime:ro
        networks:
            - appnet
        restart: always


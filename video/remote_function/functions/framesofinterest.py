import cv2
import skvideo.io
import uuid


def run(ipfilename, format, options):
    opfilename = "tmpfile" + uuid.uuid1().hex + "." + str(format)
    print(opfilename)
    vs = cv2.VideoCapture(ipfilename)

    video = skvideo.io.FFmpegWriter(opfilename, {"-pix_fmt": "bgr24"})

    framelist = list(map(int, options['framesofinterest'].strip().split(',')[:-1]))

    f_id = 0
    while True:        
        (grabbed, frame) = vs.read()
        if not grabbed:
            print("[INFO] no frame read from stream - exiting")
            video.close()
            break        
        
        if f_id in framelist:
            video.writeFrame(frame)
        f_id+=1

    vs.release()
    video.close()

    return opfilename

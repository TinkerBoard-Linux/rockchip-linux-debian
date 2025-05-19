import cv2
import cv2.aruco as aruco
import numpy as np
import time

aruco_dict11 = aruco.getPredefinedDictionary(aruco.DICT_APRILTAG_16H5)
aruco_dict11.bytesList = aruco_dict11.bytesList[[11], :, :]
aruco_dict22 = aruco.getPredefinedDictionary(aruco.DICT_APRILTAG_16H5)
aruco_dict22.bytesList = aruco_dict22.bytesList[[22], :, :]
parameters = aruco.DetectorParameters()
cap = cv2.VideoCapture(0)

if not cap.isOpened():
    print("FAIL")
    exit()

start_time = time.time()
pass_counter = 0
fail_counter = 0
while True:
    end_time = time.time()

    execution_time = end_time - start_time

    if execution_time > 10 :
        print("FAIL")
        break

    ret, frame = cap.read()

    S1 = frame.shape[:2]

    corners11, ids11, __ = aruco.detectMarkers(frame, aruco_dict11, parameters=parameters)
    corners22, ids22, __ = aruco.detectMarkers(frame, aruco_dict22, parameters=parameters)
    if (corners11 and ids11 is not None) and corners22 and ids22 is not None:
        aruco.drawDetectedMarkers(frame, corners11, ids11)
        aruco.drawDetectedMarkers(frame, corners22, ids22)

        tmp = np.array(corners11)
        avgy11 = np.mean(tmp[:, :, 1, 1])
        tmp = np.array(corners22)
        avgy22 = np.mean(tmp[:, :, 1, 1])
        #color = (0, 255, 0) if avgy11 < avgy22 else (0, 0, 255)
        color = (0, 0, 0)
        if avgy11 < avgy22 :
            color = (0, 255, 0)
            pass_counter = pass_counter + 1
            #print(pass_counter)
            if pass_counter > 20 :
                print("PASS")
                break
        else: 
            color = (0, 0, 255)
            fail_counter = fail_counter + 1
            #print(fail_counter)
            if fail_counter > 20 :
                print("FAIL")
                break
        cv2.line(frame, (0, int(avgy11)), (S1[1], int(avgy11)), color, 1)
        cv2.line(frame, (0, int(avgy22)), (S1[1], int(avgy22)), color, 1)

    cv2.imshow('', frame)
    if cv2.waitKey(1) & 0xFF == 27:
        break

cap.release()
cv2.destroyAllWindows()

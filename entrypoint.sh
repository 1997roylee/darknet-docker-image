#!/bin/sh -l

echo `./darknet/darknet detector test config/obj.data config/yolov4-tiny-17.cfg config/yolov4-tiny-17.weights -dont_show -ext_output $1 -out result/result.json`
time=$(date)
cat result/result.json
echo "::set-output name=time::$time"

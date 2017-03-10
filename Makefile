CONFIG_FILE := Makefile.config

ifeq ($(wildcard $(CONFIG_FILE)),)
$(error $(CONFIG_FILE) not found. See $(CONFIG_FILE).example.)
endif
include $(CONFIG_FILE)

# Determine platform
UNAME := $(shell uname -s)
ifeq ($(UNAME), Linux)
	LINUX := 1
else ifeq ($(UNAME), Darwin)
	OSX := 1
endif

opencv_l := -lopencv_core -lopencv_imgcodecs -lopencv_videoio -lopencv_imgproc -lopencv_highgui -lopencv_features2d -lopencv_calib3d
#opencv_l := -lopencv_calib3d -lopencv_core -lopencv_features2d -lopencv_flann -lopencv_gpu -lopencv_highgui -lopencv_imgproc -lopencv_legacy -lopencv_ml -lopencv_objdetect -lopencv_ocl -lopencv_photo -lopencv_stitching -lopencv_superres -lopencv_ts -lopencv_video -lopencv_videostab -lopencv_imgcodecs  -lopencv_videoio
opencv_l := -lopencv_calib3d -lopencv_core -lopencv_features2d -lopencv_flann -lopencv_highgui -lopencv_imgproc  -lopencv_ml -lopencv_objdetect  -lopencv_photo -lopencv_stitching -lopencv_superres  -lopencv_video -lopencv_videostab -lopencv_imgcodecs  -lopencv_videoio


# Linux
ifeq ($(LINUX), 1)
	compiler = g++ -std=c++11
  opencv_lib := -L/usr/local/lib/ $(opencv_l)
  opencv_flags := -I/usr/local/include/opencv
else
	compiler = g++
  opencv_lib := -L/usr/local/opt/opencv3/lib $(opencv_l)
  opencv_flags := -I/usr/local/opt/opencv3/include
endif

utils = src/WorkImage.cpp src/Utils.cpp
lgflags = -lprotobuf -lglog -lgflags -lpthread
tesseract_lib = -llept -ltesseract

ifdef CAFFE
caffe_include = -Wl,-rpath $(CAFFE)/build/lib -I /usr/local/cuda/include -I $(CAFFE)/build/src/ -I $(CAFFE)/build/include -I $(CAFFE)/include -I /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/Headers/ -L $(CAFFE)/build/lib/
caffe_lib =  -l$(CAFFE_LIB) -lboost_system -lpthread
endif

# CAFFE ?= 0
# ifeq ($(CPU_only), 1)
#  	CAFFE := -DCPU_ONLY=1
# endif

all: $(utils)
	rm -rf bin
	mkdir bin
	$(compiler) -DCAFFE_=1 -o bin/extractRect $(opencv_flags) $(utils) $(caffe_include) src/Output.cpp src/extractRect.cpp $(opencv_lib) $(caffe_lib) -llmdb $(lgflags)
	$(compiler) -o bin/annotateRect $(opencv_flags) $(utils) src/annotateRect.cpp $(lgflags) -lglog $(opencv_lib)

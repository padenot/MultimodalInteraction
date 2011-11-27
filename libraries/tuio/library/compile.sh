#!/bin/sh
javac -source 1.4 -target 1.4  -cp javaosc.jar:../../../lib/core.jar tuio/TuioClient.java
jar cf tuio.jar tuio/*.class
rm tuio/*.class


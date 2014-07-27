#!/bin/sh
mvn install:install-file -Dfile=src/main/resources/as3corelib.swc -DgroupId=com.adobe -DartifactId=as3corelib -Dversion=0.93 -Dpackaging=swc
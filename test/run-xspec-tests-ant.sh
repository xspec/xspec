#!/bin/bash
ant -buildfile ant/build.xml -lib "${SAXON_CP}" "$@"

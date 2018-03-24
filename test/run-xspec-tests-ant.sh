#!/bin/bash
ant -silent -buildfile ant/build.xml -lib "${SAXON_CP}" "$@"

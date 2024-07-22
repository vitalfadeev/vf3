#!/bin/sh
env PATH=${HOME}/bin/LDC/bin:${PATH} dub build --build=release-shared --compiler=ldc2

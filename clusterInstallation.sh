#!/bin/bash

# lets download a UI to make life easier
gh repo clone yahoo/CMAK

# make a build, unzip it and run it. Open localhost:9000
./CMAK/sbt clean dist
unzip ./CMAK/target/universal/cmak-3.0.0.6.zip 
sudo rm -r /CMAK
cmak-3.0.0.6/bin/cmak


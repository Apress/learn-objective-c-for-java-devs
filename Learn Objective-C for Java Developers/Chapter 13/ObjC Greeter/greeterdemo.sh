#!/bin/bash

echo "Objective-C Distributed Objects demonstration"

cd "`dirname "$0"`/Greeter"

# Build the Objective-C project
xcodebuild -target All -configuration Release

# Start the Greeter server
build/Release/Greeter --mach &
sleep 1

# Run the Guest process, which connects to Greeter and talks to it
build/Release/Guest --mach

# Terminate the Greeter service
kill %+

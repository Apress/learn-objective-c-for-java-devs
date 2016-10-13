#!/bin/bash

echo "Java RMI demonstration"

cd "`dirname "$0"`"

# Compile all of the Java source files
javac -verbose com/apress/java/rmi/*.java

# Compile the proxy object for GreeterImpl
rmic -verbose com.apress.java.rmi.GreeterImpl

# Start the rmiregistry service
rmiregistry &
sleep 1

# Start the Greeter server
java com.apress.java.rmi.GreeterImpl &
sleep 1

# Run the Guest process, which connects to Greeter and talks to it
java com.apress.java.rmi.Guest

# Terminate the Greeter service
kill %+
sleep 1

# Terminate the rmiregistry
killall rmiregistry
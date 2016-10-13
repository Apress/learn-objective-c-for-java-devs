//
//  Greeter_main.m
//  Greeter
//
//  Created by James Bucanek on 4/8/09.
//  Copyright 2009 Apress. All rights reserved.
//

#include <sys/socket.h>
#include <sys/un.h>

#import "Guest.h"
#import "Greeter.h"

//
// Syntax: Greeter --mach [ <service_name> ]
//         Greeter --network [ <service_name> [ <host_name> | '*' ]]
//         Greeter --socket [ <socket_name> ]
//
// Demonstration of Distributed Objects (DO).
//
// Greeter is the server proess. It creates a Greeter object, then vends it
//	to any interested client process via a public connection.
// Communications can be through Mach ports, IP network, or BSD socket file.
//

static void badSyntax( NSString *problem );
static void badService( NSString *name );


int main (int argc, const char * argv[])
{
	objc_startCollectorThread();	// Life is better with garbage collection
	
	if (argc<2)
		badSyntax(@"expected arguments");
	
	NSString *name = SERVICE_NAME_DEFAULT;
    NSConnection *connection = nil;
	
	NSString *mode = [NSString stringWithCString:argv[1]];
	if ([mode caseInsensitiveCompare:@"--thread"]==NSOrderedSame) {
		//
		// Demo #1 does not use a separate server process
		//
		badSyntax(@"--thread demo part of Guest executable; run Guest --thread");
	} else if ([mode caseInsensitiveCompare:@"--mach"]==NSOrderedSame) {
		//
		// Demo #2: Inter-process connection via Mach ports
		//
		
		// Get the service name argument, or use the default
		if (argc>=3)
			name = [NSString stringWithCString:argv[2]];
		
		// Obtain a connection object
		// For kind of connection, we can use the shared NSConnection object for
		//	the current thread / run loop.
		connection = [NSConnection defaultConnection];
		
		// Register the connection with the Mach port name server
		if (![connection registerName:name])
		{
			badService(name);
		}
	} else if ([mode caseInsensitiveCompare:@"--network"]==NSOrderedSame) {
		//
		// Demo #3: Inter-system connection via IP ports
		//
		
		// Get the service name argument, or use the default
		if (argc>=3)
			name = [NSString stringWithCString:argv[2]];
		
		// Create a connection object that uses NSSocketPorts.
		// Network socket ports are inherently bidirectional, so only one port is needed.
		NSSocketPort *port = [NSSocketPort new];
		
		// For a network connection, an independent NSConnection object must be created.
		// We can't use the shared NSConnection object belonging to the thread, because that
		//	connection uses run loop ports, not socket ports.
		connection = [NSConnection connectionWithReceivePort:port sendPort:nil];
		
		// Register the connection with the socket port name server
		// Note: NSSocketPortNameServer registers the service with Bonjour (aka Zero Config)
		//		 as a service available to any system in the local network zone. So the service name
		//		 must be unique within that namespace.
		if (![[NSSocketPortNameServer sharedInstance] registerPort:port name:name])
		{
			badService(name);
		}
	} else if ([mode caseInsensitiveCompare:@"--socket"]==NSOrderedSame) {
		//
		// Demo #4: Inter-system connection via sockets
		//
		
		// Get the service name argument, or use the default
		name = SOCKET_PATH_DEFAULT;		// for this demo, |name| is the socket file path
		if (argc>=3)
			name = [NSString stringWithCString:argv[2]];
		
		// If the socket file exists, delete it.
		[[NSFileManager defaultManager] removeItemAtPath:name error:NULL];
		
		// Create an BSD address structure that specifies the named socket in the file system
		struct sockaddr_un socketAddress;
		bzero(&socketAddress,sizeof(socketAddress));		// clear structure
		socketAddress.sun_len = sizeof(socketAddress);		// set length and type
		socketAddress.sun_family = AF_UNIX;
		strcpy(socketAddress.sun_path,[name fileSystemRepresentation]);
		// Convert socket structure into an NSData object
		NSData* socketAddressData = [NSData dataWithBytes:&socketAddress
												   length:sizeof(socketAddress)];
		
		// Create the port that will tie the NSConnection to the BSD socket file.
		// The initWithProtocolFamily:... method will perform a bind(), that will create the
		//	pipe file in the filesystem. bind() fails if the file already exists.
		NSPort* pipe = [[NSSocketPort alloc] initWithProtocolFamily:AF_UNIX
														 socketType:SOCK_STREAM
														   protocol:0
															address:socketAddressData];
		if (![pipe isValid])
			badService(name);
		
		// Just like the network demo, create an independent NSConnection object that uses the
		//	bidirectional BSD socket port.
		connection = [NSConnection connectionWithReceivePort:pipe sendPort:nil];
	} else {
		badSyntax(@"unrecognized mode");
	}
	
	NSLog(@"Starting Greeter service '%@'",name);
	[connection setRootObject:[Greeter new]];
	[[NSRunLoop currentRunLoop] run];			// never returns
	
	return 0;
}

static void badSyntax( NSString *problem )
{
	NSLog(@"Greeter: %@",problem);
	NSLog(@"Syntax: Greeter --mach [ <service_name> ]");
	NSLog(@"        Greeter --network [ <service_name> ]");
	NSLog(@"        Greeter --socket [ <socket_file> ]");
	exit(1);
}

static void badService( NSString *name )
{
	NSLog(@"Greeter failed: unable to create a service named '%@'",name);
	exit(2);
}

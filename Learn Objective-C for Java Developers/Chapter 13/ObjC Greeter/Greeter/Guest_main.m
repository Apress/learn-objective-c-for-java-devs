//
//  Guest_main.m
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
// Syntax: Guest --thread
//         Guest --mach [ <service_name> ]
//         Guest --network [ <service_name> [ <host_name> | '*' ]]
//         Guest --socket [ <socket_name> ]
//
// Demonstration of Distributed Objects (DO).
//
// Guest is the client process. It connects to a service through a variety of
//	of communication mediums: intra-process, and inter-process via Mach ports,
//	network services, and BSD socket files.
//
// For all demonstrations other than --thread, you must first launch the
//	Greeter process with the same connection mode. The Guest program will connect
//	to the remote Greeter object, send it a few messages, and disconnect.


static void badSyntax( NSString* problem );
static void badConnection( NSString* name, NSString *problem );


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
		// Demo #1: Inter-thread connection
		//
		// This demonstrates connecting to an distributed object running
		//	in another thead of the same process. Unlike the other demonstrations,
		//	this one starts its own "server" running in the same process.
		
		// Connections between threads are not named or registered
		name = @"<irrelevent>";
		
		// Create two simple, in-process, ports to communicate through.
		NSPort *receivePort = [NSPort port];	// Guest's message receive port
		NSPort *sendPort = [NSPort port];		// Guest's message send port
		
		//
		// Create the connection that will talk to the Greeter object
		//
		
		NSLog(@"Connecting to Greeter in local thread");
		connection = [[NSConnection alloc] initWithReceivePort:receivePort
													  sendPort:sendPort];
		
		
		//
		// Create the the Greeter "server" object and vend it to a connection
		//	running in its own thread with its own run loop. This allows it
		//	to ansynchronously respond to messages pushed onto its receive port.
		//
		
		// Create a connection to vend the Greeter.
		// Notice that the ports are reversed: the Greeter receives messages
		//	from the Guest's send port, and visa versa
		NSConnection *serverConnection = [NSConnection connectionWithReceivePort:sendPort
																		sendPort:receivePort];
		// Create a new Greeter object and vend it
		[serverConnection setRootObject:[Greeter new]];
		
		// Start a new thread that does nothing but service the connection using a run loop
		NSLog(@"Starting Greeter service in new thread with connection %@",serverConnection);
		[serverConnection runInNewThread];
		
	} else if ([mode caseInsensitiveCompare:@"--mach"]==NSOrderedSame) {
		//
		// Demo #2: Inter-process connection via Mach ports
		//
		// This demonstration connects to distant object via named Mach (kernal) ports.
		
		// Get the service name argument, or use the default
		if (argc>=3)
			name = [NSString stringWithCString:argv[2]];
		
		// Create a connection using the registered port
		NSLog(@"Connecting to greeter '%@' via Mach ports",name);
		connection = [NSConnection connectionWithRegisteredName:name host:nil];
	} else if ([mode caseInsensitiveCompare:@"--network"]==NSOrderedSame) {
		//
		// Demo #3: Inter-process connection via IP ports
		//
		// This demonstration connects to a distant object via a named service
		//	published on the local network.
		
		// Get the service name argument, or use the default
		if (argc>=3)
			name = [NSString stringWithCString:argv[2]];
		// Get an optional host name argument.
		// If omitted, use "*", which will find any host with that service.
		NSString *host = @"*";
		if (argc>=4)
			host = [NSString stringWithCString:argv[3]];
		
		// Get a port object that is connected to the port of the registered service.
		NSPort *port = [[NSSocketPortNameServer sharedInstance] portForName:name
																	   host:host];
		if (port==nil)
			badConnection(name,[NSString stringWithFormat:@"no service on host '%@'",host]);
		
		// Create an independent connection object using that port.
		// Note: We only have to connect on half of the connection, since network socket
		//		 ports are inherently bidirectional.
		NSLog(@"Connecting to greeter '%@' on host '%@' via IP ports",name,host);
		connection = [NSConnection connectionWithReceivePort:nil sendPort:port];
	} else if ([mode caseInsensitiveCompare:@"--socket"]==NSOrderedSame) {
		//
		// Demo #4: Inter-process connection via sockets
		//
		// This demonstration connects to a distant object via a socket file.
		// In theory, this basic technique could be used to communicate using
		//	any kind of BSD socket, which includes network sockets.
		
		// Get the service name argument, or use the default
		name = SOCKET_PATH_DEFAULT;		// for this demo, |name| is the socket file path
		if (argc>=3)
			name = [NSString stringWithCString:argv[2]];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:name])
			badConnection(name,@"no such file");
		NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:name error:NULL];
		if (![[attrs fileType] isEqualToString:NSFileTypeSocket])
			badConnection(name,@"file is not a socket");
		
		// Create an BSD address structure that specifies the named socket in the file system
		struct sockaddr_un socketAddress;
		bzero(&socketAddress,sizeof(socketAddress));		// clear structure
		socketAddress.sun_len = sizeof(socketAddress);		// set length and type
		socketAddress.sun_family = AF_UNIX;
		strcpy(socketAddress.sun_path,[name fileSystemRepresentation]);
		// Convert socket structure into an NSData object
		NSData* socketAddressData = [NSData dataWithBytes:&socketAddress
												   length:sizeof(socketAddress)];
		// Create a port connected to the socket.
		NSPort *port = [[NSSocketPort alloc] initRemoteWithProtocolFamily:AF_UNIX
															   socketType:SOCK_STREAM
																 protocol:0
																  address:socketAddressData];
		if (port==nil)
			badConnection(name,@"cannot connect to socket");
		
		// Create an independent connection object using the socket port.
		NSLog(@"Connecting to greeter via socket file '%@'",name);
		connection = [NSConnection connectionWithReceivePort:nil sendPort:port];
	} else {
		badSyntax(@"unrecognized mode");
	}
	
	if (connection==nil)
		badConnection(name,@"Failed to create connection");
	
	// Obtain the vended (distant) object from the connection
	Greeter *greeter = (Greeter*)[connection rootProxy];
	
	// Create a local Guest object
	Guest *guest = [Guest new];
	
	// Send messages to the distant object
	[greeter sayHello];
	[greeter greetGuest:guest];
	NSString *lastWord = [greeter sayGoodbye];
	NSLog(@"Greeter's final response was \"%@\"",lastWord);
	
	//	NSLog(@"%@",[connection statistics]);
	
    return 0;
}

static void badSyntax( NSString* problem )
{
	NSLog(@"Guest: %@",problem);
	NSLog(@"Syntax: Guest --thread");
	NSLog(@"        Guest --mach [ <service_name> ]");
	NSLog(@"        Guest --network [ <service_name> [ <host_name> | '*' ]]");
	NSLog(@"        Guest --socket [ <socket_name> ]");
	exit(1);
}

static void badConnection( NSString* name, NSString *problem )
{
	NSLog(@"Guest unable to connect to service '%@': %@",name,problem);
	exit(2);
}


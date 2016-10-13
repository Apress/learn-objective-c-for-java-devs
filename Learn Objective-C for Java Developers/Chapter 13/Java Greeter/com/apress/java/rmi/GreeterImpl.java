package com.apress.java.rmi;

import java.rmi.*;
import java.rmi.server.*;

public class GreeterImpl extends UnicastRemoteObject implements Greeter {

	private static final long serialVersionUID = 999010092613539924L;
	
	public static void main(String[] args)
	{
		String host = null;
		String name = null;
		if (args.length>=1)
			host = args[0];
		if (args.length>=2)
			name = args[1];
		String greeterServiceURI = makeServiceURI(host,name);
		
		try {
			Greeter greeter = new GreeterImpl();
			System.out.println("Starting Greeter service at "+greeterServiceURI);
			Naming.rebind(greeterServiceURI,greeter);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static String makeServiceURI( String host, String name )
	{
		if (host==null)
			host = "localhost";
		if (name==null)
			name = "JavaGreeter";
		return "rmi://"+host+"/"+name;
	}
	
	public GreeterImpl() throws RemoteException {
		super();
	}

	public void sayHello() throws RemoteException {
		System.out.println("Greeter "+getClass().getName()+" was asked to sayHello()");
	}

	public void greetGuest(Guest guest) throws RemoteException {
		System.out.println("Greeter "+getClass().getName()+" was asked to talkBackTo("+guest+")");
		guest.listen("I'm pleased to meet you, "+guest+"!");
	}

	public String sayGoodbye() throws RemoteException {
		System.out.println("Greeter "+getClass().getName()+" was asked to sayGoodbye()");
		return "It was a pleasure serving you.";
	}

}

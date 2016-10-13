package com.apress.java.rmi;

import java.io.Serializable;
import java.rmi.Naming;

public class Guest implements Serializable {
	
	private static final long serialVersionUID = -478469725382736366L;

	public static void main(String[] args)
	{
		String host = null;
		String name = null;
		if (args.length>=1)
			host = args[0];
		if (args.length>=2)
			name = args[1];
		String greeterServiceURI = GreeterImpl.makeServiceURI(host,name);
	
		try {
			System.out.println("Looking up greeter at "+greeterServiceURI);
			Greeter greeter = (Greeter)Naming.lookup(greeterServiceURI);
			Guest guest = new Guest();

			greeter.sayHello();
			greeter.greetGuest(guest);
			String lastWord = greeter.sayGoodbye();
			System.out.println("Greeter's final response was \""+lastWord+"\"");
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void listen( String message )
	{
		System.out.println(getClass().getName()+" heard \""+message+"\"");
	}
}

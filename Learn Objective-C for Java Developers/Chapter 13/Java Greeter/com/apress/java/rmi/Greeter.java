package com.apress.java.rmi;

import java.rmi.*;

public interface Greeter extends Remote {
	public void sayHello( ) throws java.rmi.RemoteException;
	public void greetGuest( Guest listener ) throws java.rmi.RemoteException;
	public String sayGoodbye( ) throws java.rmi.RemoteException;
}
